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
    var currentColor = UIColor.red.cgColor
    var imageViewHeightAnchor = NSLayoutConstraint()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "hue upright")
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        return iv
    }()
    let lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    var lineViewYConstraint = NSLayoutConstraint()
    
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
        
        imageView.isHidden = true
        
        addSubview(squareView)
        squareView.addSubview(imageView)
        imageView.addSubview(lineView)
        
        squareView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        
        squareView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        squareView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        let lessThanWidth = squareView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor)
        let lessThanHeight = squareView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor)
        lessThanWidth.priority = UILayoutPriority.required
        lessThanHeight.priority = UILayoutPriority.required
        let aspectHeight = squareView.heightAnchor.constraint(equalTo: squareView.widthAnchor)
        let aspectWidth = squareView.widthAnchor.constraint(equalTo: squareView.heightAnchor)
        aspectHeight.priority = UILayoutPriority.defaultHigh
        aspectWidth.priority = UILayoutPriority.defaultHigh
        let maxWidth = squareView.widthAnchor.constraint(equalTo: widthAnchor, constant: -circleInset)
        let maxHeight = squareView.heightAnchor.constraint(equalTo: heightAnchor, constant: -circleInset)
        maxWidth.priority = UILayoutPriority.defaultLow
        maxHeight.priority = UILayoutPriority.defaultLow
        
        lessThanWidth.isActive = true
        lessThanHeight.isActive = true
        aspectWidth.isActive = true
        aspectHeight.isActive = true
        maxWidth.isActive = true
        maxHeight.isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: squareView.topAnchor).isActive = true
        imageViewHeightAnchor = imageView.heightAnchor.constraint(equalToConstant: 300)
        imageViewHeightAnchor.isActive = true
        imageView.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        lineView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        lineView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 4).isActive = true
        lineViewYConstraint = lineView.centerYAnchor.constraint(equalTo: imageView.bottomAnchor)
        lineViewYConstraint.isActive = true
        
    }
    
    @objc func handleUpdate(recognizer: ContinousGestureRecognizer) {
        if recognizer.state == .began {
            imageView.isHidden = false
            imageViewHeightAnchor.constant = 0
            layoutIfNeeded()
            imageViewHeightAnchor.constant = 300
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        } else if recognizer.state == .ended {
            layoutIfNeeded()
            imageViewHeightAnchor.constant = 0
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        } else {
            guard recognizer.numberOfTouches != 0 else {return}
            let y = recognizer.location(ofTouch: recognizer.numberOfTouches-1, in: self.imageView).y
            guard self.imageView.frame.height != 0 else {return}
            var percent = y/self.imageView.frame.height
            if percent > 1 {percent = 1}
            if percent < 0 {percent = 0}
            self.receiver.handleColorUpdate(percent: percent)
            lineViewYConstraint.isActive = false
            lineViewYConstraint = lineView.centerYAnchor.constraint(equalTo: imageView.topAnchor, constant: percent*imageView.frame.height)
            lineViewYConstraint.isActive = true
            layoutIfNeeded()
            currentColor = UIColor(hue: percent, saturation: 1, lightness: 0.5).cgColor
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: squareView.bounds.midX, y: squareView.bounds.midY), radius: squareView.frame.width/2-circleInset, startAngle: -.pi/2, endAngle: 3*(.pi)/2, clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = currentColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5
        
        if shapeLayer.superlayer == nil {
            squareView.layer.addSublayer(shapeLayer)
        }
        
        
    }

}
