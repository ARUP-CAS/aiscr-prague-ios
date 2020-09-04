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
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        guard let place = PlacesService.service.selectedThematic.value else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        author.text = place.author
        coop.text = place.professionalCooperation
        artCoop.text = place.artisticsCooperation
        acknowledgment.text = place.thanks
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
            
            stack.addArrangedSubview(imageView)
        }
    }
}
