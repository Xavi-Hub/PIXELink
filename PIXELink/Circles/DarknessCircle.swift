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
    
    
    override func draw(_ rect: CGRect) {
        
        let circleInset: CGFloat = 10
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width/2, y: frame.height/2), radius: min(frame.width, frame.height)/2-circleInset, startAngle: -.pi/2, endAngle: 3*(.pi)/2, clockwise: true)
        
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = 5
        
        if shapeLayer.superlayer == nil {
            layer.addSublayer(shapeLayer)
        }
        
        
    }

}
