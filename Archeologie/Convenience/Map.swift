//
//  Map.swift
//  accolade
//
//  Created by Matěj Novák on 11.04.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
import GoogleMaps

extension GMSMapView {
    func offsetCoordinate(for coordinate:CLLocationCoordinate2D, offsetX:Float, offsetY:Float) -> CLLocationCoordinate2D {
        let center = self.projection.point(for: coordinate)
        print("offsetY \(offsetY)")
        let offsetPoint = CGPoint(x: CGFloat(offsetX), y: CGFloat(offsetY)+40)
        let newPoint = self.projection.coordinate(for: CGPoint(x: center.x - offsetPoint.x, y: center.y - offsetPoint.y))
        return newPoint
    }
}
