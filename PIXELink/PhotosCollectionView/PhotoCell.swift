//
//  PhotoCell.swift
//  PIXELink
//
//  Created by Xavi Anderhub on 7/2/18.
//  Copyright © 2018 Xavi Anderhub. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    
    var photo: UIImage!
    var similarity: Double!
    
    var similarLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.shadowColor = .black
        return label
    }()
    
    var photoView: UIImageView = {
        let pv = UIImageView()
        pv.contentMode = .scaleAspectFill
        pv.clipsToBounds = true
        return pv
    }()
    
    func setupViews() {
        backgroundColor = .clear
        photoView.image = photo
        similarLabel.text = String(format: "%.2f", similarity)
        
        
        addSubview(photoView)
        addSubview(similarLabel)
        
        photoView.translatesAutoresizingMaskIntoConstraints = false
        similarLabel.translatesAutoresizingMaskIntoConstraints = false
        
        photoView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        photoView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        photoView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        photoView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        similarLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        similarLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true

    }
    
}
