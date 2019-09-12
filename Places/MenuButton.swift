//
//  MenuButton.swift
//  Places
//
//  Created by Matěj Novák on 09.07.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit


@IBDesignable class MenuButton: UIButton {

    @IBInspectable var selectedBackgroundColor:UIColor = UIColor.black {
        didSet {
            backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor

        }
    }
    @IBInspectable var normalBackgroundColor:UIColor = UIColor.white {
        didSet {
            backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
            
        }
    }
    
    
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? selectedBackgroundColor : normalBackgroundColor
        }
    }

}
