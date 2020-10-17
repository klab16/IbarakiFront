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
        let storyboard = UIStoryboard(name: "imageRecognitionView", bundle: nil)
        let imageRecognitionViewController: UIViewController = storyboard.instantiateInitialViewController()!
        
        setViewControllers([imageRecognitionViewController], animated: true)
    }
}
