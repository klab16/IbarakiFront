//
//  MainMenuViewController.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/21.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet weak var walkButton: UIButton!
    @IBOutlet weak var bikeButton: UIButton!
    @IBOutlet weak var motorbikeButton: UIButton!
    @IBOutlet weak var carButton: UIButton!
    @IBOutlet weak var trackButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var flag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 各種ボタンのイラスト設定
        setButtonIcon()
        
        // ボタンの枠線の追加
        setButtonBorder()
    }
    
    func setButtonIcon() {
        self.walkButton.setImage(UIImage(named: "walkMan"), for: .normal)
        self.walkButton.setTitle("", for: .normal)
        self.walkButton.tintColor = .gray
        
        self.bikeButton.setImage(UIImage(named: "bike"), for: .normal)
        self.bikeButton.setTitle("", for: .normal)
        self.bikeButton.tintColor = .gray
        
        self.motorbikeButton.setImage(UIImage(named: "motorbike"), for: .normal)
        self.motorbikeButton.setTitle("", for: .normal)
        self.motorbikeButton.tintColor = .gray
        
        self.carButton.setImage(UIImage(named: "car"), for: .normal)
        self.carButton.setTitle("", for: .normal)
        self.carButton.tintColor = .gray
        
        self.trackButton.setImage(UIImage(named: "track"), for: .normal)
        self.trackButton.setTitle("", for: .normal)
        self.trackButton.tintColor = .gray
        
        self.saveButton.backgroundColor = .systemBlue
        self.saveButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
        self.saveButton.setTitleColor(UIColor.white, for: .normal)
    }
    
    func setButtonBorder() {
        self.walkButton.layer.borderColor = UIColor.gray.cgColor
        self.walkButton.layer.borderWidth = 3.0
        self.walkButton.layer.cornerRadius = 10.0
        
        self.bikeButton.layer.borderColor = UIColor.gray.cgColor
        self.bikeButton.layer.borderWidth = 3.0
        self.bikeButton.layer.cornerRadius = 10.0
        
        self.motorbikeButton.layer.borderColor = UIColor.gray.cgColor
        self.motorbikeButton.layer.borderWidth = 3.0
        self.motorbikeButton.layer.cornerRadius = 10.0
        
        self.carButton.layer.borderColor = UIColor.gray.cgColor
        self.carButton.layer.borderWidth = 3.0
        self.carButton.layer.cornerRadius = 10.0
        
        self.trackButton.layer.borderColor = UIColor.gray.cgColor
        self.trackButton.layer.borderWidth = 3.0
        self.trackButton.layer.cornerRadius = 10.0
        
        self.saveButton.layer.borderColor = UIColor.systemBlue.cgColor
        self.saveButton.layer.borderWidth = 3.0
        self.saveButton.layer.cornerRadius = 10.0
    }
    
    // ボタンの色を変える処理
    func selectedButtonColor(button: UIButton) {
        button.tintColor = .white
        button.backgroundColor = .gray
    }
    func normalButtonColor(button: UIButton) {
        button.tintColor = .gray
        button.backgroundColor = .none
    }
    
    @IBAction func walkButtonTapped(_ sender: Any) {
        
        // ボタンの反転処理
        flag = !flag
        if flag {
            selectedButtonColor(button: self.walkButton)
        } else {
            normalButtonColor(button: self.walkButton)
        }
    }
    
    
}
