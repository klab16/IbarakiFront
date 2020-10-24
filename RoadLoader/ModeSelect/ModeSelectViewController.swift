//
//  ModeSelectViewController.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/23.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit

class ModeSelectViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var translationButton: UIButton!
    @IBOutlet weak var assistButton: UIButton!
    
    var userInfo: Dictionary<String, Bool>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "モード選択"
        
        guard let userInfo = UserDefaults.standard.dictionary(forKey: "norimono") as? Dictionary<String, Bool> else {
            print("入ってないよ")
            return
        }
        self.userInfo = userInfo
        print(userInfo)
        setIcon()
        setButton()
        self.detailView.backgroundColor = .systemBackground
        
        // detailが設定されている場合の処理
        guard let detail = UserDefaults.standard.object(forKey: "detail") as? String else {
            return
        }
        print(detail)
        for (key, value) in userInfo {
            if value {
                if key == "motorbike" {
                    setDetail("motorbike", detail)
                } else if key == "track" {
                    setDetail("track", detail)
                }
            }
        }
        
    }
    
    // 乗り物のアイコンセット
    func setIcon() {
        for (key, value) in self.userInfo {
            if value {
                print(key)
                iconImageView.image = UIImage(named: key)
                iconImageView.contentMode = .scaleAspectFill
                iconImageView.tintColor = .gray
            }
        }
    }
    
    func setDetail(_ bikeTrack: String, _ detail: String) {
        let label = UILabel()
        
        label.frame = CGRect(x: 0, y: 20, width: UIScreen.main.bounds.size.width - 20, height: 44)
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont(name: "HiraKakuProN-W6", size: 20)
        
        if bikeTrack == "motorbike" {
            label.text = "排気量は" + detail + "cc"
        } else if bikeTrack == "track" {
            label.text = "重量は" + detail + "t"
        }
        
        self.detailView.addSubview(label)
    }
    
    // ボタンの装飾
    func setButton() {
        self.translationButton.backgroundColor = .systemGreen
        self.translationButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.translationButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        self.translationButton.setTitleColor(UIColor.white, for: .normal)
        self.translationButton.layer.cornerRadius = 10.0
        
        self.assistButton.backgroundColor = .systemTeal
        self.assistButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.assistButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        self.assistButton.setTitleColor(UIColor.white, for: .normal)
        self.assistButton.layer.cornerRadius = 10.0
    }
}
