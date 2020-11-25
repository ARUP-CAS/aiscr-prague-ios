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
    @IBOutlet weak var detailStack: UIStackView!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    
    @IBOutlet weak var openIcon: UIImageView!
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var difficultyIcon: UIImageView!

    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var webButton: BorderButton!
    @IBOutlet weak var navigateButton: BorderButton!
    


    var placeSelected:((Location)->Void)?

    override func viewDidLoad() {
        
        super.viewDidLoad()

        PlacesService.service.selectedThematic.asObservable().map { $0?.title}.bind(to: self.thematicsLabel.rx.text).disposed(by: disposeBag)
        
        PlacesService.service.locations.bind(to: collectionView.rx.items(cellIdentifier: "carouselCell")) { _, model, cell in
            if let cell = cell as? PlaceCollectionViewCell {
                cell.disposeBag = DisposeBag()
                cell.place = model
                cell.selectedPlace = PlacesService.service.selectedLocation.value?.id == model.id || PlacesService.service.selectedLocation.value == nil
                
                cell.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
                    
                    self.placeSelected?(model)

                    
                }.disposed(by: cell.disposeBag)
            }
        }.disposed(by: disposeBag)
        
        PlacesService.service.selectedLocation.asObservable().subscribe { event in
            if let element = event.element, let location = element {
                self.openIcon.isHidden = !location.openTime
    
                switch location.timeOfVisit {
                case .fifteen, .thrity, .fourtyfive, .sixty:
                    self.timeIcon.isHidden = false
                    self.timeIcon.image = UIImage(named: "visit-duration-\(location.timeOfVisit.rawValue)")
                default:
                    self.timeIcon.isHidden = true
                }

                self.difficultyIcon.image = UIImage(named: "difficulty-\(location.availability.rawValue)")
                self.addressLabel.text = location.address
                //        self.authorsLabel.text = place.implementer
                self.gpsLabel.text = "\(location.latitude), \(location.longitude)"
                self.startButton.isEnabled = true
                self.webButton.isEnabled = true
                self.navigateButton.isEnabled = true
                self.webButton.isHidden = location.externalLink == nil
                
            } else {
                self.startButton.isEnabled = false
                self.webButton.isEnabled = false
                self.navigateButton.isEnabled = false
            }

            self.collectionView.reloadData()
            

        }.disposed(by: disposeBag)
        
    }
    
    @IBAction func openPlace(_ sender: Any) {
        if let nav = self.storyboard?.instantiateViewController(withIdentifier: "placeDetailNav") as? UINavigationController, let placeDetailViewController = nav.viewControllers.first as? PlaceDetailViewController {
            nav.modalPresentationStyle = .overCurrentContext
            nav.hero.isEnabled = true
            nav.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .uncover(direction: .down))
            nav.modalPresentationCapturesStatusBarAppearance = true
            placeDetailViewController.place = PlacesService.service.selectedLocation.value
            //            statusBar = .lightContent
            //            setNeedsStatusBarAppearanceUpdate()
            self.present(nav, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func showOnWeb(_ sender: Any) {
        if let url = try? PlacesService.service.selectedLocation.value?.externalLink?.asURL() {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func openNavigation(_ sender: Any) {
        guard  let location = PlacesService.service.selectedLocation.value?.coordinate, let url = URL(string: "\(Config.mapQueryURL)\(location.latitude),\(location.longitude)") else {return}
       
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
