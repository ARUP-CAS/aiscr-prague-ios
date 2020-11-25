//
//  ThematicsViewController.swift
//  Archeologie
//
//  Created by Matěj Novák on 02/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import GoogleMaps
import ClusterKit
import FloatingPanel

class LocationsViewController:BaseViewController {
    
    @IBOutlet var mapContainer: UIView!
    var mapView:GMSMapView!
    
    let mapPadding:CGFloat = UIScreen.main.bounds.width < 400 ? 128 : 256
    @IBOutlet weak var scaleBar: ScaleBarView!
    @IBOutlet weak var scaleBottomConstraint: NSLayoutConstraint!
    lazy var selectedPlaceBag:DisposeBag = DisposeBag()
    
    var thematic:Thematic!
    var places:BehaviorRelay<[Location]> = BehaviorRelay<[Location]>(value: [])
    var annotations:[Int:Annotation] = [:]
    var markers:[Int:Marker] = [:]
    var pullController:LocationsPullViewController!
    var fpc: FloatingPanelController!
    lazy var fpLayout = ArchFloatingPanelLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        setupRX()
    }
    private func setupRX () {
        
        PlacesService.service.locations.asObservable().bind(to: places).disposed(by: disposeBag)
        
        places.asObservable().subscribe { (places) in
            
            self.annotations = [:]
            places.element?.filter({ place -> Bool in
                
                return place.coordinate.isInRegion(region: self.mapView.projection.visibleRegion())
                
            }).forEach({ (place) in
                
                let coordinate = place.coordinate
                let annotation = Annotation(id: place.id, coordinate: coordinate)
                
                self.annotations[place.id] = annotation
                
                
            })
            self.mapView.clusterManager.annotations = self.annotations.values.map({$0})
            delay(0.2) {
                self.zoomToAllParks()
            }
            
        }.disposed(by: disposeBag)
        
        PlacesService.service.selectedLocation.asObservable().subscribe { (event) in
            
            guard let place = event.element, self.fpc != nil else { return }
            
            self.fpLayout.fullEnabled = place != nil
            
            
            //            self.fpc.move(to: place != nil ? .full : .half, animated: true)
            self.setPlaces()
            
        }.disposed(by: disposeBag)
        
    }
    private func addMap() {
        
        if mapView == nil {
            mapView = GMSMapView(frame: view.bounds)
            mapView.delegate = self
            //            mapView = nil
            
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
            algo.cellSize = 500
            self.mapView.clusterManager.algorithm = algo
            self.mapView.setMinZoom(7, maxZoom: 18)
            self.mapView.cameraTargetBounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 50.951506094481545, longitude: 12.06298828125), coordinate: CLLocationCoordinate2D(latitude: 48.37084770238366, longitude: 18.709716796875))
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
            self.scaleBar.mapView = mapView
        }
        
    }
    func zoomToPlace(place:Location?) {
        if let place = place {
            
            self.mapView.animate(with: GMSCameraUpdate.setTarget(place.coordinate, zoom: 20))
            
        }
        else {
            self.zoomToAllParks()
            
        }
    }
    private func zoomToAllParks() {
        
        let bounds = self.places.value.reduce(GMSCoordinateBounds()) {
            $0.includingCoordinate($1.coordinate)
        }
        
        let fitCamera = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 128, left: 32, bottom: mapPadding, right: 32))
        self.mapView.animate(with: fitCamera)
        //               self.closeView(self)
        
    }
    private func setPlaces() {
        self.annotations = [:]
        
        
        places.value.forEach({ (place) in
            
            let coordinate = place.coordinate
            let annotation = Annotation(id: place.id, coordinate: coordinate)
            
            self.annotations[place.id] = annotation
            
            
        })
        self.mapView.clusterManager.annotations = self.annotations.values.map({$0})
    }
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    private func setupFloatingPanel() {
        
        
        if fpc == nil {
            fpLayout.type = .locations
            fpLayout.offset = self.view.safeAreaInsets.bottom
            
            fpc = FloatingPanelController()
            
            fpc.delegate = self // Optional
            
            // Set a content view controller.
            pullController = storyboard?.instantiateViewController(withIdentifier: "locationsPullController") as? LocationsPullViewController
            pullController.placeSelected = { place in
                self.selectPlace(place: place)
            }
            fpc.set(contentViewController: pullController)
            
            // Track a scroll view(or the siblings) in the content view controller.
            fpc.track(scrollView: pullController.scrollView)
            
            // Add and show the views managed by the `FloatingPanelController` object to self.view.
            fpc.addPanel(toParent: self)
            
            fpc.surfaceView.cornerRadius = 20
            
            fpc.set(contentViewController: pullController)
        }
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupFloatingPanel()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.fpLayout.fullEnabled = PlacesService.service.selectedLocation.value != nil
        
    }
}


