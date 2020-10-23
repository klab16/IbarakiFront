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
    @IBOutlet weak var detailsView: UIView!
    
    var flag = false
    // 排気量などを格納する変数
    var detailsNum: Int?
    
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
        
        // detailsViewの色を普通の色にする
        //self.detailsView.backgroundColor = .systemBackground
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
    
    // どれでもいいから乗り物のボタンを押された時の処理
    @IBAction func pushButton(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        //print(button.tag)
        
        if let tag = buttonTag(rawValue: button.tag) {
            switch tag {
            case .walk:
                buttonAction(buttonName: "walk", button: button)
                deleteTextField()
            case .bike:
                buttonAction(buttonName: "bike", button: button)
                deleteTextField()
            case .motorbike:
                buttonAction(buttonName: "motorbike", button: button)
                guard let flag = buttonState["motorbike"] else { return }
                if flag {
                    setTextField(buttonName: "motorbike")
                } else {
                    deleteTextField()
                }
                
            case .car:
                buttonAction(buttonName: "car", button: button)
                deleteTextField()
            case .track:
                buttonAction(buttonName: "track", button: button)
                guard let flag = buttonState["track"] else { return }
                if flag {
                    setTextField(buttonName: "track")
                } else {
                    deleteTextField()
                }
                
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
    
    // バイク，トラックが選択された場合，排気量や重量を入力するテキストフィールドを追加
    func setTextField(buttonName: String) {
        let textField = UITextField()
        let unitLabel = UILabel()
        deleteTextField()
        
        textField.frame = CGRect(x: 10, y: 50, width: UIScreen.main.bounds.size.width/1.8, height: 30)
        
        // キーボードタイプを指定
        textField.keyboardType = .default
        // 枠線のスタイルを設定
        textField.borderStyle = .roundedRect
        // 改行ボタンの種類を設定
        textField.returnKeyType = .done
        textField.keyboardType = UIKeyboardType.numberPad
        
        unitLabel.frame = CGRect(x: UIScreen.main.bounds.size.width-80, y: 50, width: 50, height: 30)
        unitLabel.textAlignment = .center
        unitLabel.font = UIFont(name: "HiraKaKuProN-W6", size: 30)
        unitLabel.textColor = .gray
        unitLabel.text = ""
        
        if buttonName == "motorbike" {
            textField.placeholder = "排気量を入力してください"
            unitLabel.text = "cc"
        } else if buttonName == "track" {
            textField.placeholder = "重量を入力してください"
            unitLabel.text = "t"
        }
        
        self.detailsView.addSubview(textField)
        self.detailsView.addSubview(unitLabel)
        self.detailsView.bringSubviewToFront(textField)
        
        textField.delegate = self
        
    }
    
    // detailsViewのUI部品を消す
    func deleteTextField() {
        for v in self.detailsView.subviews {
            v.removeFromSuperview()
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let num: Int = self.detailsNum else { return }
        UserDefaults.standard.set(num, forKey: "detail")
        print("save", num)
    }
    
}
extension MainMenuViewController: UITextFieldDelegate {
    // 改行ボタンを押した時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Return")
        return true
    }

    // クリアボタンが押された時の処理
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        print("Clear")
        return true
    }

    // テキストフィールドがフォーカスされた時の処理
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("Start")
        return true
    }

    // テキストフィールドでの編集が終了する直前での処理
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("End",textField.text ?? "")
        if let contents: String = textField.text {
            self.detailsNum = Int(contents)!
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.detailsView.endEditing(true)
    }
    
}
