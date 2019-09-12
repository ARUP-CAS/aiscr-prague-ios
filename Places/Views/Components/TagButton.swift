//
//  TagButton.swift
//  Places
//
//  Created by Matěj Novák on 26/11/2018.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit

class TagButton: UIButton {

    var color:UIColor = Config.Color.mainYellow
    var id:Int?
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = color
            } else {
                backgroundColor = color.combine(with: .white, amount: 0.7)
            }
        }
    }
    convenience init(color:UIColor) {
        self.init()
        self.color = color
        self.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        self.backgroundColor = color
        self.layer.cornerRadius = 3
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}
