//
//  Annotation.swift
//  Places
//
//  Created by Matěj Novák on 29.06.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
import GoogleMaps
import ClusterKit

class Annotation:MKPointAnnotation {
    var id:Int
    init(id:Int, coordinate:CLLocationCoordinate2D) {
        self.id = id
        super.init()
        self.coordinate = coordinate
    }
}
class Marker: GMSMarker {
    var id:Int!
    var isActive = false {
        didSet {
            draw()
        }
    }
    
    var color:UIColor = Config.Color.mainYellow{
        didSet {
            draw()
        }
    }
    
    fileprivate func draw() {
        let label = AlignedLabel(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        label.text = "+"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 14
        label.backgroundColor = color
        label.layer.masksToBounds = true
        if !isActive {
            iconView = label
            
        } else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
            view.layer.cornerRadius = 26
            view.backgroundColor = color.withAlphaComponent(0.3)
            let innerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            innerView.layer.cornerRadius = 20
            innerView.backgroundColor = color.withAlphaComponent(0.3)
            label.center = CGPoint(x: innerView.bounds.width/2, y: innerView.bounds.height/2)
            innerView.center = CGPoint(x: view.bounds.width/2, y: view.bounds.height/2)
            
            innerView.addSubview(label)
            view.addSubview(innerView)
            iconView = view
        }
        
    }
    
}
