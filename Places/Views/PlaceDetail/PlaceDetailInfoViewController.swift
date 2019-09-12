//
//  PlaceDetailInfoViewController.swift
//  Places
//
//  Created by Matěj Novák on 31.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift
import RxGesture
class PlaceDetailInfoViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    
    @IBOutlet weak var tagView: TagView!
    @IBOutlet var textView:UITextView!

    var place:Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.textView.attributedText = place.text?.htmlAttributed
        titleLabel.text = place.title
        addressLabel.text = place.address
        linkLabel.text = place.link
        
        if let tags = place.tags {
            tagView.setTags(tags: tags)
        }
        
        linkLabel.rx.tapGesture().when(.recognized).asObservable().subscribe(onNext: { (_) in
            if let urlOpt = try? self.linkLabel.text?.asURL(), let url = urlOpt {
                UIApplication.shared.open(url)
            }
        }).disposed(by: disposeBag)
        
    }


}
