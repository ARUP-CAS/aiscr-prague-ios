//
//  AlignedLabel.swift
//  Places
//
//  Created by Matěj Novák on 26/11/2018.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit

  class AlignedLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let labelStringSize = stringTextAsNSString.boundingRect(with: CGSize(width: self.frame.width,height: CGFloat.greatestFiniteMagnitude),
                                                                    options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                                    attributes: [NSAttributedString.Key.font: font],
                                                                    context: nil).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:self.frame.height-2))
        } else {
            super.drawText(in: rect)
        }
    }
//    override func prepareForInterfaceBuilder() {
//        super.prepareForInterfaceBuilder()
//        layer.borderWidth = 1
//        layer.borderColor = UIColor.black.cgColor
//    }
    
    
}
