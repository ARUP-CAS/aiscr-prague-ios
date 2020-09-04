//
//  View.swift
//  dameparty
//
//  Created by Matěj Novák on 24.10.17.
//  Copyright © 2017 Visualio. All rights reserved.
//

import UIKit

extension UIView {
    func copyView<T: UIView>() -> T {
//        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
        do {
        let data = try NSKeyedArchiver.archivedData(withRootObject:self, requiringSecureCoding:false)
            return try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? T ?? T())
        } catch {
            return T()
        }
    }
    func removeAllSubviews() {
        subviews.forEach { (subView) in
            subView.removeFromSuperview()
        }
    }
    func roundView() {
        layer.cornerRadius = bounds.height/2
        layer.masksToBounds = true
    }
    
    var bottomPosition:CGFloat {
        return frame.origin.y+frame.size.height
    }
}


enum GradientDirection {
    case leftToRight
    case rightToLeft
    case topToBottom
    case bottomToTop
    case bottomLeftToTopRight
}

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
    
    @IBInspectable var cRadius:CGFloat{
        set {
            self.layer.cornerRadius = newValue
            self.layer.masksToBounds = newValue > 0
            self.clipsToBounds = newValue > 0
        }
        get {
            return self.layer.cornerRadius
        }
    }
    

    func removeActivity() {
        subviews.filter{$0.tag == 666}.forEach { (view) in
            view.removeFromSuperview()
        }
    }
    
    func gradientBackground(from color1: UIColor, to color2: UIColor, direction: GradientDirection) {
        self.layer.sublayers?.removeAll()
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [color1.cgColor, color2.cgColor]
        
        switch direction {
        case .leftToRight:
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        case .rightToLeft:
            gradient.startPoint = CGPoint(x: 1.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 0.0, y: 0.5)
        case .bottomToTop:
            gradient.startPoint = CGPoint(x: 0.5, y: 1.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.0)
        case .bottomLeftToTopRight:
            gradient.startPoint = CGPoint(x: 0, y: 1)
            gradient.endPoint = CGPoint(x: 1, y: 0)
        default:
            break
        }
        
        self.layer.insertSublayer(gradient, at: 0)
    }
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
    }
    
    func roundEdges() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        self.addSubview(blurEffectView)
    }
    func removeBlurEffect() {
        let blurredEffectViews = self.subviews.filter{$0 is UIVisualEffectView}
        blurredEffectViews.forEach{ blurView in
            blurView.removeFromSuperview()
        }
    }
    
    func showActivity(style:UIActivityIndicatorView.Style, backgroundColor:UIColor = .clear) {
        let view = UIView(frame: bounds)
        view.backgroundColor = backgroundColor
        view.tag = 666
        let activity = UIActivityIndicatorView(style: style)
        activity.center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        activity.startAnimating()
        view.addSubview(activity)
        addSubview(view)
    }

}


extension UILabel {
    func sizeToFitHeight() {
        let maxHeight : CGFloat = CGFloat.greatestFiniteMagnitude
        let size = CGSize.init(width: self.frame.size.width, height: maxHeight)
        let rect = self.attributedText?.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        var frame = self.frame
        frame.size.height = (rect?.size.height)!
        self.frame = frame
    }
}

class RoundedView:UIView {
    @IBInspectable var cornerRadius:CGFloat = 0 {
        didSet {
            self.cRadius = cornerRadius
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
extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - thickness, width: self.frame.width, height: thickness)
            break
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.frame.height)
            break
        case UIRectEdge.right:
            border.frame = CGRect(x: self.frame.width - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        default:
            //For Center Line
            border.frame = CGRect(x: self.frame.width/2 - thickness, y: 0, width: thickness, height: self.frame.height)
            break
        }
        
        border.backgroundColor = color.cgColor;
        self.addSublayer(border)
    }
    

}
class NestedStackView: UIStackView {
    override var intrinsicContentSize:CGSize {
        var size = super.intrinsicContentSize
        
        for view in arrangedSubviews {
            let viewSize = view.intrinsicContentSize
            
            if axis == .vertical {
                size.width = max(viewSize.width, size.width)
            } else {
                size.height = max(viewSize.height, size.height)
            }
        }
        
        return size
    }
    
    override func layoutSubviews() {
        invalidateIntrinsicContentSize()
        super.layoutSubviews()
    }
}
