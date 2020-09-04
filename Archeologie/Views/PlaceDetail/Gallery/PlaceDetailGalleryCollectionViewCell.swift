//
//  PlaceDetailGalleryCollectionViewCell.swift
//  Places
//
//  Created by Matěj Novák on 31.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit

class PlaceDetailGalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var photo:Photo! {
        didSet {
            if let urlString = photo.url, let url = try? urlString.asURL() {
                imageView.kf.setImage(with: url)
            }
            
        }
    }
}
