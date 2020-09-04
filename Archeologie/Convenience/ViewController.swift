//
//  ViewController.swift
//  accolade
//
//  Created by Matěj Novák on 20.04.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit

extension UIViewController {
    var topController:UIViewController {
        var tp = self
        while let presentedViewController = tp.presentedViewController {
            tp = presentedViewController
        }
        return tp
    }
    
    func getPresented() -> UIViewController? {
        var tp:UIViewController = self
        if let controller = tp as? UINavigationController , let c = controller.topViewController?.getPresented(){
            tp = c
            
        } else if let controller = tp as? UITabBarController , let c = controller.selectedViewController?.getPresented() {
            tp = c
        }  else if let c = tp.presentedViewController {
            tp = c
        }
        return tp
    }
}
