//
//  ThematicsCreditsViewController.swift
//  Archeologie
//
//  Created by Matěj Novák on 04/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift

class ThematicsCreditsViewController: BaseViewController {
    @IBOutlet weak var stack: UIStackView!
    
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var coop: UILabel!
    @IBOutlet weak var artCoop: UILabel!
    @IBOutlet weak var acknowledgment: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var coopLabel: UILabel!
    @IBOutlet weak var artCoopLabel: UILabel!
    @IBOutlet weak var acknowledgmentLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        guard let place = PlacesService.service.selectedThematic.value else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if let placeAuthor = place.author {
            author.text = placeAuthor
        } else {
            author.isHidden = true
            authorLabel.isHidden = true
        }
        if let professionalCooperation = place.professionalCooperation {
            coop.text = professionalCooperation
        } else {
            coop.isHidden = true
            coopLabel.isHidden = true
        }
        if let artisticsCooperation = place.artisticsCooperation {
            artCoop.text = artisticsCooperation
        } else {
            artCoop.isHidden = true
            artCoopLabel.isHidden = true
        }
        if let thanks = place.thanks {
            acknowledgment.text = thanks
        } else {
            acknowledgment.isHidden = true
            acknowledgmentLabel.isHidden = true
        }

        createImage(url: place.logo1)
        createImage(url: place.logo2)
        createImage(url: place.logo3)
        createImage(url: place.logo4)

     
    }
    
    @IBAction func closeView(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func createImage(url:String) {
        if let url = try? url.asURL() {
            let imageView = UIImageView()
            imageView.kf.setImage(with: url)
            imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
            imageView.contentMode = .scaleAspectFit
            
            stack.addArrangedSubview(imageView)
            imageView.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 20).isActive = true
            imageView.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -20).isActive = true
        }
    }
}
