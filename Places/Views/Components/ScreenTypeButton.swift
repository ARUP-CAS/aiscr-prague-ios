//
//  ScreenTypeButton.swift
//  Places
//
//  Created by Matěj Novák on 22/11/2018.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit

class ScreenTypeButton: UIButton {

    var screenType:ScreenType = .list {
        didSet {
                self.setTitle(self.screenType.rawValue.loc, for: .normal)
                self.setImage(UIImage(named: self.screenType.rawValue), for: .normal)
           
        }
    }

}