extension LocationsViewController:CKClusterManagerDelegate, GMSMapViewDataSource,GMSMapViewDelegate {
    
    
    func mapView(_ mapView: GMSMapView, markerFor cluster: CKCluster) -> GMSMarker {
        
        if cluster.count > 1 {
            let marker = Marker()
            marker.position = cluster.coordinate
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            label.text = "\(cluster.count)"
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
            label.textAlignment = .center
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 20
            label.backgroundColor = .white
            
            marker.iconView = label
            
            return marker
        }
        
        let marker = Marker()
        marker.position = cluster.coordinate
        
        if let annotation = cluster.annotations.first as? Annotation, let place = places.value.first(where: {$0.id == annotation.id}){ //, let color = PlacesService.service.tags.value.first(where: {$0.title == place.filter})?.color
            
            if let icon = UIImage(named: "\(place.type)\( PlacesService.service.selectedLocation.value?.id == place.id ? "-selected" : "")") {
                marker.icon = icon
            } else {
                marker.isActive = PlacesService.service.selectedLocation.value?.id == place.id
                marker.color = Config.Color.orange
                
            }
            self.markers[place.id] = marker
            
        }
        
        marker.isFlat = true
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        return marker
        
        //        return GMSMarker(position: cluster.coordinate)
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.setPlaces()
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.scaleBar.setNeedsLayout()
    }

    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let cluster = marker.cluster, cluster.count > 1 && Float(self.mapView.zoom) == self.mapView.maxZoom {
            
            let alert = UIAlertController(title: "Vyberte projekt", message: "", preferredStyle: .actionSheet)
            
            var selectedPlaces:[Place] = []
            
            
            
            cluster.annotations.forEach { (an) in
                guard let anot = an as? Annotation else {return}
                guard let place = places.value.first(where: {$0.id == anot.id}) else {return}
                
                selectedPlaces.append(place)
                alert.addAction(UIAlertAction(title: place.title.truncate(length: 45, trailing: "…"), style: .default, handler: { (_) in
                    self.selectPlace(place: place)
                    if let  index = PlacesService.service.locations.value.map({$0.id}).firstIndex(of: place.id) {
                        self.pullController.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                    }
                    
                }))
                
                
            }
            
            alert.addAction(UIAlertAction(title: "Zrušit", style: .cancel, handler: nil))
            alert.message = "Vyberte místo"
            UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 2
            
            self.present(alert, animated: true, completion: nil)
            
            return true
        }
        
        if let cluster = marker.cluster, cluster.count > 1 {
            let fitCamera = GMSCameraUpdate.fit(cluster, with: UIEdgeInsets(top: 128, left: 32, bottom: mapPadding, right: 32))
            self.mapView.animate(with: fitCamera)
            return true
        }
        
        if let anot = marker.cluster?.annotations.first as? Annotation, let place = places.value.first(where: {$0.id == anot.id}) {
            
            self.selectPlace(place: place)
            if let  index = PlacesService.service.locations.value.map({$0.id}).firstIndex(of: place.id) {
                self.pullController.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
            }
            
        }
        return true
    }
    
    private func selectPlace(place:Location?) {
        
        
        if let previousPlace = PlacesService.service.selectedLocation.value, place == previousPlace{
//            self.fpc.move(to: .full, animated: true)
        } else {
            if place != nil && self.fpc.position != .full {
                self.fpc.move(to: .half, animated: true)
                
            }
            PlacesService.service.selectedLocation.accept(place)
            self.zoomToPlace(place: place)
            
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = mapContainer.bounds
    }
}

extension LocationsViewController:FloatingPanelControllerDelegate {
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return fpLayout
    }
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition == .half {
            //            fpLayout.fullEnabled = true
            
        } else if targetPosition == .tip {
            
            delay(0.2) {
                self.zoomToAllParks()
            }
            
        }
        
        
    }
    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        
        self.updateMapPadding()
//        self.pullController.collectionView.alpha = vc.position == .tip ? 0 : 1
        if vc.position == .half && PlacesService.service.selectedLocation.value == nil {
            PlacesService.service.selectedLocation.accept(PlacesService.service.locations.value.first)
        }
    }
    
    
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
//
//        let y = self.view.frame.size.height - vc.surfaceView.frame.origin.y
//        if let max =  vc.layout.insetFor(position: .half) {
//            let tip = vc.layout.insetFor(position: .tip) ?? 0
//            self.pullController.collectionView.alpha = min((y - tip) / (max), 1)
//
//        }
        
        
    }
    
    func updateMapPadding() {
        if self.fpc.position != .full, mapView != nil, let offset = self.fpc.layout.insetFor(position: self.fpc.position) {
            self.scaleBottomConstraint.constant = offset + 10
            
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
            self.view.layoutIfNeeded()
            
        }
    }
}
