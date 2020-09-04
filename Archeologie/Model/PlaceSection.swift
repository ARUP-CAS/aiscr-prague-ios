//
//  PlaceSection.swift
//  accolade
//
//  Created by Matěj Novák on 28.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
import RxDataSources

enum PlaceSectionModel {

    case places(items:[PlaceSectionItem])
}

enum PlaceSectionItem {
    case placeItem(place:Place)
}


extension PlaceSectionModel:SectionModelType {
    typealias Item = PlaceSectionItem
    
    var items: [PlaceSectionItem] {

            return items.map {$0}

    }
    
    init(original: PlaceSectionModel, items: [Item]) {

            self = .places(items: items)
   
    }
}
