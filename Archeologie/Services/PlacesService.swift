 //
//  PlacesService.swift
//  Places
//
//  Created by Matěj Novák on 22.08.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PlacesService {
    
    static var service:PlacesService = PlacesService()
    lazy var disposeBag:DisposeBag = DisposeBag()
    
    var thematics:BehaviorRelay<[Thematic]> = BehaviorRelay<[Thematic]>(value: [])
    var selectedThematic:BehaviorRelay<Thematic?> = BehaviorRelay<Thematic?>(value: nil)
    
    var tags:BehaviorRelay<[Tag]> = BehaviorRelay<[Tag]>(value: [])
//    var locations:BehaviorRelay<[Location]> = BehaviorRelay<[Location]>(value: [])
    var locations:Observable<[Location]> = Single.just([]).asObservable()
    var selectedLocation:BehaviorRelay<Location?> = BehaviorRelay<Location?>(value: nil)

    func getThematics() {
        Service.api.rx.request(.thematics).do().map(Thematics.self).asObservable().subscribe(onNext: { (thematics) in
            print("Thematics repspo")
            self.thematics.accept(thematics.thematics)
            }).disposed(by: disposeBag)
    }
    
    func getLocations(id:Int?) {
        locations =  Service.api.rx.request(.location(id)).do().map(Locations.self).map({$0.locations}).asObservable()
    }
    
//    func loadPlaces() {
//
//        let dateRequest = Service.api.rx.request(.updated).do().map(UpdatedRes.self).asObservable()
//
//        dateRequest.subscribe(onNext: { (res) in
//            if let updated = res.date.isoDateFromString, let lastUpdate = UserDefaults.standard.object(forKey: "lastUpdated") as? Date, let data = UserDefaults.standard.object(forKey: "places") as? Data, let placesRes = try? JSONDecoder().decode(PlacesRes.self, from: data),  updated <= lastUpdate {
//
//                Single.just(placesRes.places).asObservable().bind(to: self.allPlaces).disposed(by: self.disposeBag)
//
//            } else {
//
//                self.getNewPlaces(updated: res.date.isoDateFromString).bind(to: self.allPlaces).disposed(by: self.disposeBag)
//
//            }
//
//        }, onError: { (err) in
//            print(err.localizedDescription)
//            self.getNewPlaces().bind(to: self.allPlaces).disposed(by: self.disposeBag)
//
//        }).disposed(by: disposeBag)
//        allPlaces.bind(to: places).disposed(by: disposeBag)
//
//    }
//    func filter(query:String = "", tags:[String]) {
//
//
//        var filteredPlaces:[Thematic] = allPlaces.value
//
//        if !query.isEmpty {
//
//            filteredPlaces = filteredPlaces.filter({ (place) -> Bool in
//                return place.title.searchable.contains(query.searchable) || place.address.searchable.contains(query.searchable) || place.implementer.searchable.contains(query.searchable) || place.legalForm.searchable.contains(query.searchable) || place.text.searchable.contains(query.searchable) || place.filter.searchable.contains(query.searchable)
//            })
//        }
//
//        if tags.count > 0 {
//            filteredPlaces = filteredPlaces.filter({ (place) -> Bool in
//                return tags.contains(place.filter)
//            })
//        }
//
//
//        Single.just(filteredPlaces).asObservable().bind(to:self.places).disposed(by: disposeBag)
//
//    }
//
//    private func getNewPlaces(updated:Date? = nil) -> Observable<[Thematic]> {
//
//        return Service.api.rx.request(.places).do(onSuccess: { (response) in
//
//            UserDefaults.standard.set(response.data, forKey: "places")
//            if let updated = updated {
//                UserDefaults.standard.set(updated, forKey: "lastUpdated")
//            }
//
//        }).map(PlacesRes.self).map({res -> [Place] in return res.places}).catchError({ (error) -> PrimitiveSequence<SingleTrait, [Place]> in
//            UserDefaults.standard.set(nil, forKey: "lastUpdated")
//
//            print("ERROR: \(error.localizedDescription)")
//            if let data = UserDefaults.standard.object(forKey: "places") as? Data,let places = try? JSONDecoder().decode([Place].self, from: data) {
//                return Single.just(places)
//            }
//
//            return Single.just([])
//
//        }).asObservable()
//
//
//    }
//
//
//    func loadTags() {
//
//        let observable = Service.api.rx.request(.tags).do(onSuccess: { (response) in
//            UserDefaults.standard.set(response.data, forKey: "tags")
//        }).map(TagsRes.self).map({ res -> [Tag] in
//            return res.tags
//        }).catchError({ (error) -> PrimitiveSequence<SingleTrait, [Tag]> in
//            print("ERROR: \(error.localizedDescription)")
//            if let data = UserDefaults.standard.object(forKey: "tags") as? Data,let tags = try? JSONDecoder().decode([Tag].self, from: data) {
//                return Single.just(tags)
//            }
//            return Single.just([])
//        }).asObservable()
//
//        observable.bind(to: tags).disposed(by: disposeBag)
//
//        //        tags.asObservable().map{$0.compactMap({tags in return tags.tags}).flatMap({tags in return tags})}.bind(to: allTags).disposed(by: disposeBag)
//    }
//
//    func getSortedTags(for place:Place) -> [Tag] {
//        //                let categoryIds = tags.value.map {$0.id}
//        //
//        //
//        //                return place.tags?.map{($0, categoryIds.firstIndex(of: $0.categoryId ?? 999) ?? 999)}
//        //                    .sorted(by: {$0.1 < $1.1})
//        //                    .map{$0.0} ?? []
//
//        return tags.value
//    }
    
    
    init() {
//        loadPlaces()
//        loadTags()
        getThematics()
        getLocations(id: nil)
    }
}