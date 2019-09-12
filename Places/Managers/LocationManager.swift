//
//  LocationManager.swift
//  Places
//
//  Created by Matěj Novák on 22.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
class LocationManager:NSObject,CLLocationManagerDelegate {
    
    static var shared:LocationManager = LocationManager()
    lazy fileprivate var locationManager:CLLocationManager = CLLocationManager()

    var currentLocation:Observable<CLLocationCoordinate2D?> {
        
        locationManager.startUpdatingLocation()
        return locationManager.rx.didUpdateLocations.map{$0.first?.coordinate}.do(onNext: { (_) in
            self.locationManager.stopUpdatingLocation()
        })
    }
}
