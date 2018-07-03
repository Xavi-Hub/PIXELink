//
//  DataAsset.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 7/2/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import Photos

class DataAsset: Comparable {
    
    var asset: PHAsset
    var photoDifference: Double?
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    
    static func < (lhs: DataAsset, rhs: DataAsset) -> Bool {
        return lhs.photoDifference! < rhs.photoDifference!
    }
    
    static func == (lhs: DataAsset, rhs: DataAsset) -> Bool {
        return lhs.photoDifference == rhs.photoDifference
    }


    
}

