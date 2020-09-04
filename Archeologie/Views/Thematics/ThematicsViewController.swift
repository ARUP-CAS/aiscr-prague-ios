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
import GoogleUtilities
import GoogleMapsUtils

class ThematicsViewController:BaseViewController {
    
    @IBOutlet var mapContainer: UIView!
    var mapView:GMSMapView!
    var geoJsonParser:GMUGeoJSONParser!
    var renderer:GMUGeometryRenderer!
    let mapPadding:CGFloat = UIScreen.main.bounds.width < 400 ? 128 : 256
    
    lazy var selectedPlaceBag:DisposeBag = DisposeBag()
    
    
    var places:BehaviorRelay<[Thematic]> = BehaviorRelay<[Thematic]>(value: [])
    var annotations:[Int:Annotation] = [:]
    var markers:[Int:Marker] = [:]
    var pullController:ThematicsPullViewController!
    var fpc: FloatingPanelController!
    lazy var fpLayout = ArchFloatingPanelLayout()
    
    var selectedThematic:Thematic?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addMap()
        setupRX()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.fpLayout.fullEnabled = PlacesService.service.selectedThematic.value != nil
    }
    private func setupRX () {
        
        PlacesService.service.thematics.asObservable().bind(to: places).disposed(by: disposeBag)
        
        places.asObservable().subscribe { (places) in
            
            self.setPlaces()
            self.zoomToAllParks()
            
        }.disposed(by: disposeBag)
        
        PlacesService.service.selectedThematic.asObservable().subscribe { (event) in
            
            guard let place = event.element, self.fpc != nil else { return }
            
            self.fpLayout.fullEnabled = place != nil
            
            
            self.fpc.move(to: place != nil ? .full : .half, animated: true)
            
            
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
            mapView.hero.id = "map"
            
            mapView.topAnchor.constraint(equalTo: mapContainer.topAnchor).isActive = true
            mapView.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor).isActive = true
            mapView.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor).isActive = true
            mapView.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor).isActive = true
            
            let algo = CKNonHierarchicalDistanceBasedAlgorithm()
            algo.cellSize = 500
            self.mapView.clusterManager.algorithm = algo
            self.mapView.setMinZoom(3, maxZoom: 18)
            self.mapView.settings.myLocationButton = true
            //            self.mapView.clusterManager.marginFactor = 1
            self.mapView.dataSource = self
            self.mapView.clusterManager.delegate = self
            self.mapView.isMyLocationEnabled = true
            
            if let styleUrl = Bundle.main.url(forResource: "map-style", withExtension: "json"), let style = try? GMSMapStyle(contentsOfFileURL: styleUrl) {
                self.mapView.mapStyle = style
            }
            
            let path = Bundle.main.path(forResource: "map", ofType: "geojson")
            let url = URL(fileURLWithPath: path!)
            geoJsonParser = GMUGeoJSONParser(url: url)
            geoJsonParser.parse()
            
            
            
            for feature in geoJsonParser.features {
                if let feature = feature as? GMUFeature, let properties = feature.properties ,let id = properties["topic-id"] as? Int, let fill = properties["fill"] as? String, let stroke =  properties["stroke"] as? String{
                    let style = GMUStyle(styleID: "\(id)", stroke: UIColor(hexString: stroke).withAlphaComponent(0.5), fill: UIColor(hexString: fill).withAlphaComponent(0.5), width: 1, scale: 1, heading: 1, anchor: CGPoint(x: 0.5, y: 0.5), iconUrl: nil, title: nil, hasFill: true, hasStroke: true)
                    feature.style = style

                }
            }
            renderer = GMUGeometryRenderer(map: mapView, geometries: geoJsonParser.features)
            
            renderer.render()
            
            renderer.mapOverlays()?.forEach({ (overlay) in
                overlay.isTappable = true
            })
            
        }
        
    }
    func zoomToPlace(place:Thematic) {
        self.mapView.moveCamera(GMSCameraUpdate.setTarget(place.coordinate, zoom: 15))
    }
    private func zoomToAllParks() {
        
        let bounds = self.places.value.reduce(GMSCoordinateBounds()) {
            $0.includingCoordinate($1.coordinate)
        }
        
        let fitCamera = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 256, left: 32, bottom: mapPadding, right: 32))
        self.mapView.animate(with: fitCamera)
        //               self.closeView(self)
        
    }
    private func setPlaces(filterByVisible: Bool = false) {
        self.annotations = [:]
        
        
        places.value.filter({ place -> Bool in
            
            return place.coordinate.isInRegion(region: self.mapView.projection.visibleRegion()) || !filterByVisible
            
        }).forEach({ (place) in
            
            let coordinate = place.coordinate
            let annotation = Annotation(id: place.id, coordinate: coordinate)
            
            self.annotations[place.id] = annotation
            
            
        })
        self.mapView.clusterManager.annotations = self.annotations.values.map({$0})
    }
    
    
    private func setupFloatingPanel() {
        
        
        if fpc == nil {
            // Initialize a `FloatingPanelController` object.
            fpLayout.offset = self.view.safeAreaInsets.bottom
            
            fpc = FloatingPanelController()
            
            // Assign self as the delegate of the controller.
            fpc.delegate = self // Optional
            
            // Set a content view controller.
            pullController = storyboard?.instantiateViewController(withIdentifier: "thematicsPullController") as? ThematicsPullViewController
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
        if fpc != nil {
            
            let y = self.view.frame.size.height - fpc.surfaceView.frame.origin.y
            if let max =  fpc.layout.insetFor(position: .half) {
                self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: min(y, max), right: 0)
            }
        }
        setupFloatingPanel()
        
    }
}


