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
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var creditsButton: UIButton!
    @IBOutlet weak var characteristicsLabel: UILabel!
    
    
    var placeSelected:((Thematic)->Void)?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        PlacesService.service.selectedThematic.asObservable().subscribe { (event) in
            
            guard let place = event.element else { return }
            
            self.startButton.isEnabled = place != nil
            self.creditsButton.isEnabled = place != nil
            
            if let characteristics = place?.characteristics {
                self.characteristicsLabel.isHidden = false
                self.characteristicsLabel.text = characteristics
            } else {
                self.characteristicsLabel.isHidden = true
            }
            
            self.collectionView.reloadData()
    
            
            
        }.disposed(by: disposeBag)
        
        PlacesService.service.thematics.bind(to: collectionView.rx.items(cellIdentifier: "carouselCell")) { _, model, cell in
            if let cell = cell as? PlaceCollectionViewCell {
                cell.disposeBag = DisposeBag()
                cell.place = model
                
                cell.selectedPlace = PlacesService.service.selectedThematic.value?.id == model.id || PlacesService.service.selectedThematic.value == nil
                cell.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
                    
                    self.placeSelected?(model)
                    
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
