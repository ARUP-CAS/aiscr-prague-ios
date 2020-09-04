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
    
    func showActivity(style:UIActivityIndicatorView.Style, backgroundColor:UIColor = .clear) {
        let view = UIView(frame: bounds)
        view.backgroundColor = backgroundColor
        view.tag = 666
        let activity = UIActivityIndicatorView(style: style)
        activity.color = .black
        activity.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        activity.startAnimating()
        
        view.addSubview(activity)
        addSubview(view)
    }
    
    func removeActivity() {
        subviews.filter{$0.tag == 666}.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
}
