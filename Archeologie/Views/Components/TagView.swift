//
//  TagView.swift
//  Places
//
//  Created by Matěj Novák on 26.09.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
class TagView: UIView {
    lazy var heightConstraint = self.heightAnchor.constraint(equalToConstant: 10)
    var tags:[Tag] = []
    init(tags:[Tag]) {
        super.init(frame:CGRect.zero)
        self.tags = tags
        createTags(tags: tags)
        
        
    }
    func setTags(tags:[Tag]) {
        self.tags = tags
        createTags(tags: tags)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        createTags(tags: self.tags)
    }
    private func createTags(tags:[Tag]) {
        
        subviews.forEach({$0.removeFromSuperview()})
        var yPos:CGFloat = 0, xPos:CGFloat = 0
        var lastHeight:CGFloat = 0
        tags.forEach { (tag) in
            let tagButton = UIButton(type: .system)
            tagButton.frame = CGRect(x: xPos, y: yPos, width: 200, height: 44)
            tagButton.isSelected = true
            tagButton.tintColor = UIColor(hexString: tag.color ?? "#0000FF")
            tagButton.setTitle(tag.title, for: .normal)
            tagButton.isUserInteractionEnabled = false
            tagButton.sizeToFit()
            xPos += 12 + tagButton.frame.width
            
            if xPos - 12 > frame.size.width {
                xPos = 0
                yPos += tagButton.frame.origin.y + tagButton.frame.size.height + 4
                tagButton.frame = CGRect(x: xPos, y: yPos, width: tagButton.frame.width, height: tagButton.frame.height)
                xPos += 12 + tagButton.frame.width

            }
            lastHeight = tagButton.frame.height

            addSubview(tagButton)
            
        }

        self.heightConstraint.constant = yPos+lastHeight

    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        heightConstraint.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
