//
//  ResNet.swift
//  YOLOv3-CoreML
//
//  Created by shun on 2020/10/26.
//  Copyright © 2020 MachineThink. All rights reserved.
//

import Foundation
import UIKit
import CoreML

class ResNet{
    public static let inputWidth = 224
    public static let inputHeight = 224
    struct Prediction {
        let classConfidence: [String:Double]
        let predClass: String
    }
    
    let model = myresnet()
    
    public init() { }
    
    public func predict(image: CVPixelBuffer) throws -> [Prediction] {
        if let output = try? model.prediction(input1: image) {
            return [Prediction(classConfidence: output.output1, predClass: output.classLabel)]
        } else {
            return []
        }
    }
    
}
