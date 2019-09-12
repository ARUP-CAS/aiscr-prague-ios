//
//  SearchViewController.swift
//  Places
//
//  Created by Matěj Novák on 29.06.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift

protocol SearchViewControllerDelegate {
    func onSearch()
}


class SearchViewController: BaseViewController {
    
    var delegate:SearchViewControllerDelegate?
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet var screenTypeButton: ScreenTypeButton!
    @IBOutlet weak var searchStack: UIStackView!
    @IBOutlet weak var tagsScroll: UIScrollView!
    @IBOutlet weak var tagsStack: UIStackView!
    //    @IBOutlet weak var resultScroll: UIScrollView!
    //    @IBOutlet weak var resultsStack: UIStackView!
    @IBOutlet weak var searchButton: UIButton!
    var screenType:ScreenType = .map
    @IBOutlet weak var containerView: UIView!
    lazy var resultBag = DisposeBag()
    lazy var tagsBag = DisposeBag()
    
    lazy var mapViewController:MapViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
    lazy var listViewController:ListViewController = self.storyboard?.instantiateViewController(withIdentifier: "listViewController") as! ListViewController
    
    var tagsSet:NSMutableOrderedSet = NSMutableOrderedSet()
    
    var endEditing:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showMap()
        self.tagsScroll.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.endEditing = {
            self.searchField.endEditing(true)
            
        }
        self.searchStack.addShadow()
        
        self.searchField.rx.controlEvent(.editingDidBegin).asDriver().drive(onNext:({ _ in
            //                self.displayResults()
            self.delegate?.onSearch()
        })).disposed(by: disposeBag)
        
        self.searchField.rx.controlEvent(.editingDidEnd).asDriver().drive(onNext: { (_) in
            //            self.displayResults(show: false)
        }).disposed(by: disposeBag)
        
        self.searchField.rx.text.asDriver().throttle(5).distinctUntilChanged().drive(onNext:{ (string) in
            print(string)
            let tags = self.tagsSet.map{$0} as? [Int]
            PlacesService.service.loadPlaces(query: string, tags: tags)
            
            }).disposed(by: disposeBag)
        
        self.searchField.rx.controlEvent(.editingDidEndOnExit).asDriver().drive(onNext:{ _ in
            let tags = self.tagsSet.map{$0} as? [Int]
            PlacesService.service.loadPlaces(query: self.searchField.text, tags: tags)
            
        }).disposed(by: disposeBag)
        
        PlacesService.service.tags.asDriver().drive(onNext: { (tagCategories) in
            
            //            self.setTagCategories(tagCategories: tagCategories)
            self.tagsBag = DisposeBag()
            if let tags = tagCategories.first?.tags {
                self.displayTags(tags: tags)
            }
        }).disposed(by: disposeBag)

    }

    private func displayTags(tags:[Tag]) {
        self.tagsStack.removeAllArrangedSubviews()
        self.tagsSet = []
        tags.forEach { (tag) in
            
            let tagButton = TagButton(color: UIColor(hexString: tag.color ?? "FFFF00"))
            tagButton.setTitle(tag.title, for: .normal)
            tagButton.isSelected = true
            tagButton.id = tag.id
            tagButton.heightAnchor.constraint(equalToConstant: 35).isActive = true
            self.tagsSet.add(tagButton)
            self.tagsStack.addArrangedSubview(tagButton)
            
            tagButton.rx.tapGesture().when(.recognized).bind(onNext: { (gesture) in
                
                let categories = self.tagsSet.compactMap{$0 as? TagButton}
                if categories.count == categories.filter({$0.isSelected}).count {
                    categories.forEach{$0.isSelected = false}
                }
                

                tagButton.isSelected = !tagButton.isSelected
                
                if categories.filter({$0.isSelected}).count == 0 {
                    categories.forEach{$0.isSelected = true}
                    
                }
                PlacesService.service.loadPlaces(query: self.searchField.text, tags: self.tagsSet.filter({ (selectedTag) -> Bool in
                    if let selectedTag = selectedTag as? TagButton, selectedTag.isSelected{
                        return true
                    }
                    return false
                }).compactMap({ (selectedTag) -> Int? in
                    if let selectedTag = selectedTag as? TagButton, selectedTag.isSelected{
                        return selectedTag.id
                    }
                    return nil
                }))
                
            }).disposed(by: tagsBag)
            
        }
    }
    
    @IBAction func toggleView(_sender:UIButton) {
        if screenType == .list {
            self.showMap()
        } else if screenType == .map {
            self.showList()
        }
//        setNeedsStatusBarAppearanceUpdate()

    }
    private func showMap() {
        self.containerView.subviews.forEach {$0.removeFromSuperview()}
        mapViewController.removeFromParent()
        listViewController.removeFromParent()
        self.screenType = .map
        self.screenTypeButton.screenType = .list
        addChild(mapViewController)
        mapViewController.view.frame = containerView.bounds
        mapViewController.masterVC = self

        self.containerView.insertSubview(mapViewController.view, at: 0)
        mapViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        mapViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        mapViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        mapViewController.view.heightAnchor.constraint(equalTo: containerView.heightAnchor, multiplier: 1).isActive = true
        mapViewController.didMove(toParent: self)
        self.delegate = mapViewController
        mapViewController.onMapTapped = {
            self.endEditing?()
        }
        
    }
    func showPlace(place:Place) {
        if let nav = self.storyboard?.instantiateViewController(withIdentifier: "placeDetailNav") as? UINavigationController, let placeDetailViewController = nav.viewControllers.first as? PlaceDetailViewController {
            nav.modalPresentationStyle = .overCurrentContext
            nav.hero.isEnabled = true
            nav.hero.modalAnimationType = .selectBy(presenting: .cover(direction: .up), dismissing: .uncover(direction: .down))
            nav.modalPresentationCapturesStatusBarAppearance = true
            placeDetailViewController.place = place
            placeDetailViewController.place.tags = PlacesService.service.getSortedTags(for: place)
//            statusBar = .lightContent
//            setNeedsStatusBarAppearanceUpdate()
            self.show(nav, sender: nil)
        }
    }

    private func showList() {
        mapViewController.removeFromParent()
        listViewController.removeFromParent()
        self.screenType = .list
        self.screenTypeButton.screenType = .map
//        self.delegate = listViewController

        self.containerView.subviews.forEach {$0.removeFromSuperview()}
        self.containerView.insertSubview(listViewController.view, at: 0)
        listViewController.endEditing = {
            self.endEditing?()
        }
        listViewController.masterVC = self
        listViewController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        listViewController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        listViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        listViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        //        setTags(tags: self.selectedTags)
        let rect = tagsScroll.convert(tagsScroll.bounds, to: view)
        self.listViewController.setTopMargin(top: rect.origin.y+rect.size.height)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }

}

