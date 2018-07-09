//
//  PhotosCollectionViewController.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 7/2/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "photoCell"

class PhotosCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var drawnPhoto: NSData
    var dataArray: [Photo]
    var assets: [DataAsset] = []
    let imgManager = PHImageManager.default()
    var dispatchItem: DispatchWorkItem!
    let trackLayer = CAShapeLayer()
    let calculatingLayer = CAShapeLayer()
    var totalPhotoCount = 0
    var processedPhotoCount = 0
    
    init(photo: NSData, dataArray: [Photo]) {
        drawnPhoto = photo
        self.dataArray = dataArray
        self.totalPhotoCount = dataArray.count
        super.init(collectionViewLayout: UICollectionViewLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView?.collectionViewLayout = layout

        collectionView!.register(PhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView?.backgroundColor = AppDelegate.alternateColor
        view.backgroundColor = AppDelegate.alternateColor
        
        setupViews()
        grabPhotos()
        
    }
    
    
    func setupViews() {
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false

        collectionView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        collectionView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    func toggleCalculatingLayers(hidden: Bool) {
        
        if hidden {
            trackLayer.isHidden = true
            calculatingLayer.isHidden = true
        } else {
            trackLayer.isHidden = false
            calculatingLayer.isHidden = false
            
            trackLayer.frame = collectionView!.frame
            calculatingLayer.frame = collectionView!.frame
            
            let calculatingPath = UIBezierPath(arcCenter: view.center, radius: 100, startAngle: -.pi/2, endAngle: 3 * .pi/2, clockwise: true)
//            calculatingPath.move(to: CGPoint(x: view.center.x-50, y: view.center.y))
//            calculatingPath.addLine(to: CGPoint(x: view.center.x+50, y: view.center.y))

            trackLayer.path = calculatingPath.cgPath
            calculatingLayer.path = calculatingPath.cgPath
            
            trackLayer.lineWidth = 10
            trackLayer.lineCap = kCALineCapRound
            trackLayer.strokeColor = UIColor.lightGray.cgColor
            trackLayer.fillColor = UIColor.clear.cgColor
            
            calculatingLayer.lineWidth = 10
            calculatingLayer.lineCap = kCALineCapRound
            calculatingLayer.strokeColor = AppDelegate.mainColor.cgColor
            calculatingLayer.fillColor = UIColor.clear.cgColor 
            
            calculatingLayer.strokeEnd = 0
            
            if trackLayer.superlayer == nil {
                collectionView?.layer.addSublayer(trackLayer)
            }
            if calculatingLayer.superlayer == nil {
                collectionView?.layer.addSublayer(calculatingLayer)
            }
            
        }
        
    }
    
    func updateCalculatingLayers() {
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.toValue = Double(processedPhotoCount)/Double(totalPhotoCount)
        animation.duration = 0.5
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        calculatingLayer.add(animation, forKey: nil)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        
        if parent == nil {
            DispatchQueue.global(qos: .background).async {
                self.dispatchItem.cancel()
            }
        }
    }
    
    // Grabs photo assets and puts them in the DataAsset array, then reloads collectionView.
    func grabPhotos() {
        DispatchQueue.global(qos: .background).async {
            
            let photoFetchOptions=PHFetchOptions()
            photoFetchOptions.sortDescriptors=[NSSortDescriptor(key:"creationDate", ascending: false)]
            
            let photoFetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: photoFetchOptions)
            
            if photoFetchResult.count == 0 {return}
            for i in 0..<photoFetchResult.count {
                let asset = photoFetchResult.object(at: i) as PHAsset
                // dataArray MUST contain all photos, or else a DataAsset's photoDifference will be nil
                self.assets.append(DataAsset(asset: asset))
            }
            self.processDifferences()
        }
    }

//    func processDifferences() {
//        let rawDrawnData = drawnPhoto.bytes.bindMemory(to: RGBAPixel.self, capacity: 32 * 32)
//        let drawnPixels = UnsafeBufferPointer<RGBAPixel>(start: rawDrawnData, count: 32 * 32)
//        for photo in dataArray {
//            let rawPhotoData = photo.photoData?.bytes.bindMemory(to: RGBAPixel.self, capacity: 32 * 32)
//            let photoPixels = UnsafeBufferPointer<RGBAPixel>(start: rawPhotoData, count: 32 * 32)
//            var photoDifference = 0.0
//            var processedPixels = 0
//            for i in 0..<photoPixels.count {
//                let currentDrawnPixel = drawnPixels[i]
//                let currentPhotoPixel = photoPixels[i]
//                if currentDrawnPixel.red == 250 && currentDrawnPixel.green == 250 && currentDrawnPixel.blue == 250 {
//                    continue
//                }
//                let absRedDifference = abs(Int(currentDrawnPixel.red) - Int(currentPhotoPixel.red))
//                let absGreenDifference = abs(Int(currentDrawnPixel.green) - Int(currentPhotoPixel.green))
//                let absBlueDifference = abs(Int(currentDrawnPixel.blue) - Int(currentPhotoPixel.blue))
//                let pixelDifference = absRedDifference + absGreenDifference + absBlueDifference
//                photoDifference += Double(pixelDifference)/(255*3)
//                processedPixels += 1
//            }
//            let currentAssetIndex = assets.index(where: { (asset) -> Bool in
//                return asset.asset.localIdentifier == photo.localIdentifier
//                })
//            let currentAsset = assets[currentAssetIndex!]
//            currentAsset.photoDifference = processedPixels == 0 ? 1 : photoDifference / (Double (processedPixels))
//        }
//    }
    
    func processDifferences() {
        dispatchItem = DispatchWorkItem {
            DispatchQueue.main.async {
                self.toggleCalculatingLayers(hidden: false)
            }
            let rawDrawnData = self.drawnPhoto.bytes.bindMemory(to: RGBAPixel.self, capacity: 32 * 32)
            let drawnPixels = UnsafeBufferPointer<RGBAPixel>(start: rawDrawnData, count: 32 * 32)
            for photo in self.dataArray {
                if !self.dispatchItem.isCancelled {
                    if photo.photoData == nil {
                        continue
                    }
                    let rawPhotoData = photo.photoData?.bytes.bindMemory(to: RGBAPixel.self, capacity: 32 * 32)
                    let photoPixels = UnsafeBufferPointer<RGBAPixel>(start: rawPhotoData, count: 32 * 32)
                    var photoDifference = 0.0
                    var processedPixels = 0
                    for i in 0..<photoPixels.count {
                        let currentDrawnPixel = drawnPixels[i]
                        let currentPhotoPixel = photoPixels[i]
                        if currentDrawnPixel.red == 250 && currentDrawnPixel.green == 250 && currentDrawnPixel.blue == 250 {
                            continue
                        }
                        let drawnColor = (Int(currentDrawnPixel.red), Int(currentDrawnPixel.green), Int(currentDrawnPixel.blue))
                        let photoColor = (Int(currentPhotoPixel.red), Int(currentPhotoPixel.green), Int(currentPhotoPixel.blue))
                        let deltaE = ColorHelper.deltaE(color1: drawnColor, color2: photoColor)
                        photoDifference += deltaE
                        processedPixels += 1
                    }
                    let currentAssetIndex = self.assets.index(where: { (asset) -> Bool in
                        return asset.asset.localIdentifier == photo.localIdentifier
                    })
                    if currentAssetIndex == nil {
                        self.dataArray.remove(at: self.dataArray.index(of: photo)!)
                        PersistenceService.context.delete(photo)
                        PersistenceService.saveContext()
                        continue
                    }
                    let currentAsset = self.assets[currentAssetIndex!]
                    currentAsset.photoDifference = processedPixels == 0 ? 1 : photoDifference / (Double (processedPixels)) / 100
                    self.processedPhotoCount += 1
                    DispatchQueue.main.async {
                        self.updateCalculatingLayers()
                    }
                } else {
                    break
                }
            }
            self.assets.sort()
            DispatchQueue.main.async {
                self.toggleCalculatingLayers(hidden: true)
                self.collectionView?.reloadData()
            }
        }
        
        DispatchQueue.global(qos: .background).async(execute: dispatchItem)
        
    }
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCell
    
        let photoRequestOptions=PHImageRequestOptions()
        photoRequestOptions.isSynchronous=true
        photoRequestOptions.deliveryMode = .opportunistic
        if !(assets.isEmpty) {
            imgManager.requestImage(for: assets[indexPath.row].asset, targetSize: CGSize(width:200, height: 200),contentMode: .aspectFill, options: photoRequestOptions, resultHandler: { (image, error) in
                cell.photo = image
            })
            cell.similarity = 1-(assets[indexPath.row].photoDifference ?? 1)
        }
        cell.setupViews()
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        if UIDevice.current.orientation.isPortrait {
            return CGSize(width: width/4-1, height: width/4-1)
        } else {
            return CGSize(width: width/6-1, height: width/6-1)
        }
    }
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
