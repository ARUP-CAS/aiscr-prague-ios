//
//  ThematicsPullViewController.swift
//  Archeologie
//
//  Created by Matěj Novák on 03/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift

class ThematicsPullViewController: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var detailStack: UIStackView!
    @IBOutlet weak var guideDescription: UILabel!
    
    var placeSelected:((Thematic)->Void)?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.detailStack.isHidden = true
        
        PlacesService.service.selectedThematic.asObservable().subscribe { (event) in
            
            guard let place = event.element else { return }
            
            self.detailStack.isHidden = place == nil
            self.collectionView.reloadData()
            
            if let place = place, place.characteristics != "" {
                self.guideDescription.text = place.characteristics
                self.guideDescription.isHidden = false
            } else {
                self.guideDescription.isHidden = true

            }
            
        }.disposed(by: disposeBag)
        
        PlacesService.service.thematics.bind(to: collectionView.rx.items(cellIdentifier: "carouselCell")) { _, model, cell in
            if let cell = cell as? PlaceCollectionViewCell {
                cell.disposeBag = DisposeBag()
                cell.place = model
                
                cell.selectedPlace = PlacesService.service.selectedThematic.value?.id == model.id || PlacesService.service.selectedThematic.value == nil
                cell.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
                    
                    PlacesService.service.selectedThematic.accept(model)

                    
                }.disposed(by: cell.disposeBag)
            }
        }.disposed(by: disposeBag)
    }
    
    @IBAction func startGuide() {
        
        if let locationsViewController = self.storyboard?.instantiateViewController(identifier: "locationsViewController") as? LocationsViewController, let place = PlacesService.service.selectedThematic.value {
            locationsViewController.thematic = place
            self.present(locationsViewController, animated: true, completion: nil)
        }
    }

}
