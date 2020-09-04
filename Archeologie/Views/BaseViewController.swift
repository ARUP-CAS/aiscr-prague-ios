//
//  BaseViewController.swift
//  Places
//
//  Created by Matěj Novák on 29.06.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift


class BaseViewController: UIViewController {

    lazy var disposeBag:DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let value = UIInterfaceOrientation.portrait.rawValue
        UIView.animate(withDuration: 0) {
            UIDevice.current.setValue(value, forKey: "orientation")

        }
        
    }
   
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

}


class NavController:UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setNeedsStatusBarAppearanceUpdate()

    }
}
