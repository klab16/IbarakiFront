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
    
    // ボタンの種類の列挙型
    enum buttonTag: Int {
        case walk = 1
        case bike = 2
        case motorbike = 3
        case car = 4
        case track = 5
    }
    
    // ボタンの押下判定を行う辞書
    var buttonState: Dictionary<String, Bool> = ["walk": false, "bike": false, "motorbike":false, "car": false, "track": false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 各種ボタンのイラスト設定
        setButtonIcon()
        
        // ボタンの枠線の追加
        setButtonBorder()
        
        // UserDefaultsの読み込み
        guard let buttonState = UserDefaults.standard.dictionary(forKey: "norimono") as?  Dictionary<String, Bool> else { return }
        self.buttonState = buttonState
        
        // ボタン状態の更新
        setButtonState(buttonState: self.buttonState)
        
    }
    
    func setButtonIcon() {
        self.walkButton.setImage(UIImage(named: "walkMan"), for: .normal)
        self.walkButton.setTitle("", for: .normal)
        self.walkButton.tintColor = .gray
        //self.walkButton.tag = 1 //strorybordで設定
        
        self.bikeButton.setImage(UIImage(named: "bike"), for: .normal)
        self.bikeButton.setTitle("", for: .normal)
        self.bikeButton.tintColor = .gray
        //self.bikeButton.tag = 2
        
        self.motorbikeButton.setImage(UIImage(named: "motorbike"), for: .normal)
        self.motorbikeButton.setTitle("", for: .normal)
        self.motorbikeButton.tintColor = .gray
        //self.motorbikeButton.tag = 3
        
        self.carButton.setImage(UIImage(named: "car"), for: .normal)
        self.carButton.setTitle("", for: .normal)
        self.carButton.tintColor = .gray
        //self.carButton.tag = 4
        
        self.trackButton.setImage(UIImage(named: "track"), for: .normal)
        self.trackButton.setTitle("", for: .normal)
        self.trackButton.tintColor = .gray
        //self.trackButton.tag = 5
        
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
    
    // 乗り物のボタンを押された時の処理
    @IBAction func pushButton(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        //print(button.tag)
        
        if let tag = buttonTag(rawValue: button.tag) {
            switch tag {
            case .walk:
                buttonAction(buttonName: "walk", button: button)
            case .bike:
                buttonAction(buttonName: "bike", button: button)
            case .motorbike:
                buttonAction(buttonName: "motorbike", button: button)
            case .car:
                buttonAction(buttonName: "car", button: button)
            case .track:
                buttonAction(buttonName: "track", button: button)
            }
        }
    }
    
    // 各乗り物ボタンの処理
    func buttonAction(buttonName: String, button: UIButton) {
        // ボタンの押下フラグ
        guard var flag = buttonState[buttonName] else { return }
        flag = !flag
        
        for (key, _) in buttonState {
            if buttonName == key {
                buttonState[buttonName] = flag
                
            } else {
                buttonState[key] = false
            }
        }
        
        //print(buttonState)
        
        // 各ボタンの状態を更新
        setButtonState(buttonState: buttonState)
        
        // UserDefaultsにボタンの状態を保存
        UserDefaults.standard.set(buttonState, forKey: "norimono")
    }
    
    // ボタンの状態を反映する処理
    func setButtonState(buttonState: Dictionary<String, Bool>) {
        let buttonNames: Dictionary<String, UIButton> = ["walk": walkButton, "bike": bikeButton, "motorbike": motorbikeButton, "car": carButton, "track": trackButton]
        
        for (key, button) in buttonNames {
            guard let flag = buttonState[key] else { return }
            if flag {
                // 押下
                selectedButtonColor(button: button)
            } else {
                // not押下
                normalButtonColor(button: button)
            }
        }
        
        
    }
    
}

