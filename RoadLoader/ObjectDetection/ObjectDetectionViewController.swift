import UIKit
import Vision
import AVFoundation
import CoreMedia
import VideoToolbox

class ObjectDetectionViewController: UIViewController {
    @IBOutlet weak var videoPreview: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var debugImageView: UIImageView!
    
    let yolo = YOLO()
    let resnet = ResNet()
    
    var videoCapture: VideoCapture!
    var request: VNCoreMLRequest!
    var startTimes: [CFTimeInterval] = []
    
    var boundingBoxes = [BoundingBox]()
    var colors: [UIColor] = []
    
    let ciContext = CIContext()
    var resizedPixelBuffer_yolo: CVPixelBuffer?
    var resizedPixelBuffer_res: CVPixelBuffer?
    
    var framesDone = 0
    var frameCapturingStartTime = CACurrentMediaTime()
    let semaphore = DispatchSemaphore(value: 2)
    
    var userInfo: Dictionary<String, Bool>!
    
    var mode: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeLabel.text = ""
        
        setUpBoundingBoxes()
        setUpCoreImage()
        setUpCamera()
        
        frameCapturingStartTime = CACurrentMediaTime()
        
        // nabvigationbarの下からuiを配置
        self.navigationController?.navigationBar.isTranslucent = false
        
        guard let userInfo = UserDefaults.standard.dictionary(forKey: "norimono") as? Dictionary<String, Bool> else {
            return
        }
        self.userInfo = userInfo
        print(userInfo)
        
        // モードの取得
        guard let md = UserDefaults.standard.string(forKey: "mode") else { return }
        self.mode = md
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print(#function)
    }
    
    // MARK: - Initialization
    
    func setUpBoundingBoxes() {
        for _ in 0..<YOLO.maxBoundingBoxes {
            boundingBoxes.append(BoundingBox())
        }
        
        // Make colors for the bounding boxes. There is one color for each class,
        // 80 classes in total.
        for r: CGFloat in [0.2, 0.4, 0.6, 0.8, 1.0] {
            for g: CGFloat in [0.3, 0.7, 0.6, 0.8] {
                for b: CGFloat in [0.4, 0.8, 0.6, 1.0] {
                    let color = UIColor(red: r, green: g, blue: b, alpha: 1)
                    colors.append(color)
                }
            }
        }
    }
    
    func setUpCoreImage() {
        let status = CVPixelBufferCreate(nil, YOLO.inputWidth, YOLO.inputHeight, kCVPixelFormatType_32BGRA, nil, &resizedPixelBuffer_yolo)
        let status_res = CVPixelBufferCreate(nil, ResNet.inputWidth, ResNet.inputHeight, kCVPixelFormatType_32BGRA, nil, &resizedPixelBuffer_res)
        if status != kCVReturnSuccess {
            print("Error: could not create resized pixel buffer", status)
        }
        if status_res != kCVReturnSuccess {
            print("Error: could not create resized pixel buffer", status_res)
        }
    }

    func setUpCamera() {
        videoCapture = VideoCapture()
        videoCapture.delegate = self
        videoCapture.fps = 50
        videoCapture.setUp(sessionPreset: AVCaptureSession.Preset.vga640x480) { success in
            if success {
                // Add the video preview into the UI.
                if let previewLayer = self.videoCapture.previewLayer {
                    self.videoPreview.layer.addSublayer(previewLayer)
                    self.resizePreviewLayer()
                }
                
                // Add the bounding box layers to the UI, on top of the video preview.
                for box in self.boundingBoxes {
                    box.addToLayer(self.videoPreview.layer)
                }
                
                // Once everything is set up, we can start capturing live video.
                self.videoCapture.start()
            }
        }
    }
    
    // MARK: - UI stuff
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        resizePreviewLayer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func resizePreviewLayer() {
        videoCapture.previewLayer?.frame = videoPreview.bounds
    }
    