extension ThematicsViewController:CKClusterManagerDelegate, GMSMapViewDataSource,GMSMapViewDelegate {
    
    func mapViewSnapshotReady(_ mapView: GMSMapView) {
        
    }
    
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
            
            marker.color = Config.Color.orange
            self.markers[place.id] = marker
            
        }
        
        marker.isFlat = true
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        return marker
        
    }
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //        self.setPlaces()
        
        
    }
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        if let userData = overlay.userData as? [String:Any], let placeId = userData["topic-id"] as? Int, let place = PlacesService.service.thematics.value.first(where: {$0.id == placeId}){
            PlacesService.service.selectedThematic.accept(place)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        //        self.closeView(self)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
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
                    self.populatePlaceView(place: place)
                    
                }))
                
                //                self.populatePlaceView(place: place)
                
            }
            
            alert.addAction(UIAlertAction(title: "Zrušit", style: .cancel, handler: nil))
            alert.message = "Vyberte místo"
            UILabel.appearance(whenContainedInInstancesOf: [UIAlertController.self]).numberOfLines = 2
            
            self.present(alert, animated: true, completion: nil)
            
            return true
        }
        
        if let cluster = marker.cluster, cluster.count > 1 {
            let fitCamera = GMSCameraUpdate.fit(cluster, with: UIEdgeInsets(top: mapPadding, left: 32, bottom: mapPadding, right: 32))
            self.mapView.animate(with: fitCamera)
            return true
        }
        
        if let anot = marker.cluster?.annotations.first as? Annotation, let place = places.value.first(where: {$0.id == anot.id}) {
            //            self.selectedPlace = place
            //            if let marker = marker as? Marker {
            //                marker.isActive = true
            //            }
            
            self.populatePlaceView(place: place)
            
            
        }
        return true
    }
    
    private func populatePlaceView(place:Thematic) {
        
        PlacesService.service.selectedThematic.accept(place)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = mapContainer.bounds
    }
}

extension ThematicsViewController:FloatingPanelControllerDelegate {
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
        
        if vc.position != .full, mapView != nil, let offset = vc.layout.insetFor(position: vc.position) {
            self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: offset, right: 0)
            
        }
        
    }
    func floatingPanelDidMove(_ vc: FloatingPanelController) {
        UIView.animateKeyframes(withDuration: 0.0, delay: 0.0, options: [.calculationModeCubic], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1.0) {
                // Update Map padding
                let y = self.view.frame.size.height - vc.surfaceView.frame.origin.y
                if let max =  vc.layout.insetFor(position: .half) {
                    self.mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: min(y, max), right: 0)
                }
                
                
            }
        })
        
    }
}
