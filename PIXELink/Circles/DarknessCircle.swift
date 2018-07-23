//
//  DarknessCircle.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 7/8/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit

class DarknessCircle: UIView {

    let shapeLayer = CAShapeLayer()
    let recognizer = ContinousGestureRecognizer()
    var receiver: SizeInfoReceiver!
    let circleInset: CGFloat = 10
    let circlePath = UIBezierPath()
    let squareView = UIView()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 50
        iv.layer.masksToBounds = true
        return iv
    }()
    let darknessLabel: UILabel = {
        let label = UILabel()
        label.text = "Darkness"
        label.textColor = .white
        return label
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
        addSubview(darknessLabel)
        squareView.addSubview(imageView)
        
        squareView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        darknessLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        imageView.bottomAnchor.constraint(equalTo: squareView.bottomAnchor, constant: -circleInset).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        darknessLabel.topAnchor.constraint(equalTo: squareView.bottomAnchor).isActive = true
        darknessLabel.centerXAnchor.constraint(equalTo: squareView.centerXAnchor).isActive = true
        
    }
    
    @objc func handleUpdate(recognizer: ContinousGestureRecognizer) {
        
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
