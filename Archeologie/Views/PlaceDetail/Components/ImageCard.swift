//
//  ImageCard.swift
//  Archeologie
//
//  Created by Matěj Novák on 14/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit
import ZoomImageView

class ImageCard:UIView {
    @IBOutlet weak var imageView:ZoomImageView!
    @IBOutlet weak var textLabel:UILabel!
    @IBOutlet weak var overlayView:UIView!
    
    var image:Image! {
        didSet {
            if let url = try? image.url.asURL(), let rImage = try? UIImage(withContentsOfUrl: url) {
                imageView.image = rImage
            }
            textLabel.text = image.text
        }
    }
    
}

