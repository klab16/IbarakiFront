//
//  RootViewController.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/17.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit

class RootTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTab()
    }
    
    private func setTab() {
        let storyboard = UIStoryboard(name: "ImageRecognitionView", bundle: nil)
        let imageRecognitionViewController: UIViewController = storyboard.instantiateInitialViewController()!
        
        let sb2 = UIStoryboard(name: "ObjectDetectionView", bundle: nil)
        let objectDetectionViewController: UIViewController = sb2.instantiateInitialViewController()!
        
        setViewControllers([imageRecognitionViewController, objectDetectionViewController], animated: false)
    }
    
    // 写真を保存
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
}
