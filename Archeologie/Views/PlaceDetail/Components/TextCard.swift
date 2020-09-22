//
//  TextCard.swift
//  Archeologie
//
//  Created by Matěj Novák on 14/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit

class TextCard:UIView {
    @IBOutlet weak var textView:UITextView!
    
    var text:String = "" {
        didSet {
            self.textView.attributedText = text.htmlAttributed
        }
    }
}
