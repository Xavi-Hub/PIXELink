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

protocol SizeInfoReceiver {
    func handleSizeUpdate(percent: CGFloat)
}

protocol ColorInfoReceiver {
    func handleColorUpdate(percent: CGFloat)
}

protocol DarknessInfoReceier {
    func handleDarknessUpdate(percent: CGFloat)
}


class DrawingViewController: UIViewController, ColorInfoReceiver {

    var dataArray = [Photo]()
    var portraitConstraints = [NSLayoutConstraint]()
    var landscapeConstraints = [NSLayoutConstraint]()
    var drawingView = DrawingView()
    var isProcessingPhotos = false
    var currentProcessingPhotoIndex = 0
    var numberOfPhotosToBeProcessed = 0
    
    
    let processingLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont(name: AppDelegate.mainFont, size: 16)
        label.textColor = UIColor(white: 0.6, alpha: 0.6)
        return label
    }()
    
    let processingItem = UIBarButtonItem()

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
        
        setupNavController()
        
        layoutAndConstrainViews()
        
    }
    
    func setupNavController() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = AppDelegate.mainColor
        view.backgroundColor = AppDelegate.alternateColor
        processingItem.customView = processingLabel
        updateProcessingLabel()
        processingLabel.sizeToFit()
        processingItem.width = 50
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Search", style: .plain, target: self, action: #selector(search)), UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(handleUndo(sender:))), processingItem]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(handleClear(sender:)))
    }
    
    func updateProcessingLabel() {
        let barLabel = processingItem.customView as! UILabel
        if numberOfPhotosToBeProcessed == 0 {
            barLabel.text = ""
        } else if currentProcessingPhotoIndex > numberOfPhotosToBeProcessed {
            barLabel.text = ""
        } else {
            barLabel.text = "\(currentProcessingPhotoIndex)/\(numberOfPhotosToBeProcessed)"
        }
    }
    
    func layoutAndConstrainViews() {
        
        let containerView1 = UIView()
        let containerView1_2 = UIView()
        let sizeCircle = SizeCircle()
        let colorCircle = ColorCircle()
        let darknessCircle = DarknessCircle()
        let circlesView = UIView()
                
        sizeCircle.backgroundColor = .clear
        colorCircle.backgroundColor = .clear
        colorCircle.receiver = self
        darknessCircle.backgroundColor = .clear
        
        view.addSubview(containerView1)
        containerView1.addSubview(circlesView)
        containerView1.addSubview(containerView1_2)

        view.addSubview(drawingView)
        view.addSubview(containerView1)
        containerView1.addSubview(circlesView)
        circlesView.addSubview(colorCircle)
        circlesView.addSubview(sizeCircle)
        circlesView.addSubview(darknessCircle)
        containerView1.addSubview(containerView1_2)
        blackWhiteGradientMask.transform = blackWhiteGradientMask.transform.rotated(by: -.pi/2)
        hueImageView.addSubview(blackWhiteGradientMask)
        
        hueImageView.addGestureRecognizer(hueRecognizer)
        hueImageView.isUserInteractionEnabled = true
        
        drawingView.addGestureRecognizer(pinchRecognizer)
        
        blackWhiteImageView.addGestureRecognizer(grayRecognizer)
        blackWhiteImageView.isUserInteractionEnabled = true
        
        containerView1.translatesAutoresizingMaskIntoConstraints = false
        circlesView.translatesAutoresizingMaskIntoConstraints = false
        sizeCircle.translatesAutoresizingMaskIntoConstraints = false
        colorCircle.translatesAutoresizingMaskIntoConstraints = false
        darknessCircle.translatesAutoresizingMaskIntoConstraints = false
        containerView1_2.translatesAutoresizingMaskIntoConstraints = false
        drawingView.translatesAutoresizingMaskIntoConstraints = false
        hueImageView.translatesAutoresizingMaskIntoConstraints = false
        blackWhiteGradientMask.translatesAutoresizingMaskIntoConstraints = false
        blackWhiteImageView.translatesAutoresizingMaskIntoConstraints = false
        
        portraitConstraints.append(drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        portraitConstraints.append(drawingView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor))
        portraitConstraints.append(drawingView.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        portraitConstraints.append(drawingView.heightAnchor.constraint(equalTo: drawingView.widthAnchor))
        
        portraitConstraints.append(containerView1.centerXAnchor.constraint(equalTo: view.centerXAnchor))
        portraitConstraints.append(containerView1.topAnchor.constraint(equalTo: drawingView.bottomAnchor))
        portraitConstraints.append(containerView1.widthAnchor.constraint(equalTo: view.widthAnchor))
        portraitConstraints.append(containerView1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        
        portraitConstraints.append(circlesView.centerXAnchor.constraint(equalTo: containerView1.centerXAnchor))
        portraitConstraints.append(circlesView.topAnchor.constraint(equalTo: containerView1.topAnchor))
        portraitConstraints.append(circlesView.widthAnchor.constraint(equalTo: containerView1.widthAnchor))
        portraitConstraints.append(circlesView.heightAnchor.constraint(equalTo: containerView1.heightAnchor, multiplier: 0.6))
        
        portraitConstraints.append(sizeCircle.leftAnchor.constraint(equalTo: circlesView.leftAnchor))
        portraitConstraints.append(sizeCircle.widthAnchor.constraint(equalTo: circlesView.widthAnchor, multiplier: 1/3))
        portraitConstraints.append(sizeCircle.topAnchor.constraint(equalTo: circlesView.topAnchor))
        portraitConstraints.append(sizeCircle.bottomAnchor.constraint(equalTo: circlesView.bottomAnchor))
        
        portraitConstraints.append(colorCircle.leftAnchor.constraint(equalTo: sizeCircle.rightAnchor))
        portraitConstraints.append(colorCircle.widthAnchor.constraint(equalTo: sizeCircle.widthAnchor))
        portraitConstraints.append(colorCircle.topAnchor.constraint(equalTo: sizeCircle.topAnchor))
        portraitConstraints.append(colorCircle.bottomAnchor.constraint(equalTo: sizeCircle.bottomAnchor))
        
        portraitConstraints.append(darknessCircle.leftAnchor.constraint(equalTo: colorCircle.rightAnchor))
        portraitConstraints.append(darknessCircle.widthAnchor.constraint(equalTo: colorCircle.widthAnchor))
        portraitConstraints.append(darknessCircle.topAnchor.constraint(equalTo: sizeCircle.topAnchor))
        portraitConstraints.append(darknessCircle.bottomAnchor.constraint(equalTo: sizeCircle.bottomAnchor))

        
        portraitConstraints.append(containerView1_2.centerXAnchor.constraint(equalTo: containerView1.centerXAnchor))
        portraitConstraints.append(containerView1_2.topAnchor.constraint(equalTo: circlesView.bottomAnchor))
        portraitConstraints.append(containerView1_2.widthAnchor.constraint(equalTo: containerView1.widthAnchor))
        portraitConstraints.append(containerView1_2.bottomAnchor.constraint(equalTo: containerView1.bottomAnchor))

        
        
        landscapeConstraints.append(drawingView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor))
        landscapeConstraints.append(drawingView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor))
        landscapeConstraints.append(drawingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor))
        landscapeConstraints.append(drawingView.widthAnchor.constraint(equalTo: drawingView.heightAnchor))
        
        
        
        
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
        
        if PHPhotoLibrary.authorizationStatus() == .denied {
            let alert = UIAlertController(title: "Photo Library Access", message: "This app requires access to your photos.\n\nTo grant access, open the Settings app and navigate to Privacy > Photos > PIXELink and check \"Read and Write\"", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if isProcessingPhotos {
            let alert = UIAlertController(title: "Processing Photos...", message: "Some of your photos could still be undergoing initial processing. This only occurs when you have new photos to be processed.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                let photo = self.getDrawnPhoto(sender: nil)
                let photosCollectionViewController = PhotosCollectionViewController(photo: photo, dataArray: self.dataArray)
                self.navigationController?.pushViewController(photosCollectionViewController, animated: true)
            }))
            self.present(alert, animated: true)
            
        } else {
            let photo = getDrawnPhoto(sender: nil)
            let photosCollectionViewController = PhotosCollectionViewController(photo: photo, dataArray: dataArray)
            navigationController?.pushViewController(photosCollectionViewController, animated: true)
        }
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
            updateBackgroundColor(xPercent: xPercent, yPercent: 1-yPercent)
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
    
    func handleColorUpdate(percent: CGFloat) {
        drawingView.changeCurrentColor(newColor: UIColor(hue: percent, saturation: 1, lightness: 0.5))
    }
    
    @objc func updateBackgroundGray(percent: CGFloat) {
        let newGray = UIColor(white: percent, alpha: 1)
        drawingView.changeCurrentColor(newColor: newGray)
    }
    
    
    func grabPhotos() {
        isProcessingPhotos = true
        
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization { (status) in
                if status == .denied {
                    return
                }
            }
        }
        
        print("Processing photos...")
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
            
            // Making sure each already-made Photo object has data and an identifier attached to it.
            // If not, removing it from dataArray to be re-processed below.
            for photo in self.dataArray {
                if photo.photoData == nil || photo.localIdentifier == nil {
                    self.dataArray.remove(at: self.dataArray.index(of: photo)!)
                }
            }
            
            // Setting up arrays to compare number of dataIdentifiers and photoIdentifers
            var dataIdentifiers = [String]()
            var photoIdentifiers = [String]()
            for photo in self.dataArray {
                dataIdentifiers.append(photo.localIdentifier!)
            }
            for i in 0..<photoFetchResult.count {
                photoIdentifiers.append(photoFetchResult[i].localIdentifier)
            }
            
            // Deleting data from stored data if photo has been deleted from device
            var toBeDeletedArray = [Int]()
            if self.dataArray.count != 0 {
                for i in 0..<self.dataArray.count {
                    if !photoIdentifiers.contains(self.dataArray[i].localIdentifier ?? "") {
                        toBeDeletedArray.append(i)
                    }
                }
            }
            if toBeDeletedArray.count != 0 {
                for i in 0..<toBeDeletedArray.count {
                    print("Deleting item: \(i)")
                    let index = toBeDeletedArray[toBeDeletedArray.count-1-i]
                    PersistenceService.context.delete(self.dataArray[index])
                    PersistenceService.saveContext()
                    self.dataArray.remove(at: index)
                    dataIdentifiers.remove(at: index)
                }

            }
            
            var newlyAddedAssets: [PHAsset] = []
            if photoFetchResult.count > 0 {
                for i in 0..<photoFetchResult.count{
                    // Checking for newly added photos and adding them to an array
                    let identifer = photoFetchResult[i].localIdentifier
                    if !dataIdentifiers.contains(identifer) {
                        newlyAddedAssets.append(photoFetchResult[i])
                    }
                }
                self.numberOfPhotosToBeProcessed = newlyAddedAssets.count
                self.currentProcessingPhotoIndex = 1
                // Processing newly added photos from newlyAddedIdentifiersArray
                self.currentProcessingPhotoIndex = 1
                for asset in newlyAddedAssets {
                    autoreleasepool {
                        print("Processing photo \(self.currentProcessingPhotoIndex)/\(self.numberOfPhotosToBeProcessed).")
                        imgManager.requestImage(for: asset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: photoRequestOptions, resultHandler: {[unowned self] (image, error) in
                            self.savePhotoData(newPhoto: image!, localIdentifier: asset.localIdentifier)
                            self.currentProcessingPhotoIndex += 1
                            DispatchQueue.main.async {
                                self.setupNavController()
                            }
                        })
                    }
                }
            } else {

            
//            if photoFetchResult.count > 0 {
//                for i in 0..<photoFetchResult.count{
//                    autoreleasepool {
//                        let identifier = photoFetchResult[i].localIdentifier
//                        if !dataIdentifiers.contains(identifier) {
//                            imgManager.requestImage(for: photoFetchResult.object(at: i) as PHAsset, targetSize: CGSize(width:500, height: 500),contentMode: .aspectFill, options: photoRequestOptions, resultHandler: {[unowned self] (image, error) in
//                                self.savePhotoData(newPhoto: image!, localIdentifier: identifier)
//                            })
//                        }
//                    }
//                }
//            } else {
                if PHPhotoLibrary.authorizationStatus() == .authorized {
                    print("No photos found.")
                }
            }
            print("Done processing photos.")
            self.isProcessingPhotos = false
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

    // Resizes photo and returns a data object of RBGA Pixels
    func getPhotoData(image: UIImage) -> NSData {
        
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
        newPhotoCount += 1
        let newData = Photo(context: PersistenceService.context)
        newData.localIdentifier = localIdentifier
        newData.photoData = getPhotoData(image: newPhoto)
        PersistenceService.saveContext()
        dataArray.append(newData)
    }
    

}
