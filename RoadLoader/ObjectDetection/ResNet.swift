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

let resnet_classes = ["no_bicycles", "peds_bicycles_crossing", "no_vehicles", "weight_limit", "no_motorcycles", "closed_vehicles", "width_limit", "one_way", "vehicles_only", "slow", "no_stopping", "speed_limit", "crosswalk", "traffic_rights_ahead", "closed_road", "no_overtaking", "bicycles_and_peds_only", "no_parking", "bicycles_only", "no_entry", "no_peds_crossing", "bicycles_crossing", "peds_only", "stop", "height_limit"]
let resnet_cls2jp: Dictionary<String,String> = [
    "no_bicycles":"自転車通行止め",
    "peds_bicycles_crossing": "横断歩道・自転車横断帯",
    "no_vehicles": "二輪の自動車以外の自動車通行止め",
    "weight_limit": "重量制限(t)",
    "no_motorcycles": "二輪の自動車・原動機付自転車通行止め",
    "closed_vehicles": "車両通行止め",
    "width_limit": "最大幅(m)",
    "one_way": "一方通行",
    "vehicles_only": "自動車専用",
    "slow": "徐行",
    "no_stopping": "駐停車禁止",
    "speed_limit": "最高速度(km/h)",
    "crosswalk": "横断歩道",
    "traffic_rights_ahead": "信号機あり",
    "closed_road": "通行止め",
    "no_overtaking": "追い越し禁止",
    "bicycles_and_peds_only": "自転車及び歩行者専用",
    "no_parking": "駐車禁止",
    "bicycles_only": "自転車専用",
    "no_entry": "車両進入禁止",
    "no_peds_crossing": "歩行者横断禁止",
    "bicycles_crossing": "自転車横断帯",
    "peds_only": "歩行者専用",
    "stop": "止まれ",
    "height_limit": "高さ制限"]

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
