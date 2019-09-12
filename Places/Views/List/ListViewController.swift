//
//  ListViewController.swift
//  Places
//
//  Created by Matěj Novák on 20.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import RxGesture
import Hero
class ListViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    var endEditing:(()->Void)?
    var topMargin:CGFloat = 115
    var masterVC:SearchViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tableTapped))
        self.tableView.backgroundView = UIView()
        self.tableView.backgroundView?.addGestureRecognizer(tap)
        
        setupRX()
        //        self.tableView.backgroundView = UIView()
    }
    func setTopMargin(top:CGFloat) {
        self.topMargin = top
        if self.topConstraint != nil {
            self.topConstraint.constant = top
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func tableTapped() {
        endEditing?()
    }
    private func setupRX () {
        
        
        PlacesService.service.places.asObservable().bind(to: self.tableView.rx.items(cellIdentifier:"placeCell", cellType: ListTableViewCell.self)) { index, model,cell in
            
            cell.place = model
                cell.place.tags = PlacesService.service.getSortedTags(for: cell.place)

            }.disposed(by: disposeBag)
        
        self.tableView.rx.modelSelected(Place.self).bind { (place) in
            self.masterVC?.showPlace(place: place)
            }.disposed(by: disposeBag)
        
        self.tableView.rx.didScroll.asObservable().subscribe { (_) in
            self.endEditing?()
        }.disposed(by: disposeBag)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setTopMargin(top: self.topMargin)
    }

}
