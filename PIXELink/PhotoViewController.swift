//
//  PhotoViewController.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 6/26/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit
import CoreImage
import CoreData
import Photos

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

class PhotoViewController: UIViewController {
    
    var dataArray = [Photo]()
    var imageArray = [UIImage]()
    
    var redSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 255
        slider.isContinuous = true
        slider.value = 254/2
        slider.tintColor = .red
        return slider
    }()
    var greenSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 255
        slider.isContinuous = true
        slider.value = 254/2
        slider.tintColor = .green
        return slider
    }()
    var blueSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 255
        slider.isContinuous = true
        slider.value = 254/2
        slider.tintColor = .blue
        return slider
    }()
    var updateButton: UIButton = {
        let button = UIButton()
        button.setTitle("Find Photo", for: .normal)
        return button
    }()
    var imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sampleImage = UIImage(named: "copper")
        imageView.image = sampleImage
        imageView.contentMode = .scaleAspectFit
        
        setupViews()
        
        grabPhotos()
        
//        let height = Int((sampleImage?.size.height)!)
//        let width = Int((sampleImage?.size.width)!)
//
//        let bitsPerComponent = Int(8)
//        let bytesPerRow = 4 * width
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
//        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
//        let CGPointZero = CGPoint(x: 0, y: 0)
//        let rect = CGRect(origin: CGPointZero, size: (sampleImage?.size)!)
//
//
//
//        let imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
//
//        imageContext?.draw(sampleImage!.cgImage!, in: rect)
//
//        let pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func setupViews() {
        view.addSubview(redSlider)
        view.addSubview(greenSlider)
        view.addSubview(blueSlider)
        view.addSubview(updateButton)
        view.addSubview(imageView)
        redSlider.translatesAutoresizingMaskIntoConstraints = false
        greenSlider.translatesAutoresizingMaskIntoConstraints = false
        blueSlider.translatesAutoresizingMaskIntoConstraints = false
        updateButton.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        redSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        greenSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        blueSlider.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        updateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        redSlider.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        greenSlider.topAnchor.constraint(equalTo: redSlider.bottomAnchor, constant: 10).isActive = true
        blueSlider.topAnchor.constraint(equalTo: greenSlider.bottomAnchor, constant: 10).isActive = true
        updateButton.topAnchor.constraint(equalTo: blueSlider.bottomAnchor, constant: 10).isActive = true
        redSlider.widthAnchor.constraint(equalToConstant: 300).isActive = true
        greenSlider.widthAnchor.constraint(equalToConstant: 300).isActive = true
        blueSlider.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 10).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        redSlider.addTarget(self, action: #selector(handleChangeColor), for: .valueChanged)
        greenSlider.addTarget(self, action: #selector(handleChangeColor), for: .valueChanged)
        blueSlider.addTarget(self, action: #selector(handleChangeColor), for: .valueChanged)
        updateButton.addTarget(self, action: #selector(updateBestPhoto), for: .touchUpInside)
        
    }

    @objc func handleChangeColor() {
        let red = redSlider.value
        let green = greenSlider.value
        let blue = blueSlider.value
        guard red <= 255 && green <= 255 && blue <= 255 else {return}
        view.backgroundColor = UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }
    
    let imgManager=PHImageManager.default()
    
    func grabPhotos(){
        imageArray = []
        
        DispatchQueue.global(qos: .background).async {
            
            let photoRequestOptions=PHImageRequestOptions()
            photoRequestOptions.isSynchronous=true
            photoRequestOptions.deliveryMode = .highQualityFormat
            
            let photoFetchOptions=PHFetchOptions()
            photoFetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let photoFetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: photoFetchOptions)
            
            let dataFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
            let dataFetchSortDescriptor = NSSortDescriptor(key: "localIdentifier", ascending: true)
            dataFetchRequest.sortDescriptors = [dataFetchSortDescriptor]
            do {
                let dataFetchResult = try PersistenceService.context.fetch(dataFetchRequest)
                self.dataArray = dataFetchResult
            } catch let error {
                print(error)
            }
            var identifiers = [String]()
            for photo in self.dataArray {
                identifiers.append(photo.localIdentifier!)
            }
            if photoFetchResult.count > 0 {
                for i in 0..<photoFetchResult.count{
                    let identifier = photoFetchResult[i].localIdentifier
                    if !identifiers.contains(identifier) {
                        self.imgManager.requestImage(for: photoFetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: photoRequestOptions, resultHandler: { (image, error) in
                            self.savePhotoData(newPhoto: image!, localIdentifier: identifier)
                        })
                    }
                }
            } else {
                print("You got no photos.")
            }
            
            DispatchQueue.main.async {
                self.updateBestPhoto()
            }
        }
    }
    
    var newPhotoCount = 0
    func savePhotoData(newPhoto: UIImage, localIdentifier: String) {
        print("Processing new image: \(newPhotoCount)")
        newPhotoCount += 1
        let newData = Photo(context: PersistenceService.context)
        newData.localIdentifier = localIdentifier
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let color = newPhoto.averageColor!
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        newData.red = Float(red)
        newData.green = Float(green)
        newData.blue = Float(blue)
        PersistenceService.saveContext()
        dataArray.append(newData)
    }
    
    func colorDifference(color: UIColor, photo: Photo) -> Float {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let pRed = CGFloat(photo.red)
        let pGreen = CGFloat(photo.green)
        let pBlue = CGFloat(photo.blue)
        let redDiff = abs(red-pRed)
        let greenDiff = abs(green-pGreen)
        let blueDiff = abs(blue-pBlue)
        let absDifference = Float(redDiff + greenDiff + blueDiff)
        return absDifference
    }
    
    func findBestPhoto() -> UIImage {
        guard let targetColor = view.backgroundColor else {
            print("No target color")
            return UIImage()
        }
        if dataArray.count == 0 {return UIImage()}
        var bestData = dataArray[0]
        var bestDifference = colorDifference(color: targetColor, photo: bestData)
        for photo in dataArray {
            let currentDifference = colorDifference(color: targetColor, photo: photo)
            if currentDifference < bestDifference {
                bestDifference = currentDifference
                bestData = photo
            }
        }
        var bestPhoto = UIImage()
        let photoRequestOptions=PHImageRequestOptions()
        photoRequestOptions.isSynchronous=true
        photoRequestOptions.deliveryMode = .highQualityFormat
        let asset = PHAsset.fetchAssets(withLocalIdentifiers: [bestData.localIdentifier!], options: .none)
        imgManager.requestImage(for: asset[0], targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: photoRequestOptions, resultHandler: { (image, error) in
            bestPhoto = image!
        })
        return bestPhoto
    }
    
    @objc func updateBestPhoto() {
        let bestPhoto = findBestPhoto()
        imageView.image = bestPhoto
    }

}
