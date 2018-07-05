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
import CoreGraphics

class DrawingViewController: UIViewController {

    var dataArray = [Photo]()
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    var drawingView: DrawingView = {
        let dv = DrawingView()
        dv.layer.borderWidth = 5
        dv.layer.borderColor = UIColor(hue: 0, saturation: 1, lightness: 0.5).cgColor
        return dv
    }()
    var isProcessingPhotos = false
    
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
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(handleUndo(sender:))), UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(search))]
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
        landscapeConstraints.append(drawingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 5))
        landscapeConstraints.append(drawingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5))
        landscapeConstraints.append(drawingView.widthAnchor.constraint(equalTo: drawingView.heightAnchor))

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
        // Before the rotation begins
        for constraint in self.landscapeConstraints {
            constraint.isActive = false
        }
        for constraint in self.portraitConstraints {
            constraint.isActive = false
        }

        coordinator.animate(alongsideTransition: { (context) in
            DispatchQueue.main.async {
                self.updateConstraints()
            }
        }) { (context) in
            // After the rotation is finished
        }
    }
    
    
    
    func updateConstraints() {
        if UIDevice.current.orientation.isPortrait {
            for constraint in self.landscapeConstraints {
                constraint.isActive = false
            }
            for constraint in self.portraitConstraints {
                constraint.isActive = true
            }
        }
        if UIDevice.current.orientation.isLandscape {
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
    
    
    
    func getDrawnPhoto(sender: Any?) -> NSData {
        let drawnPhoto = drawingView.saveImage()
        return getPhotoData(image: drawnPhoto)
    }
    
    @objc func search() {
        let photo = getDrawnPhoto(sender: nil)
        let photosCollectionViewController = PhotosCollectionViewController(photo: photo, dataArray: dataArray)
        navigationController?.pushViewController(photosCollectionViewController, animated: true)
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
    
    @objc func updateBackgroundGray(percent: CGFloat) {
        let newGray = UIColor(white: percent, alpha: 1)
        drawingView.changeCurrentColor(newColor: newGray)
    }
    
    
    func grabPhotos() {
        isProcessingPhotos = true
        DispatchQueue.global(qos: .background).async {[unowned self] in
            
            let imgManager=PHImageManager.default()

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
                // Fetching 32x32 data stored for photos
                let dataFetchResult = try PersistenceService.context.fetch(dataFetchRequest)
                self.dataArray = dataFetchResult
            } catch let error {
                print(error)
            }
            
            // Checking for newly added photos and processing them
            var identifiers = [String]()
            for photo in self.dataArray {
                identifiers.append(photo.localIdentifier!)
            }
            if photoFetchResult.count > 0 {
                for i in 0..<photoFetchResult.count{
                    autoreleasepool {
                        let identifier = photoFetchResult[i].localIdentifier
                        if !identifiers.contains(identifier) {
                            imgManager.requestImage(for: photoFetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: photoRequestOptions, resultHandler: {[unowned self] (image, error) in
                                self.savePhotoData(newPhoto: image!, localIdentifier: identifier)
                            })
                        }
                    }
                }
            } else {
                print("No photos found.")
            }
        }
        isProcessingPhotos = false
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    // Resizes photo and returns a data object of RBGA Pixels
    func getPhotoData(image: UIImage) -> NSData {
        
//        let resizedPhoto = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
//        let height = Int(resizedPhoto.size.height)
//        let width = Int(resizedPhoto.size.width)
//
//        let bitsPerComponent = Int(8)
//        let bytesPerRow = 4 * width
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
//        let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
//        let CGPointZero = CGPoint(x: 0, y: 0)
//        let rect = CGRect(origin: CGPointZero, size: resizedPhoto.size)
//
//        weak var imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
//
//        imageContext?.draw(resizedPhoto.cgImage!, in: rect)

        let resizedPhoto = resizeImage(image: image, targetSize: CGSize(width: 32, height: 32))
        guard let cgImage = resizedPhoto.cgImage else { return NSData() } // 1
        
        let width = Int(resizedPhoto.size.width)
        let height = Int(resizedPhoto.size.height)
        let bitsPerComponent = 8 // 2
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let imageData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB() // 3
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else { return NSData() }
        imageContext.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: resizedPhoto.size))
        
        let pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: imageData, count: width * height)
        
//        let newContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil)
//        addAndSetupImageView(withImage: UIImage(cgImage: (newContext?.makeImage()!)!))
        
//        let dataObject = NSData(bytes: imageData, length: width * height)
        
        let dataObject = Data.init(buffer: pixels) as NSData
        
        return dataObject
    }
    
    func addAndSetupImageView(withImage image: UIImage) {
        DispatchQueue.main.async {
            let imageView = UIImageView(image: image)
            self.view.addSubview(imageView)
            imageView.frame = CGRect(x: 50, y: 50, width: 200, height: 200)
            imageView.contentMode = .scaleToFill
        }
    }
    
    var newPhotoCount = 0
    
    func savePhotoData(newPhoto: UIImage, localIdentifier: String) {
        print("Processing new image: \(newPhotoCount)")
        newPhotoCount += 1
        let newData = Photo(context: PersistenceService.context)
        newData.localIdentifier = localIdentifier
        newData.photoData = getPhotoData(image: newPhoto)
        PersistenceService.saveContext()
        dataArray.append(newData)
    }
    

}
