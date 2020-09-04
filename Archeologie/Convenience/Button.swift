//
//  FixedButton.swift
//  accolade
//
//  Created by Matěj Novák on 13.02.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit

class FixedButton: UIButton {
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = self.titleLabel?.frame
        frame?.size.height = self.bounds.size.height
        frame?.origin.y = self.titleEdgeInsets.top
        if let frame = frame {
            self.titleLabel?.frame = frame
        }
    }
}

class RoundButton:UIButton {
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
           self.layer.cornerRadius = cornerRadius
        }
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layer.cornerRadius = cornerRadius == 0 ? self.bounds.height/2 : cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = cornerRadius == 0 ? self.bounds.height/2 : cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
}

class BorderButton:RoundButton {
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor.cgColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderWidth = 1
        self.layer.borderColor = self.tintColor.cgColor
    }
}
