//
//  ImageRecognitionViewController.swift
//  RoadLoader
//
//  Created by 岡本航昇 on 2020/10/17.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ImageRecognitionController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func photoPredict(_ targetPhoto: UIImage) {
        // resnet50 のインスタンス化, （Visionを用いる場合）
        guard let model = try? VNCoreMLModel(for: Resnet50Int8LUT().model) else {
            print("error model")
            return
        }
        
        // リクエスト
        let request = VNCoreMLRequest(model: model) {
            request, error in
            guard let results = request.results as? [VNClassificationObservation] else {
                return
            }
            
            // 確率を整数にする
            let conf = Int(results[0].confidence * 100)
            
            // 候補の一番目
            let name = results[0].identifier
            
            self.textLabel.text = "\(name):\(conf)% \n"
        }
        
        // resize
        request.imageCropAndScaleOption = .centerCrop
        // CIImageに変換
        guard let ciImage = CIImage(image: targetPhoto) else {
            return
        }
        
        // 画像の向き
        let orientation = CGImagePropertyOrientation(
            rawValue: UInt32(targetPhoto.imageOrientation.rawValue))!
        
        // ハンドラを実行
        let handler = VNImageRequestHandler(
            ciImage: ciImage, orientation: orientation)
        
        do{
            try handler.perform([request])
            
        }catch {
            print("error handler")
        }
    }
    @IBAction func startCamera(_ sender: Any) {
        
        let sourceType:UIImagePickerController.SourceType =
            UIImagePickerController.SourceType.camera
        
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(
            UIImagePickerController.SourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        else{
            textLabel.text = "error"
        }
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ imagePicker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        
        // dismiss
        imagePicker.dismiss(animated: true, completion: nil)
        
        if let pickedImage = info[.originalImage]
            as? UIImage {
            
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            
            photoPredict(pickedImage)
        }
    }
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

