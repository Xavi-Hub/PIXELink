//
//  Extensions.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 6/29/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class WidthGestureRecognizer: UIPinchGestureRecognizer {
    
    var pinchContent: PinchContentDelegate!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if touches.count == 2 {
            pinchContent.onGestureUpdate(recognizer: self)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if touches.count == 2 {
            pinchContent.onGestureUpdate(recognizer: self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        pinchContent.onGestureEnd()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        pinchContent.onGestureEnd()
    }
    
}

class ContinousGestureRecognizer: UIGestureRecognizer {

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .possible {
            guard touches.count == 1 else {return}
            if location(ofTouch: 0, in: view!).x >= 0 &&
               location(ofTouch: 0, in: view!).x <=  view!.frame.width &&
               location(ofTouch: 0, in: view!).y >= 0 &&
               location(ofTouch: 0, in: view!).y <= view!.frame.height {
                self.state = .began
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        self.state = .changed
    }
}


extension UIColor {
    convenience init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat = 1)  {
        let offset = saturation * (lightness < 0.5 ? lightness : 1 - lightness)
        let brightness = lightness + offset
        let saturation = lightness > 0 ? 2 * offset / brightness : 0
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    var hsl: (hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0, hue: CGFloat = 0
        guard
            getRed(&red, green: &green, blue: &blue, alpha: &alpha),
            getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
            else { return nil }
        let upper = max(red, green, blue)
        let lower = min(red, green, blue)
        let range = upper - lower
        let lightness = (upper + lower) / 2
        let saturation = range == 0 ? 0 : range / (lightness < 0.5 ? lightness * 2 : 2 - lightness * 2)
        return (hue, saturation, lightness, alpha)
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [kCIContextWorkingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}


public struct RGBAPixel {
    public var raw: UInt32
    public var red: UInt8 {
        get {return UInt8(raw & 0xFF)}
        set { raw = UInt32(newValue) | (raw & 0xFFFFFF00)}
    }
    public var green: UInt8 {
        get {return UInt8((raw & 0xFF00) >> 8)}
        set { raw = (UInt32(newValue) << 8) | (raw & 0xFFFF00FF)}
    }
    public var blue: UInt8 {
        get {return UInt8((raw & 0xFF0000) >> 16)}
        set { raw = (UInt32(newValue) << 16) | (raw & 0xFF00FFFF)}
    }
    public var alpha: UInt8 {
        get {return UInt8((raw & 0xFF000000) >> 24)}
        set { raw = (UInt32(newValue) << 24) | (raw & 0x00FFFFFF)}
    }
}


