//
//  ParkCollectionViewCell.swift
//  accolade
//
//  Created by Matěj Novák on 18.01.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift
class PlaceCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var selectedPlace = true {
        didSet {
            self.imageView.alpha = selectedPlace ? 1 : 0.3
        }
    }
    var disposeBag = DisposeBag()
    var place:Place! {
        didSet {
            self.layer.cornerRadius = 10
            if let url = try? place.image.asURL() {
            imageView.kf.setImage(with: url)
            } else {
                imageView.image = nil
            }
            titleLabel.text = place.title
            overlayView.gradientBackground(from: Config.Color.primary, to: UIColor.clear, direction: .bottomToTop)
        }
    }
}
