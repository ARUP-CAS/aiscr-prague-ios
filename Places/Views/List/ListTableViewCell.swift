//
//  ListTableViewCell.swift
//  Places
//
//  Created by Matěj Novák on 22.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import Kingfisher
class ListTableViewCell: UITableViewCell {
    
    var place:Place! {
        didSet {
            
            titleLabel.text = place.title
            subtitleLabel.text = place.address?.components(separatedBy: ",").first
            
            if let photo = place.photos?.first?.url, let url = try? photo.asURL() {
                photoView.kf.setImage(with: url)
            }
            
            if let tag = place.tags?.first, let tagColor = tag.color {
                tagColorView.backgroundColor = UIColor(hexString: tagColor)
                tagTitleLabel.text = tag.title
            } else {
                tagTitleLabel.text = nil
            }
        }
    }
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tagColorView: UIView!
    @IBOutlet weak var tagTitleLabel: UILabel!
    

}
