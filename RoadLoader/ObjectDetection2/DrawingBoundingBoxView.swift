//
//  DrawingBoundingBoxView.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/20.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import Vision

class DrawingBoundingView: UIView {
    
    static private var colors: [String: UIColor] = [:]
    
    // objectのバウンディングボックスの色設定
    public func labelColor(with label: String) -> UIColor {
        guard let color = DrawingBoundingView.colors[label] else {
            let color = UIColor(hue: .random(in: 0...1), saturation: 1, brightness: 1, alpha: 0.0)
            DrawingBoundingView.colors[label] = color
            return color
        }
        return color
    }
    
    // VNRecognizedObjectObservation: 認識されたオブジェクトのラベルに関する観測値．最大1.0
    // didSet: プロパティ監視処理，プロパティの変更後に処理を行う
    public var predictedObjects: [VNRecognizedObjectObservation] = [] {
        didSet {
            self.drawBoxs(with: predictedObjects)
            // 再描画をシステムに依頼
            self.setNeedsDisplay()
        }
    }
    
    func drawBoxs(with predictions: [VNRecognizedObjectObservation]) {
        // subviewを消す
        subviews.forEach({ $0.removeFromSuperview()})
        
        for prediction in predictions {
            createLabelAndBox(prediction: prediction)
        }
    }
    
    func createLabelAndBox(prediction: VNRecognizedObjectObservation) {
        //let labelString: String? = prediction.label
    }
}
