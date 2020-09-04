//
//  CLLocationCoordinate.swift
//  MSMT
//
//  Created by Matěj Novák on 30/10/2019.
//  Copyright © 2019 Matěj Novák. All rights reserved.
//

import Foundation
import GoogleMaps

extension CLLocationCoordinate2D {
    
    func isInRegion(region:GMSVisibleRegion) -> Bool {
//        CLLocationCoordinate2D topLeftCorner = /* some coordinate */, bottomRightCorner = /* some coordinate */;
//        CLLocationCoordinate2D targetCoordinate = /* some coordinate */;
//        MKMapPoint topLeftPoint = MKMapPointForCoordinate(topLeftCorner);
//        MKMapPoint bottomRightPoint = MKMapPointForCoordinate(bottomRightCorner);
//        MKMapRect mapRect = MKMapRectMake(topLeftPoint.x, topLeftPoint.y, bottomRightPoint.x - topLeftPoint.x, bottomRightPoint.y - topLeftPoint.y);
//        MKMapPoint targetPoint = MKMapPointForCoordinate(targetCoordinate);
//
//        BOOL isInside = MKMapRectContainsPoint(mapRect, targetPoint);
        
        let topLeftPoint = MKMapPoint(region.farLeft)
        let topRightPoint = MKMapPoint(region.farRight)
        let bottomLeftPoint = MKMapPoint(region.nearLeft)
        let bottomRightPoint = MKMapPoint(region.nearRight)
        
        let mapRect = MKMapRect(x: topLeftPoint.x, y: topLeftPoint.y, width: bottomRightPoint.x - topLeftPoint.x, height: bottomRightPoint.y - topLeftPoint.y)
        let targetPoint = MKMapPoint(self)
        let mapRect2 = MKMapRect(x: bottomLeftPoint.x, y: bottomLeftPoint.y, width: topRightPoint.x - bottomLeftPoint.x, height: topRightPoint.y - bottomLeftPoint.y)
        let mapRect3 = MKMapRect(x: bottomRightPoint.x, y: bottomRightPoint.y, width: topLeftPoint.x - bottomRightPoint.x, height: topLeftPoint.y - bottomRightPoint.y)
        let mapRect4 = MKMapRect(x: topRightPoint.x, y: topRightPoint.y, width: bottomLeftPoint.x - topRightPoint.x, height: bottomLeftPoint.y - topRightPoint.y)

        
        return mapRect.contains(targetPoint) || mapRect2.contains(targetPoint) || mapRect3.contains(targetPoint) || mapRect4.contains(targetPoint)
        
    }
}
