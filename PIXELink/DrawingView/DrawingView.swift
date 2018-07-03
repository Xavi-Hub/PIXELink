//
//  DrawingView.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 6/29/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit

protocol PinchContentDelegate {
    func onGestureEnd()
    func onGestureUpdate(recognizer: WidthGestureRecognizer)
}

class DrawingView: UIView, PinchContentDelegate {
    
    var currentColor = UIColor.red.cgColor
    var minWidth: CGFloat {
        get {
            return frame.width/25
        }
        set {}
    }
    var currentWidth: CGFloat = 20
    var path: UIBezierPath!
    var startingPoint: CGPoint!
    var touchPoint: CGPoint!
    var currentTouch: UITouch?
    var addedLayers: [[CAShapeLayer]] = [[]]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard event?.touches(for: self)?.count == 1 else {return}
        if touches.count == 1 {
            if let first = touches.first {
                startingPoint = first.location(in: self)
                currentTouch = first
                addedLayers.append([])
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard event?.touches(for: self)?.count == 1 else {return}
        if touches.count == 1 {
            if let first = touches.first {
                guard first == currentTouch else {return}
                touchPoint = first.location(in: self)
                
                path = UIBezierPath()
                path.move(to: startingPoint)
                path.addLine(to: touchPoint)
                startingPoint = touchPoint
                drawShapeLayer()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchesMoved(touches, with: event)
    }
    
    func onGestureEnd() {
        if let contains = layer.sublayers?.contains(shapeLayer1) {
            if contains {
                layer.sublayers?.remove(at: layer.sublayers!.index(of: shapeLayer1)!)
            }
        }
        setNeedsDisplay()
    }
    
    func onGestureUpdate(recognizer: WidthGestureRecognizer) {
        currentWidth = currentWidth * recognizer.scale
        recognizer.scale = 1.0
        if currentWidth < minWidth {currentWidth = minWidth}
        showWidthCircle(width: currentWidth)
    }
    
    let shapeLayer1 = CAShapeLayer()
    
    func showWidthCircle(width: CGFloat) {
        if let contains = layer.sublayers?.contains(shapeLayer1) {
            if contains {
                layer.sublayers?.remove(at: layer.sublayers!.index(of: shapeLayer1)!)
            }
        }
        shapeLayer1.fillColor = currentColor
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.midX, y: frame.midY), radius: currentWidth/2, startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        shapeLayer1.path = circlePath.cgPath
        shapeLayer1.strokeColor = UIColor.black.cgColor
        shapeLayer1.lineWidth = 1.5
        layer.addSublayer(shapeLayer1)
        setNeedsDisplay()
        
    }

    
    
    func setupViews() {
        layer.cornerRadius = 25
        layer.masksToBounds = true
        backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        isMultipleTouchEnabled = true
        
    }
    
    func changeCurrentColor(newColor: UIColor) {
        currentColor = newColor.cgColor
        layer.borderColor = newColor.cgColor
    }
    
    func undo() {
        if let lastGroup = addedLayers.last {
            for layer in lastGroup {
                layer.removeFromSuperlayer()
                setNeedsDisplay()
            }
            let _ = addedLayers.popLast()
        }
    }
    
    func clear() {
        for layerGroup in addedLayers {
            for layer in layerGroup {
                layer.removeFromSuperlayer()
            }
        }
        setNeedsDisplay()
    }
    
    func drawShapeLayer() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineCap = kCALineCapRound
        shapeLayer.strokeColor = currentColor
        shapeLayer.lineWidth = currentWidth < minWidth ? minWidth : currentWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(shapeLayer)
        addedLayers[addedLayers.count-1].append(shapeLayer)
        setNeedsDisplay()
    }
    
    
    func saveImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: CGRect(x: 15, y: 15, width: frame.width-30, height: frame.height-30))
        let image = renderer.image { (context) in
            return layer.render(in: context.cgContext)
        }
        return image
    }
    
    
    
    
    
    

}
