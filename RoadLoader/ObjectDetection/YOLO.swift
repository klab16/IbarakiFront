//
//  YOLO.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/17.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Foundation
// CVのフレームワーク
import Vision

class YOLO {
    // static : override不可
    public static let inputWidth = 416
    public static let inputHeight = 416
    public static let maxBoundingBoxes = 10
    
    let confidenceThreshold: Double = 0.3
    let iouThreshold: Double = 0.5
    
    struct Prediction {
        let classIndex: Int
        let score: Float
        let rect: CGRect
    }
    
    // YOLOv3　インスタンス生成
    // input: image(416 416), iouThreshold, confidenceThreshold
    // output: confidence: 各バウンディングボックスの信頼度，coodinates: 各バウンディングボックス(x,y,w,h)の正規化された座標
//    let model = YOLOv3()
    let model = YOLOv3Tiny()
//    var yolov3Input: YOLOv3Input
    
    public init() { }
    
    public func predict(image: CVPixelBuffer) throws -> [Prediction] {
        let yolov3Input = YOLOv3TinyInput(image: image, iouThreshold: iouThreshold, confidenceThreshold: confidenceThreshold)

//        guard let output = model.prediction(input: yolov3Input) else {
//            return []
//        }
//        return computeBoundingBoxes(features: [output.confidence, output.coordinates])

        if let output = try? model.prediction(input: yolov3Input) {
            return computeBoundingBoxes(features: [output.coordinates, output.coordinates])
        } else {
            return []
        }
    }
    
    public func computeBoundingBoxes(features: [MLMultiArray]) -> [Prediction] {
        print("yeah")
        // assert: 条件を満たさない時エラー
        // yoloはバウンディングボックスを作る時，13*13のグリッドに分割する
        assert(features[0].count == 255*13*13)
        assert(features[1].count == 255*26*26)
        assert(features[2].count == 255*52*52)
        
        var predictions = [Prediction]()
        
        let blockSize: Float = 32
        let boxesPerCell = 3
        let numClasses = 80
        
        let gridHeight = [13, 26, 52]
        let gridWidth = [13, 26, 52]
        
        var featurePointer = UnsafeMutablePointer<Double>(OpaquePointer(features[0].dataPointer))
        var channelStride = features[0].strides[0].intValue
        var yStride = features[0].strides[1].intValue
        var xStride = features[0].strides[2].intValue
        
        func offset(_ channel: Int, _ x: Int, _ y: Int) -> Int {
            return channel*channelStride + y*yStride + x*xStride
        }
        
        for i in 0..<3 {
            featurePointer = UnsafeMutablePointer<Double>(OpaquePointer(features[i].dataPointer))
            channelStride = features[i].strides[0].intValue
            yStride = features[i].strides[1].intValue
            xStride = features[i].strides[2].intValue
            for cy in 0..<gridHeight[i] {
                for cx in 0..<gridWidth[i] {
                    for b in 0..<boxesPerCell {
                        // For the first bounding box (b=0) we have to read channels 0-24,
                        // for b=1 we have to read channels 25-49, and so on.
                        let channel = b*(numClasses + 5)
                        
                        // The fast way:
                        let tx = Float(featurePointer[offset(channel    , cx, cy)])
                        let ty = Float(featurePointer[offset(channel + 1, cx, cy)])
                        let tw = Float(featurePointer[offset(channel + 2, cx, cy)])
                        let th = Float(featurePointer[offset(channel + 3, cx, cy)])
                        let tc = Float(featurePointer[offset(channel + 4, cx, cy)])
                        
                        // The predicted tx and ty coordinates are relative to the location
                        // of the grid cell; we use the logistic sigmoid to constrain these
                        // coordinates to the range 0 - 1. Then we add the cell coordinates
                        // (0-12) and multiply by the number of pixels per grid cell (32).
                        // Now x and y represent center of the bounding box in the original
                        // 416x416 image space.
                        let scale = powf(2.0,Float(i)) // scale pos by 2^i where i is the scale pyramid level
                        let x = (Float(cx) * blockSize + sigmoid(tx))/scale
                        let y = (Float(cy) * blockSize + sigmoid(ty))/scale
                        
                        // The size of the bounding box, tw and th, is predicted relative to
                        // the size of an "anchor" box. Here we also transform the width and
                        // height into the original 416x416 image space.
                        let w = exp(tw) * anchors[i][2*b    ]
                        let h = exp(th) * anchors[i][2*b + 1]
                        
                        // The confidence value for the bounding box is given by tc. We use
                        // the logistic sigmoid to turn this into a percentage.
                        let confidence = sigmoid(tc)
                        
                        // Gather the predicted classes for this anchor box and softmax them,
                        // so we can interpret these numbers as percentages.
                        var classes = [Float](repeating: 0, count: numClasses)
                        for c in 0..<numClasses {
                            // The slow way:
                            //classes[c] = features[[channel + 5 + c, cy, cx] as [NSNumber]].floatValue
                            
                            // The fast way:
                            classes[c] = Float(featurePointer[offset(channel + 5 + c, cx, cy)])
                        }
                        classes = softmax(classes)
                        
                        // Find the index of the class with the largest score.
                        let (detectedClass, bestClassScore) = classes.argmax()
                        
                        // Combine the confidence score for the bounding box, which tells us
                        // how likely it is that there is an object in this box (but not what
                        // kind of object it is), with the largest class prediction, which
                        // tells us what kind of object it detected (but not where).
                        let confidenceInClass = bestClassScore * confidence
                        
                        // Since we compute 13x13x3 = 507 bounding boxes, we only want to
                        // keep the ones whose combined score is over a certain threshold.
                        if confidenceInClass > Float(confidenceThreshold) {
                            let rect = CGRect(x: CGFloat(x - w/2), y: CGFloat(y - h/2),
                                              width: CGFloat(w), height: CGFloat(h))
                            
                            let prediction = Prediction(classIndex: detectedClass,
                                                        score: confidenceInClass,
                                                        rect: rect)
                            predictions.append(prediction)
                        }
                    }
                }
            }
        }
        
        // We already filtered out any bounding boxes that have very low scores,
        // but there still may be boxes that overlap too much with others. We'll
        // use "non-maximum suppression" to prune those duplicate bounding boxes.
        return nonMaxSuppression(boxes: predictions, limit: YOLO.maxBoundingBoxes, threshold: Float(iouThreshold))
    }

}
