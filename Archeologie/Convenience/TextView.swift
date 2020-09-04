//
//  TextView.swift
//  accolade
//
//  Created by Matěj Novák on 19.04.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
extension UITextView {
    func sizeToFitAttributedString() {
        let textSize = self.attributedText.size()
        let viewSize = CGSize(width: textSize.width + self.firstCharacterOrigin.x * 2, height: textSize.height + self.firstCharacterOrigin.y * 2)
        self.bounds.size = self.sizeThatFits(viewSize)
    }
    var sizeThatFitsAttributedString:CGSize {
        let textSize = self.attributedText.size()
        let viewSize = CGSize(width: textSize.width + self.firstCharacterOrigin.x * 2, height: textSize.height + self.firstCharacterOrigin.y * 2)
        return self.sizeThatFits(viewSize)
        
    }
    private var firstCharacterOrigin: CGPoint {
        if self.text.lengthOfBytes(using: .utf8) == 0 {
            return .zero
        }
        let range = self.textRange(from: self.position(from: self.beginningOfDocument, offset: 0)!,
                                   to: self.position(from: self.beginningOfDocument, offset: 1)!)
        return self.firstRect(for: range!).origin
        
    }
}
