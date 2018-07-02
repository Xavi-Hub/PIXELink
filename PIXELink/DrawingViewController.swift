//
//  NavigationController.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 6/29/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit
import CoreImage
import CoreData
import Photos


class DrawingViewController: UIViewController {

    var dataArray = [Photo]()
    var imageArray = [UIImage]()
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    var drawingView: DrawingView = {
        let dv = DrawingView()
        dv.layer.borderWidth = 5
        dv.layer.borderColor = UIColor(hue: 0, saturation: 1, lightness: 0.5).cgColor
        return dv
    }()
    
    var blackWhiteGradientMask: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor.clear
        view.image = UIImage(named: "BlackWhiteGradient")
        view.contentMode = .scaleToFill
        return view
    }()
    
    var hueImageView: UIImageView = {
        let iv = UIImageView()
        let image = UIImage(named: "hue")
        iv.image = image
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 7
        iv.layer.masksToBounds = true
        return iv
    }()
    
    var blackWhiteImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "BlackWhite")
        iv.contentMode = .scaleToFill
        iv.layer.cornerRadius = 7
        iv.layer.masksToBounds = true
        return iv
    }()
    
    let hueRecognizer = ContinousGestureRecognizer()
    let grayRecognizer = ContinousGestureRecognizer()
    let pinchRecognizer = WidthGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()

        grabPhotos()
        
        hueRecognizer.addTarget(self, action: #selector(handleSliderUpdate(sender:)))
        grayRecognizer.addTarget(self, action: #selector(handleGrayUpdate(sender:)))
        pinchRecognizer.pinchContent = drawingView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupViews() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor(white: 0.2, alpha: 1)
        view.backgroundColor = UIColor(white: 0.3, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(handleUndo(sender:)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(handleClear(sender:)))
        
        let containerView1 = UIView()
        let containerView2 = UIView()
        let colorStackView = UIStackView(arrangedSubviews: [containerView1, containerView2])
        colorStackView.axis = .vertical
        colorStackView.distribution = .fillEqually
        
        view.addSubview(colorStackView)
        view.addSubview(drawingView)
        containerView1.addSubview(hueImageView)
        containerView2.addSubview(blackWhiteImageView)
        blackWhiteGradientMask.transform = blackWhiteGradientMask.transform.rotated(by: .pi/2)
        hueImageView.addSubview(blackWhiteGradientMask)
        
        hueImageView.addGestureRecognizer(hueRecognizer)
        hueImageView.isUserInteractionEnabled = true
        
        drawingView.addGestureRecognizer(pinchRecognizer)
        
        blackWhiteImageView.addGestureRecognizer(grayRecognizer)
        blackWhiteImageView.isUserInteractionEnabled = true

        colorStackView.translatesAutoresizingMaskIntoConstraints = false
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        hueImageView.translatesAutoresizingMaskIntoConstraints = false
        blackWhiteGradientMask.translatesAutoresizingMaskIntoConstraints = false
        blackWhiteImageView.translatesAutoresizingMaskIntoConstraints = false
        
        blackWhiteGradientMask.centerXAnchor.constraint(equalTo: hueImageView.centerXAnchor).isActive = true
        blackWhiteGradientMask.centerYAnchor.constraint(equalTo: hueImageView.centerYAnchor).isActive = true
        blackWhiteGradientMask.widthAnchor.constraint(equalTo: hueImageView.heightAnchor).isActive = true
        blackWhiteGradientMask.heightAnchor.constraint(equalTo: hueImageView.widthAnchor).isActive = true
        
        portraitConstraints.append(drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20))
        portraitConstraints.append(drawingView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -10))
        portraitConstraints.append(drawingView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        portraitConstraints.append(drawingView.heightAnchor.constraint(equalTo: drawingView.widthAnchor))
        
        portraitConstraints.append(colorStackView.topAnchor.constraint(equalTo: drawingView.bottomAnchor))
        portraitConstraints.append(colorStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        portraitConstraints.append(colorStackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor))
        portraitConstraints.append(colorStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor))

        portraitConstraints.append(hueImageView.centerXAnchor.constraint(equalTo: containerView1.centerXAnchor))
        portraitConstraints.append(hueImageView.centerYAnchor.constraint(equalTo: containerView1.centerYAnchor))
        portraitConstraints.append(hueImageView.widthAnchor.constraint(equalTo: containerView1.widthAnchor, constant: -50))
        portraitConstraints.append(hueImageView.heightAnchor.constraint(equalTo: containerView1.heightAnchor, multiplier: 0.9))


        portraitConstraints.append(blackWhiteImageView.centerXAnchor.constraint(equalTo: containerView2.centerXAnchor))
        portraitConstraints.append(blackWhiteImageView.centerYAnchor.constraint(equalTo: containerView2.centerYAnchor))
        portraitConstraints.append(blackWhiteImageView.widthAnchor.constraint(equalTo: containerView2.widthAnchor, constant: -50))
        portraitConstraints.append(blackWhiteImageView.heightAnchor.constraint(equalTo: containerView2.heightAnchor, multiplier: 0.9))

        
        landscapeConstraints.append(drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5))
        landscapeConstraints.append(drawingView.widthAnchor.constraint(equalTo: drawingView.heightAnchor, constant: -10))
        landscapeConstraints.append(drawingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5))
        landscapeConstraints.append(drawingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5))

        landscapeConstraints.append(colorStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        landscapeConstraints.append(colorStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        landscapeConstraints.append(colorStackView.leftAnchor.constraint(equalTo: drawingView.rightAnchor))
        landscapeConstraints.append(colorStackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor))

        landscapeConstraints.append(hueImageView.centerXAnchor.constraint(equalTo: containerView1.centerXAnchor))
        landscapeConstraints.append(hueImageView.centerYAnchor.constraint(equalTo: containerView1.centerYAnchor))
        landscapeConstraints.append(hueImageView.widthAnchor.constraint(equalTo: containerView1.widthAnchor, multiplier: 0.9))
        landscapeConstraints.append(hueImageView.heightAnchor.constraint(equalTo: containerView1.heightAnchor, multiplier: 0.9))
        
        landscapeConstraints.append(blackWhiteImageView.centerXAnchor.constraint(equalTo: containerView2.centerXAnchor))
        landscapeConstraints.append(blackWhiteImageView.centerYAnchor.constraint(equalTo: containerView2.centerYAnchor))
        landscapeConstraints.append(blackWhiteImageView.widthAnchor.constraint(equalTo: containerView2.widthAnchor, multiplier: 0.9))
        landscapeConstraints.append(blackWhiteImageView.heightAnchor.constraint(equalTo: containerView2.heightAnchor, multiplier: 0.9))
        
        updateConstraints()
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.updateConstraints()
        }
    }
    
    func updateConstraints() {
        if UIDevice.current.orientation.isPortrait {
            hueImageView.image = UIImage(named: "hue")
            blackWhiteImageView.image = UIImage(named: "BlackWhite")
            blackWhiteGradientMask.image = UIImage(named: "BlackWhiteGradient")
            for constraint in self.landscapeConstraints {
                constraint.isActive = false
            }
            for constraint in self.portraitConstraints {
                constraint.isActive = true
            }
        }
        if UIDevice.current.orientation.isLandscape {
//            hueImageView.image = UIImage(named: "hue upright")
//            blackWhiteImageView.image = UIImage(named: "BlackWhiteUpright")
//            blackWhiteGradientMask.image = UIImage(named: "BlackWhiteGradientUpright")
            for constraint in self.portraitConstraints {
                constraint.isActive = false
            }
            for constraint in self.landscapeConstraints {
                constraint.isActive = true
            }
        }
    }
    
    @objc func handleUndo(sender: Any?) {
        drawingView.undo()
    }
    
    @objc func handleClear(sender: Any?) {
        drawingView.clear()
    }
    
    @objc func handleSaveImage(sender: Any?) {
        let imageView = UIImageView()
        var newImage = drawingView.saveImage()
        newImage = resizeImage(image: newImage, targetSize: CGSize(width: 32, height: 32))
        imageView.image = newImage
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
        view.addSubview(imageView)
    }
    
    @objc func handleSliderUpdate(sender: Any?) {
        if let recognizer = sender as? ContinousGestureRecognizer {
            guard recognizer.numberOfTouches != 0 else {return}
            var xPercent = recognizer.location(ofTouch: recognizer.numberOfTouches-1, in: hueImageView).x/hueImageView.frame.width
            if xPercent < 0 {xPercent = 0}
            if xPercent > 1 {xPercent = 1}
            var yPercent = recognizer.location(ofTouch: recognizer.numberOfTouches-1, in: hueImageView).y/hueImageView.frame.height
            if yPercent < 0 {yPercent = 0}
            if yPercent > 1 {yPercent = 1}
            updateBackgroundColor(xPercent: xPercent, yPercent: yPercent)
        }
    }
    
    func updateBackgroundColor(xPercent: CGFloat, yPercent: CGFloat) {
        let newColor = UIColor(hue: xPercent, saturation: 1, lightness: yPercent)
        drawingView.changeCurrentColor(newColor: newColor)
    }
    
    @objc func handleGrayUpdate(sender: Any?) {
        if let recognizer = sender as? ContinousGestureRecognizer {
            guard recognizer.numberOfTouches != 0 else {return}
            var xPercent = recognizer.location(ofTouch: recognizer.numberOfTouches-1, in: blackWhiteImageView).x/blackWhiteImageView.frame.width
            if xPercent < 0 {xPercent = 0}
            if xPercent > 1 {xPercent = 1}
            updateBackgroundGray(percent: xPercent)
        }
    }
    
    func updateBackgroundGray(percent: CGFloat) {
        let newGray = UIColor(white: percent, alpha: 1)
        drawingView.changeCurrentColor(newColor: newGray)
    }
    
    let imgManager=PHImageManager.default()
    
    func grabPhotos() {
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
                
            }
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
    var newPhotoCount = 0
    func savePhotoData(newPhoto: UIImage, localIdentifier: String) {
        print("Processing new image: \(newPhotoCount)")
        newPhotoCount += 1
        let newData = Photo(context: PersistenceService.context)
        newData.localIdentifier = localIdentifier
        let resizedPhoto = resizeImage(image: newPhoto, targetSize: CGSize(width: 32, height: 32))
        
        let height = Int(resizedPhoto.size.height)
        let width = Int(resizedPhoto.size.width)
        
        let bitsPerComponent = Int(8)
        let bytesPerRow = 4 * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let CGPointZero = CGPoint(x: 0, y: 0)
        let rect = CGRect(origin: CGPointZero, size: resizedPhoto.size)
        
        let imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        imageContext?.draw(resizedPhoto.cgImage!, in: rect)
        
        //        let pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)
        
        let dataToStore = NSData(bytes: rawData, length: width * height)
        newData.photoData = dataToStore
        
        PersistenceService.saveContext()
        dataArray.append(newData)
    }
    
    func colorDifference(dPhoto: UIColor, photo: Photo) -> Float {
        
        return 0
    }
    
    func findBestPhoto() -> UIImage {
        let bestData = dataArray[0]
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
    

}
