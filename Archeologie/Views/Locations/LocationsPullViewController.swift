//
//  ThematicsPullViewController.swift
//  Archeologie
//
//  Created by Matěj Novák on 03/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift

class LocationsPullViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var thematicsLabel: UILabel!

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        PlacesService.service.selectedThematic.asObservable().map { $0?.title}.bind(to: self.thematicsLabel.rx.text).disposed(by: disposeBag)
        
        PlacesService.service.locations.bind(to: collectionView.rx.items(cellIdentifier: "carouselCell")) { _, model, cell in
            if let cell = cell as? PlaceCollectionViewCell {
                cell.disposeBag = DisposeBag()
                cell.place = model
                
                cell.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
                    
                    if let nav = self.storyboard?.instantiateViewController(withIdentifier: "placeDetailNav") as? UINavigationController, let placeDetailViewController = nav.viewControllers.first as? PlaceDetailViewController {
                        nav.modalPresentationStyle = .overCurrentContext
                        nav.hero.isEnabled = true
                        nav.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .uncover(direction: .down))
                        nav.modalPresentationCapturesStatusBarAppearance = true
                        placeDetailViewController.place = model
                        self.present(nav, animated: true, completion: nil)
                    }
                }.disposed(by: cell.disposeBag)
            }
        }.disposed(by: disposeBag)
    }
    
    
}
