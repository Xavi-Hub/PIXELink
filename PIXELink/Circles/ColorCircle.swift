//
//  ColorCircle.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 7/8/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit

class ColorCircle: UIView {

    let shapeLayer = CAShapeLayer()
    let recognizer = ContinousGestureRecognizer()
    var receiver: ColorInfoReceiver!
    let circleInset: CGFloat = 10
    let circlePath = UIBezierPath()
    let squareView = UIView()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "hue upright")
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        recognizer.addTarget(self, action: #selector(handleUpdate(recognizer:)))
        
        addGestureRecognizer(recognizer)
        
        setupViews()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        
        addSubview(squareView)
        squareView.addSubview(imageView)
        
        squareView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        squareView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        squareView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        squareView.widthAnchor.constraint(equalTo: widthAnchor, constant: -circleInset).isActive = true
        squareView.heightAnchor.constraint(equalTo: squareView.widthAnchor).isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: squareView.bottomAnchor, constant: -circleInset).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
    }
    
    @objc func handleUpdate(recognizer: ContinousGestureRecognizer) {
        if recognizer.state == .began {
            
        } else {
            guard recognizer.numberOfTouches != 0 else {return}
            var y = recognizer.location(ofTouch: recognizer.numberOfTouches-1, in: self).y
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: squareView.bounds.midX, y: squareView.bounds.midY), radius: squareView.frame.width/2-circleInset, startAngle: -.pi/2, endAngle: 3*(.pi)/2, clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5
        
        if shapeLayer.superlayer == nil {
            squareView.layer.addSublayer(shapeLayer)
        }
        
        
    }

}
