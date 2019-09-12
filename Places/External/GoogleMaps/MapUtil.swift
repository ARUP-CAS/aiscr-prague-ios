//
//  MapUtil.swift
//  accolade
//
//  Created by Matěj Novák on 08.02.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation


class MapUtil {
    
    class func translateCoordinate(coordinate: CLLocationCoordinate2D, metersLat: Double,metersLong: Double) -> (CLLocationCoordinate2D) {
        var tempCoord = coordinate
        
        let tempRegion = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: metersLat, longitudinalMeters: metersLong)
        let tempSpan = tempRegion.span
        
        tempCoord.latitude = coordinate.latitude + tempSpan.latitudeDelta
        tempCoord.longitude = coordinate.longitude + tempSpan.longitudeDelta
        
        return tempCoord
    }
    
    class func setRadius(radius: Double,withCity city: CLLocationCoordinate2D,InMapView mapView: GMSMapView) {
        
        let range = MapUtil.translateCoordinate(coordinate: city, metersLat: radius * 2, metersLong: radius * 2)
        
        let bounds = GMSCoordinateBounds(coordinate: city, coordinate: range)
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 5.0)    // padding set to 5.0
        
        mapView.moveCamera(update)
    }
        
}

extension GMSCameraUpdate {
    
    static func fit(coordinate: CLLocationCoordinate2D, radius: Double) -> GMSCameraUpdate {
        var leftCoordinate = coordinate
        var rigthCoordinate = coordinate
        
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: radius, longitudinalMeters: radius)
        let span = region.span
        
        leftCoordinate.latitude = coordinate.latitude - span.latitudeDelta
        leftCoordinate.longitude = coordinate.longitude - span.longitudeDelta
        rigthCoordinate.latitude = coordinate.latitude + span.latitudeDelta
        rigthCoordinate.longitude = coordinate.longitude + span.longitudeDelta
        
        let bounds = GMSCoordinateBounds(coordinate: leftCoordinate, coordinate: rigthCoordinate)
        let update = GMSCameraUpdate.fit(bounds, withPadding: -15.0)
        
        return update
    }
    
}
