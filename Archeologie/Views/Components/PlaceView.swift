//
//  PlaceView.swift
//  MSMT
//
//  Created by Matěj Novák on 31/10/2019.
//  Copyright © 2019 Matěj Novák. All rights reserved.
//

import Foundation
import RxSwift

class PlaceView:UIView {
    @IBOutlet weak var selectedPlaceTitle: UILabel!
    @IBOutlet weak var selectedPlaceAddress: UILabel!
    @IBOutlet weak var selectedPlaceCategory: UILabel!
    @IBOutlet weak var selectedPlaceCategoryColor: UIView!
    @IBOutlet weak var selectedPlaceDate: UILabel!
    @IBOutlet weak var selectedPlaceGrant: UILabel!
    
    lazy var selectedPlaceBag:DisposeBag = DisposeBag()
    var place:Place! {
        didSet {
            selectedPlaceTitle.text = place.title

            
//            if let color = PlacesService.service.tags.value.first(where: {$0.title == place.filter})?.color {
//                  self.selectedPlaceCategoryColor.backgroundColor = UIColor(hexString: color)
//              }

        }
    }
}
