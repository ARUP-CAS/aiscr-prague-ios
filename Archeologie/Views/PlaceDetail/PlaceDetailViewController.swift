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
import YouTubePlayer

class PlaceDetailViewController: BaseViewController {
    
    
    
    //    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var gpsLabel: UILabel!
    @IBOutlet weak var mapContainer: UIView!
    @IBOutlet weak var mainStack: UIStackView!
    @IBOutlet weak var linkButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var gallery:KFImageViewer!
    var mapView:GMSMapView!
    @IBOutlet weak var galleryView: UIView!
    
    
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
        //        setupNavBar()
        setupPlace()
        addMap()
        
        linkButton.layer.borderWidth = 1
        linkButton.layer.borderColor = Config.Color.primary.cgColor
        
        
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func close(_ sender: Any) {
        if navigationController?.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
            
        }
    }
    
    private func setupPlace() {
        
        self.configureGallery()
        self.title = place.title
        self.addressLabel.text = place.address
        //        self.authorsLabel.text = place.implementer
        self.gpsLabel.text = "\(place.latitude), \(place.longitude)"
        self.aboutLabel.attributedText = place.text.htmlAttributed
        
        place.videos.forEach{ video in
            
            
            if let url = try? video.urlVideo?.asURL() {
                let player = YouTubePlayerView()
                player.heightAnchor.constraint(equalToConstant: 210).isActive = true
                
                mainStack.insertArrangedSubview(player, at: mainStack.arrangedSubviews.count-1)
                player.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor, constant: 0).isActive = true
                player.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor, constant: 0).isActive = true
                player.loadVideoURL(url)
            }
        }
        
        PlacesService.service.locations.bind(to: collectionView.rx.items(cellIdentifier: "carouselCell")) { _, model, cell in
            if let cell = cell as? PlaceCollectionViewCell {
                cell.place = model
                
                cell.rx.tapGesture().when(.recognized).asObservable().subscribe{ (tap) in
                    
                    if let placeViewController = self.storyboard?.instantiateViewController(identifier: "placeDetail") as? PlaceDetailViewController {
                        placeViewController.place = model
                        self.navigationController?.show(placeViewController, sender: nil)
                    }
                    
                }.disposed(by: cell.disposeBag)
            }
        }.disposed(by: disposeBag)
        
        
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
            
            mapView.topAnchor.constraint(equalTo: mapContainer.topAnchor).isActive = true
            mapView.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor).isActive = true
            
            
            self.mapView.dataSource = self
            
            
            self.mapView.isMyLocationEnabled = true
            if let styleUrl = Bundle.main.url(forResource: "18_PBK_mapa-JSON_v02", withExtension: "json"), let style = try? GMSMapStyle(contentsOfFileURL: styleUrl) {
                self.mapView.mapStyle = style
            }
            let coordinate = place.coordinate
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 5))
            self.mapView.clusterManager.annotations = [Annotation(id: place.id, coordinate: coordinate)]
            
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
        let photos = place.images.compactMap({KingfisherSource(urlString: $0.url)})
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
    private func openGallery(atItem:Int = 0) {
        
        galleryBag = DisposeBag()
        
        let photos = place.images.compactMap({KingfisherSource(urlString: $0.url )})
        let galleryController = gallery.presentFullScreenController(from: self.navigationController ?? self)
        galleryController.modalPresentationStyle = .fullScreen
        galleryController.view.rx.swipeGesture(.down).when(.recognized).subscribe { (_) in
            galleryController.dismiss(animated: true, completion: nil)
        }.disposed(by: galleryBag)
        
    }
    
    @IBAction func openLink(_ sender: Any) {
        if let url = try? place.externalLink.asURL() {
            UIApplication.shared.open(url)
        }
    }
    
}
extension PlaceDetailViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        
        return true
    }
}

extension PlaceDetailViewController:CKClusterManagerDelegate, GMSMapViewDataSource,GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let location = place.coordinate
        let locationString = "\(location.latitude),\(location.longitude)"
        guard let url = URL(string: "\(Config.mapQueryURL)\(locationString)") else {return}
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        
        //        self.masterVC?.selectedPlace = self.place
        //        self.navigationController?.dismiss(animated: true, completion: nil)
        
        
    }
    
    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        let marker = Marker()
        marker.position = cluster.coordinate
        //        if let color = PlacesService.service.tags.value.first(where: {$0.title == place.filter})?.color {
        //            marker.color = UIColor(hexString: color)
        //        }
        marker.color = Config.Color.primary
        marker.isActive = true
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        return marker
    }
}
