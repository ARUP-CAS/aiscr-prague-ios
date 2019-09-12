//
//  PlaceDetailGalleryViewController.swift
//  Places
//
//  Created by Matěj Novák on 31.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxGesture
import KFImageViewer
import Kingfisher
class PlaceDetailGalleryViewController: BaseViewController {
    
    @IBOutlet var collectionView:UICollectionView!
    var place:Place!
    var superViewController:UIViewController!
    lazy var galleryBag = DisposeBag()
    lazy var galleryViewerBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        if let photos = place.photos {
            Observable<[Photo]>.just(photos).bind(to: self.collectionView.rx.items(cellIdentifier:"galleryCell", cellType: PlaceDetailGalleryCollectionViewCell.self)) { index, model,cell in
                
                cell.photo = model
                cell.imageView.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
                    self.openGallery(atItem: index)
                    }.disposed(by: self.galleryBag)
                
                }.disposed(by: disposeBag)
            
            collectionView.rx.setDelegate(self).disposed(by: disposeBag)
            
        }
        
        
        
    }
    private func openGallery(atItem:Int = 0) {
        
        galleryViewerBag = DisposeBag()
        let gallery = KFImageViewer()
        
        if let photos = place.photos?.compactMap({KingfisherSource(urlString: $0.url ?? "")}) {
            gallery.setImageInputs(photos)
            gallery.setCurrentPage(atItem, animated: false)
            gallery.preload = .fixed(offset: 1)
            
            let galleryController = gallery.presentFullScreenController(from: self.superViewController)
            
            galleryController.view.rx.swipeGesture(.down).when(.recognized).subscribe { (_) in
                galleryController.dismiss(animated: true, completion: nil)
                }.disposed(by: galleryViewerBag)
            
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        galleryBag = DisposeBag()
        self.collectionView.reloadData()
        
    }
}

extension PlaceDetailGalleryViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.width/2
        return CGSize(width: size, height: size)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
