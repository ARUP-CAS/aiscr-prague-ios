//
//  PlaceDetailViewController.swift
//  Places
//
//  Created by Matěj Novák on 31.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift
import RxDataSources
import KFImageViewer
import Hero
import GoogleMaps

class PlaceDetailViewController: BaseViewController {
    
    
    
    //    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainStack: UIStackView!
    
    var gallery:KFImageViewer!
    var mapView:GMSMapView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    lazy var galleryBag:DisposeBag = DisposeBag()
    var place:Location!
    var swipeGesture:UISwipeGestureRecognizer?
    
    var panGR : UIPanGestureRecognizer!
    // Detect current direction.
    var progressBool : Bool = false
    // Hero dismiss bool to track dismissal
    var dismissBool : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = place.title
        scrollView.delegate = self
        populateStack()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    private func populateStack() {
        var cards:[UIView?] = []
        //        cards.append(contentsOf: place.videos.map{self.prepare(video: $0)})
        //        cards.append(self.prepare(text: place.text))
        
        place.content.forEach { (content) in
            switch content.content {
            case .text(let texts):
                cards.append(contentsOf: texts.map{self.prepare(text: $0)})
            case .video(let videos):
                cards.append(contentsOf: videos.map{self.prepare(video: $0)})
            case .image(let images):
                cards.append(contentsOf: images.map{self.prepare(image: $0)})
            default:
                return
            }
            
        }
        self.mainStack.removeAllArrangedSubviews()
        self.mainStack.removeAllSubviews()
        
        cards.compactMap({$0}).forEach { (card) in
            mainStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor, multiplier: 1).isActive = true
            
        }
        pageControl.numberOfPages = cards.count

    }
    
    private func prepare(image:Image) -> ImageCard? {
        let card = Bundle.main.loadNibNamed("ImageCard", owner: self, options: nil)?.first as? ImageCard
        card?.image = image
        return card
        
    }
    private func prepare(video:Video) -> VideoCard? {
        let card = Bundle.main.loadNibNamed("VideoCard", owner: self, options: nil)?.first as? VideoCard
        card?.video = video
        return card
        
    }
    private func prepare(text:Text) -> TextCard? {
        let card = Bundle.main.loadNibNamed("TextCard", owner: self, options: nil)?.first as? TextCard
        card?.text = text.text
        return card
        
    }
    
    @IBAction func close(_ sender: Any) {
        if navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
}

extension PlaceDetailViewController:UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = self.scrollView.contentOffset.x / scrollView.frame.size.width
        self.pageControl.currentPage = Int(currentPage)
    }
}
