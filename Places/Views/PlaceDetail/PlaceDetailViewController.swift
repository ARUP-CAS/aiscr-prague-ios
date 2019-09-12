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
import KFImageViewer
import Hero
import GoogleMaps
class PlaceDetailViewController: BaseViewController {
    
    
    
    //    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagColorView: UIView!
    @IBOutlet weak var tagTitleLabel: UILabel!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapContainer: UIView!
    var gallery:KFImageViewer!
    var mapView:GMSMapView!
    @IBOutlet weak var galleryView: UIView!
    
    
    lazy var galleryBag:DisposeBag = DisposeBag()
    var place:Place!
    var swipeGesture:UISwipeGestureRecognizer?
    
    var panGR : UIPanGestureRecognizer!
    // Detect current direction.
    var progressBool : Bool = false
    // Hero dismiss bool to track dismissal
    var dismissBool : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(pan))
        panGR.delegate = self
        view.backgroundColor = UIColor.white
        view.addGestureRecognizer(panGR)
        self.galleryView.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
            self.openGallery()
            }.disposed(by: self.disposeBag)
        
        self.view.rx.swipeGesture(.down) { (gesture, delegate) in
            
            self.swipeGesture = gesture
            gesture.require(toFail:self.scrollView.panGestureRecognizer)
            }.when(.recognized).asObservable().subscribe { (_) in
                
                self.navigationController?.dismiss(animated: true, completion: nil)
                
            }.disposed(by: disposeBag)
        
        setupNavBar()
        setupPlace()
        addMap()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func close(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupPlace() {
        //        if let urlString = place.photos?.first?.url, let url = try? urlString.asURL() {
        //            titleImageView.kf.setImage(with: url)
        //        }
        self.configureGallery()
        self.placeTitleLabel.text = place.title
        self.addressLabel.text = place.address
        self.authorsLabel.text = PlacesService.service.getSortedTags(for: place).dropFirst().compactMap({$0.title}).joined(separator: ", ")
        self.aboutLabel.attributedText = place.text?.htmlAttributed
        
        
        if let tag = PlacesService.service.getSortedTags(for: place).first {
            self.tagTitleLabel.text = tag.title
            if let color = tag.color {
                self.tagColorView.backgroundColor = UIColor(hexString: color)
            }
        }
        
        
    }
    private func addMap() {
        
        if mapView == nil {
            mapView = GMSMapView(frame: mapContainer.bounds)
            mapView.delegate = self
            mapView.layer.cornerRadius = 3
            mapView.settings.scrollGestures = false
            mapView.settings.zoomGestures = false
            mapView.settings.rotateGestures = false
            mapView.settings.tiltGestures = false
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapContainer.addSubview(mapView)
            
            //            mapView.snp.makeConstraints { (make) in
            //                make.top.equalTo(view.snp.top)
            //                make.bottom.equalTo(view.snp.bottom)
            //                make.left.equalTo(view.snp.left)
            //                make.right.equalTo(view.snp.right)
            //            }
            //
            mapView.topAnchor.constraint(equalTo: mapContainer.topAnchor).isActive = true
            mapView.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor).isActive = true
            
            
            self.mapView.dataSource = self
            
            
            self.mapView.isMyLocationEnabled = true
            if let styleUrl = Bundle.main.url(forResource: "style", withExtension: "json"), let style = try? GMSMapStyle(contentsOfFileURL: styleUrl) {
                self.mapView.mapStyle = style
            }
            if let coordinate = place.location?.coordinate {
                self.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 15))
                self.mapView.clusterManager.annotations = [Annotation(id: place.id, coordinate: coordinate)]
            }
        }
        
    }
    
    private func setupNavBar() {
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 20.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 10.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.3
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func configureGallery() {
        if let photos = place.photos?.compactMap({KingfisherSource(urlString: $0.url ?? "")}) {
            gallery = KFImageViewer(frame: galleryView.bounds)
            gallery.setImageInputs(photos)
            gallery.contentScaleMode = .scaleAspectFill
            gallery.preload = .fixed(offset: 1)
            galleryView.addSubview(gallery)
            gallery.topAnchor.constraint(equalTo: galleryView.topAnchor).isActive = true
            gallery.bottomAnchor.constraint(equalTo: galleryView.bottomAnchor).isActive = true
            gallery.leadingAnchor.constraint(equalTo: galleryView.leadingAnchor).isActive = true
            gallery.trailingAnchor.constraint(equalTo: galleryView.trailingAnchor).isActive = true
            gallery.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
        }
    }
    private func openGallery(atItem:Int = 0) {
        
        galleryBag = DisposeBag()
        
        if let photos = place.photos?.compactMap({KingfisherSource(urlString: $0.url ?? "")}) {
            let galleryController = gallery.presentFullScreenController(from: self)
            
            
            galleryController.view.rx.swipeGesture(.down).when(.recognized).subscribe { (_) in
                galleryController.dismiss(animated: true, completion: nil)
                }.disposed(by: galleryBag)
        }
    }
    
    //    @IBAction func showInfo(_ sender: Any) {
    //
    //        if infoViewController.place == nil {
    //            infoViewController.place = self.place
    //        }
    //        containerStack.arrangedSubviews.forEach{$0.removeFromSuperview()}
    //        containerStack.subviews.forEach{$0.removeFromSuperview()}
    //        containerStack.addArrangedSubview(infoViewController.view)
    //
    //        self.infoButton.isSelected = true
    //        self.galleryButton.isSelected = false
    //    }
    //    @IBAction func showGallery(_ sender: Any) {
    //
    //        if galleryViewController.place == nil {
    //            galleryViewController.place = self.place
    //        }
    //
    //        galleryViewController.superViewController = self
    //
    //        containerStack.arrangedSubviews.forEach{$0.removeFromSuperview()}
    //        containerStack.subviews.forEach{$0.removeFromSuperview()}
    //        containerStack.addArrangedSubview(galleryViewController.view)
    //
    //        self.infoButton.isSelected = false
    //        self.galleryButton.isSelected = true
    //
    //        self.swipeGesture?.require(toFail: galleryViewController.collectionView.panGestureRecognizer)
    //    }
    //
    
}
extension PlaceDetailViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        return true
    }
}

extension PlaceDetailViewController:CKClusterManagerDelegate, GMSMapViewDataSource,GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        guard let location = place.location else {return}
        let locationString = "\(location.latitude),\(location.longitude)"
        guard let url = URL(string: "\(Config.mapQueryURL)\(locationString)") else {return}
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        let marker = Marker()
        marker.position = cluster.coordinate
        marker.color = UIColor(hexString: PlacesService.service.getSortedTags(for: place).first?.color ?? "")
        marker.isActive = true
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        return marker
    }
}
