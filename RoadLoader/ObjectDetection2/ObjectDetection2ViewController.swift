//
//  ObjectDetection2ViewController.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/20.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import Vision
import CoreMedia // AVの各フレームでのピクセルデータなどを参照，操作できる

class ObjectDetection2ViewController: UIViewController {
    
    @IBOutlet weak var videoPreview: UIView!
//    @IBOutlet weak var boxesView: DrawingBoundingBoxView!
    @IBOutlet weak var labelsTableView: UITableView!
    
    @IBOutlet weak var inferenceLabel: UILabel!
    @IBOutlet weak var etimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    let objectDetectionModel = YOLOv3Tiny()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