    // MARK: - Doing inference
    
    func predict(image: UIImage) {
        if let pixelBuffer = image.pixelBuffer(width: YOLO.inputWidth, height: YOLO.inputHeight) {
            predict(pixelBuffer: pixelBuffer)
        }
    }
    
    func predict(pixelBuffer: CVPixelBuffer) {
        // Measure how long it takes to predict a single video frame.
        let startTime = CACurrentMediaTime()
        
        // Resize the input with Core Image to 416x416.
        guard let resizedPixelBuffer_yolo = resizedPixelBuffer_yolo else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let sx = CGFloat(YOLO.inputWidth) / CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let sy = CGFloat(YOLO.inputHeight) / CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
        let scaledImage = ciImage.transformed(by: scaleTransform)
        ciContext.render(scaledImage, to: resizedPixelBuffer_yolo)
        
        // Resize the input to 416x416 and give it to our model.
        if let boundingBoxes = try? yolo.predict(image: resizedPixelBuffer_yolo) {
            let elapsed = CACurrentMediaTime() - startTime
            showOnMainThread(boundingBoxes, elapsed, pixelBuffer)
        }
    }

    func showOnMainThread(_ boundingBoxes: [YOLO.Prediction], _ elapsed: CFTimeInterval, _ pixelBuffer: CVPixelBuffer) {
        DispatchQueue.main.async {
            // For debugging, to make sure the resized CVPixelBuffer is correct.
            //var debugImage: CGImage?
            //VTCreateCGImageFromCVPixelBuffer(resizedPixelBuffer, nil, &debugImage)
            //self.debugImageView.image = UIImage(cgImage: debugImage!)
            
            self.show(predictions: boundingBoxes, pixelBuffer: pixelBuffer)
            
            let fps = self.measureFPS()
            self.timeLabel.text = String(format: "Elapsed %.5f seconds - %.2f FPS", elapsed, fps)
            
            self.semaphore.signal()
        }
    }
    
    func measureFPS() -> Double {
        // Measure how many frames were actually delivered per second.
        framesDone += 1
        let frameCapturingElapsed = CACurrentMediaTime() - frameCapturingStartTime
        let currentFPSDelivered = Double(framesDone) / frameCapturingElapsed
        if frameCapturingElapsed > 1 {
            framesDone = 0
            frameCapturingStartTime = CACurrentMediaTime()
        }
        return currentFPSDelivered
    }
    
    func show(predictions: [YOLO.Prediction],  pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        var classLabel = ""
        var score: Double = 0.0
        
        for i in 0..<boundingBoxes.count {
            if i < predictions.count {
                let prediction = predictions[i]

                if prediction.classIndex == 1 {
                    // trafic_signの処理
                    let ret = resnetInput(ciImage: ciImage, prediction: prediction)
                    classLabel = ret.label
                    score = ret.conf
                    print(classLabel)
                    
                } else {
                    // sub_signの処理 OCR
                    classLabel = "sub"
                    score = 0.0
                }
                
                let width = view.bounds.width
                let height = width * 4 / 3
                let scaleX = width / CGFloat(YOLO.inputWidth)
                let scaleY = height / CGFloat(YOLO.inputHeight)
                let top = (view.bounds.height - height) / 2
                
                var rect = prediction.rect
                rect.origin.x *= scaleX
                rect.origin.y *= scaleY
                rect.origin.y += top
                rect.size.width *= scaleX
                rect.size.height *= scaleY

//                let label = String(format: "%@ %.1f", classLabel, prediction.score * 100)
                
                let color = colors[prediction.classIndex]
                guard let mode: String = self.mode else { return }
                boundingBoxes[i].show(frame: rect, label: classLabel, score: score, color: color, mode: mode)
            } else {
                boundingBoxes[i].hide()
            }
        }
    }
    
