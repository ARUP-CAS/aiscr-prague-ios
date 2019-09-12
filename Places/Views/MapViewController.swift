//
//  ViewController.swift
//  Places
//
//  Created by Matěj Novák on 28.05.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
import RxSwift
import RxCocoa
import ClusterKit


class MapViewController: BaseViewController {
    
    @IBOutlet weak var selectedPlaceView: UIView!
    @IBOutlet weak var selectedPlaceImage: UIImageView!
    @IBOutlet weak var selectedPlaceTitle: UILabel!
    @IBOutlet weak var selectedPlaceAddress: UILabel!
    @IBOutlet weak var selectedPlaceCategory: UILabel!
    @IBOutlet weak var selectedPlaceCategoryColor: UIView!
    @IBOutlet weak var mapContainer: UIView!
    
    var selectedPlace:Place? {
        didSet {
            self.markers.values.forEach{$0.isActive = false}
            
            if let place = selectedPlace {
                selectedPlaceBag = DisposeBag()
                selectedPlaceTitle.text = place.title
                selectedPlaceAddress.text = place.address?.components(separatedBy: ",").first
                
                if let photo = place.photos?.first?.url, let url = try? photo.asURL() {
                    selectedPlaceImage.kf.setImage(with: url)
                }
                if let tag  = PlacesService.service.getSortedTags(for: place).first {
                    selectedPlaceCategoryColor.backgroundColor = UIColor(hexString: tag.color ?? "")
                    selectedPlaceCategory.text = tag.title
                    
                }
                selectedPlaceView.isHidden = false
                selectedPlaceView.rx.tapGesture().when(.recognized).asObservable().subscribe { (event) in
                    self.masterVC?.showPlace(place:place)
                    
                    }.disposed(by: selectedPlaceBag)
            } else {
                selectedPlaceView.isHidden = true
            }
        }
    }
    
    lazy var selectedPlaceBag:DisposeBag = DisposeBag()
    
    
    var masterVC:SearchViewController?
    
    var mapView:GMSMapView!
    var places:BehaviorRelay<[Place]> = BehaviorRelay<[Place]>(value: [])
    var annotations:[Int:Annotation] = [:]
    var markers:[Int:Marker] = [:]
    
    var onMapTapped:(()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        setupRX()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    private func setupRX () {
        
        PlacesService.service.places.asObservable().bind(to: places).disposed(by: disposeBag)
        
        places.asObservable().subscribe { (places) in
            
            self.annotations = [:]
            
            places.element?.forEach({ (place) in
                
                if let coordinate = place.location?.coordinate {
                    let annotation = Annotation(id: place.id, coordinate: coordinate)
                    
                    self.annotations[place.id] = annotation
                }
                
            })
            
            self.mapView.clusterManager.annotations = self.annotations.values.map({$0})
            self.zoomToAllParks()
            }.disposed(by: disposeBag)
        
    }
    
    private func addMap() {
        
        if mapView == nil {
            mapView = GMSMapView(frame: view.bounds)
            mapView.delegate = self
            mapView = nil
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
            
            let algo = CKNonHierarchicalDistanceBasedAlgorithm()
            algo.cellSize = 320
            self.mapView.clusterManager.algorithm = algo
            self.mapView.setMinZoom(6, maxZoom: 20)
            self.mapView.settings.myLocationButton = true
            //            self.mapView.clusterManager.marginFactor = 1
            self.mapView.dataSource = self
            self.mapView.clusterManager.delegate = self
            self.mapView.isMyLocationEnabled = true
            
            if let styleUrl = Bundle.main.url(forResource: "18_PBK_mapa-JSON_v02", withExtension: "json"), let style = try? GMSMapStyle(contentsOfFileURL: styleUrl) {
                self.mapView.mapStyle = style
            }
            LocationManager.shared.currentLocation.subscribe(onNext: { (coordinate) in
                if let coordinate = coordinate {
                    self.mapView.moveCamera(GMSCameraUpdate.setTarget(coordinate, zoom: 10))
                }
            }).disposed(by: disposeBag)
        }
        
    }
    
    
    private func zoomToAllParks() {
        let bounds = self.annotations.values.reduce(GMSCoordinateBounds()) {
            $0.includingCoordinate($1.coordinate)
        }
        let fitCamera = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 256, left: 64, bottom: 256, right: 64))
        self.mapView.animate(with: fitCamera)
    }
    
    
}

extension MapViewController:CKClusterManagerDelegate, GMSMapViewDataSource,GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        
        if cluster.count > 1 {
            let marker = Marker()
            marker.position = cluster.coordinate
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            label.text = "\(cluster.count)"
            label.font = UIFont(name: "ChaletBook-Bold", size: 18)
            label.textColor = .black
            label.textAlignment = .center
            label.backgroundColor = Config.Color.mainYellow
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 20
            
            //            let view = UIView(frame: label.frame)
            //            view.addSubview(label)
            marker.iconView = label
            
            return marker
        }
        
        let marker = Marker()
        marker.position = cluster.coordinate
        let annotation = (cluster.annotations.first as! Annotation)
        if let annotation = cluster.annotations.first as? Annotation, let place = places.value.first(where: {$0.id == annotation.id}), let color = PlacesService.service.getSortedTags(for: place).first?.color {
            
            //            marker.icon = UIImage(named: "pin")
            marker.color = UIColor(hexString: color)
            marker.isActive = place.id == selectedPlace?.id
            self.markers[place.id] = marker
            
        }
        //                    marker.color = UIColor(hexString: "000000")
        
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        return marker
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { // change 2 to desired number of seconds
            self.mapView.clusterManager.updateClustersIfNeeded()
        }
        
        
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.selectedPlace = nil
        self.onMapTapped?()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.onMapTapped?()
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cluster = marker.cluster, cluster.count > 1 {
            let fitCamera = GMSCameraUpdate.fit(cluster, with: UIEdgeInsets(top: 256, left: 64, bottom: 256, right: 64))
            self.mapView.animate(with: fitCamera)
            return true
        }
        
        if let anot = marker.cluster?.annotations.first as? Annotation, let place = places.value.first(where: {$0.id == anot.id}) {
            self.selectedPlace = place
            if let marker = marker as? Marker {
                marker.isActive = true
            }
        }
        return true
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = mapContainer.bounds
    }
}

extension MapViewController:SearchViewControllerDelegate {
    
    func onSearch() {
        print("on search")
        self.selectedPlace = nil
    }
}
