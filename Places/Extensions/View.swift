//
//  View.swift
//  Places
//
//  Created by Matěj Novák on 06.09.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit


extension UIView {
    func addShadow(rasterize:Bool = true) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        if rasterize {
        self.layer.shouldRasterize = true
        }
    }
    
    @IBInspectable var cornerRadius:CGFloat{
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
            self.clipsToBounds = newValue > 0
        }
        get {
            return self.layer.cornerRadius
        }
    }
    
}