    func resnetInput(ciImage: CIImage, prediction: YOLO.Prediction) -> (label: String, conf: Double) {
        // Translate and scale the rectangle to our own coordinate system.
        let rect = prediction.rect
        let width = CGFloat(480)
        let height = CGFloat(640)
        let scaleX = width / CGFloat(YOLO.inputWidth)
        let scaleY = height / CGFloat(YOLO.inputHeight)

        // Resize the input with Core Image to 224x224.
        let x = rect.origin.x * scaleX
        let y = rect.origin.y * scaleY
        let w = rect.size.width * scaleX
        let h = rect.size.height * scaleY
        // adjust y (second arg)

        // BB部分の切り出し処理
        let realRect = CGRect(x: CGFloat(x), y: CGFloat(640 - y - h), width: CGFloat(w), height: CGFloat(h))
        guard let resizedPixelBuffer_res = resizedPixelBuffer_res else { return ("error", 0.0) }
        let croppedImage = ciImage.cropped(to: realRect)
        let cropImage = ciContext.createCGImage(croppedImage, from:croppedImage.extent)
        let cropped = CIImage(cgImage: cropImage!)
        let sx = CGFloat(224) / CGFloat(w)
        let sy = CGFloat(224) / CGFloat(h)
        let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
        let scaledImage = cropped.transformed(by: scaleTransform)
        ciContext.render(scaledImage, to: resizedPixelBuffer_res)
        
        var classLabel: String?
        var confidence: Double?
        
        // resnetに入力
        if let pred = try? resnet.predict(image: resizedPixelBuffer_res) {
            // predicted label
            classLabel = pred[0].predClass
            confidence = pred[0].classConfidence[pred[0].predClass]
        } else {
            classLabel = "error"
            confidence = 0.0
        }
        
        guard let label: String = classLabel, let conf: Double = confidence else {
            return ("", 0.0)
        }
        return (label, conf)
    }
    
    func pushAlert(_ label: String) {
        var norimono: String!
        for (key, value) in self.userInfo {
            if value {
                norimono = key
            }
        }
        
        if label == "traffic_sign" && norimono != "walk" {
            // view
            let alertView = UIView()
            alertView.frame = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height)
            alertView.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
            alertView.layer.shadowOpacity = 0.5
            self.view.addSubview(alertView)
            
            // text
            let alertLabel = UILabel()
            alertLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.width/2+20, width: UIScreen.main.bounds.size.width, height: 100)
            alertLabel.text = "STOP"
            alertLabel.font = UIFont(name: "HiraKakuProN-W6", size: 60)
            alertLabel.textAlignment = .center
            alertLabel.textColor = .white
            self.view.addSubview(alertLabel)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                alertView.removeFromSuperview()
                alertLabel.removeFromSuperview()
            }
        } else if norimono == "walk" {
            // view
            let alertView = UIView()
            alertView.frame = CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.size.width, height:  UIScreen.main.bounds.size.height)
            alertView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.1)
            alertView.layer.shadowOpacity = 0.5
            self.view.addSubview(alertView)
            
            // text
            let alertLabel = UILabel()
            alertLabel.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.width/2+20, width: UIScreen.main.bounds.size.width, height: 100)
            alertLabel.text = "PASS"
            alertLabel.font = UIFont(name: "HiraKakuProN-W6", size: 60)
            alertLabel.textAlignment = .center
            alertLabel.textColor = .white
            self.view.addSubview(alertLabel)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                alertView.removeFromSuperview()
                alertLabel.removeFromSuperview()
            }
        } else {
            // 追加したUI部品の削除
            
        }
    }
    
//    func alertType(type: String) {
//
//    }
}

extension ObjectDetectionViewController: VideoCaptureDelegate {
    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?, timestamp: CMTime) {
        semaphore.wait()
        
        if let pixelBuffer = pixelBuffer {
            DispatchQueue.global().async {
                self.predict(pixelBuffer: pixelBuffer)
            }
        }
    }
}
