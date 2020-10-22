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
        
        let sb3 = UIStoryboard(name: "ObjectDetection2View", bundle: nil)
        let od2ViewController: UIViewController = sb3.instantiateInitialViewController()!
        
        let sb4 = UIStoryboard(name: "MainMenuView", bundle: nil)
        let mainmenuViewController: UIViewController = sb4.instantiateInitialViewController()!
        
        setViewControllers([imageRecognitionViewController, objectDetectionViewController, od2ViewController, mainmenuViewController], animated: false)
    }
    
}
