//
//  YOLO.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/17.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import AVFoundation
// CVのフレームワーク
import Vision

class YOLO {
    let model = YOLOv3Tiny()
    private let session = AVCaptureSession()
    
    // 背面カメラを入力として使用
//    let videoDevice = AVCaptureDevice.default()
}