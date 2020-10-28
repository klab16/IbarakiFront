import Foundation
import UIKit

class BoundingBox {
    let shapeLayer: CAShapeLayer
    let textLayer: CATextLayer
    var center: Bool = false
    
    init() {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.isHidden = true
        
        textLayer = CATextLayer()
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 14
        textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
    }
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        parent.addSublayer(textLayer)
    }
    
    func show(frame: CGRect, label: String, score: Double, color: UIColor, mode:String) {
        
        // モード設定
        if mode == "translation" {
            center = true
        } else if mode == "assist" {
            center = false
        }
        
        CATransaction.setDisableActions(true)
        
        let path = UIBezierPath(rect: frame)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        
        //    textLayer.string = label
        
        textLayer.isHidden = false
        
        var textOrigin: CGPoint
        var textSize: CGSize
        
        if center {
            // 中央表示モード（翻訳を想定）
//            guard let classLabel = NSLocalizedString(label, comment: "") else {
//                return
//            }
            let classLabel = NSLocalizedString(label, comment: "")
            let text = String(format: "%@", classLabel)
            textLayer.string = text
            textLayer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5).cgColor
            textLayer.fontSize = 28
            textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
            let attributes = [
                NSAttributedString.Key.font: textLayer.font as Any
            ]
            let textRect = text.boundingRect(with: CGSize(width: 400, height: 100), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)
            textSize = CGSize(width: textRect.width + 12, height: textRect.height)
            let centerX = frame.origin.x + frame.size.width / 2 - textRect.width / 2
            let centerY = frame.origin.y + frame.size.height / 2 - textRect.height / 2
            textOrigin = CGPoint(x: centerX, y: centerY)
        } else {
            // 従来の表示
            let label = String(format: "%@ %.1f", label, score * 100)
            textLayer.string = label
            textLayer.backgroundColor = color.cgColor
            textLayer.fontSize = 14
            textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)
            let attributes = [
                NSAttributedString.Key.font: textLayer.font as Any
            ]
            let textRect = label.boundingRect(with: CGSize(width: 400, height: 100),
                                              options: .truncatesLastVisibleLine,
                                              attributes: attributes, context: nil)
            textSize = CGSize(width: textRect.width + 12, height: textRect.height)
            textOrigin = CGPoint(x: frame.origin.x - 2, y: frame.origin.y - textSize.height)
        }
        
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
    }
    
    func hide() {
        shapeLayer.isHidden = true
        textLayer.isHidden = true
    }
}
