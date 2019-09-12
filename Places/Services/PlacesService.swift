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

    var places:BehaviorRelay<[Place]> = BehaviorRelay<[Place]>(value: [])
    var tags:BehaviorRelay<[TagCategory]> = BehaviorRelay<[TagCategory]>(value: [])
    var allTags:BehaviorRelay<[Tag]> = BehaviorRelay<[Tag]>(value: [])
    
    
    func loadPlaces(query:String? = nil, tags:[Int]? = nil) {
        
        let observable = Service.api.rx.request(.places(query:query?.searchable,tags:tags)).do(onSuccess: { (response) in
            
            UserDefaults.standard.set(response.data, forKey: "places")
            
        }).map([Place].self).catchError({ (error) -> PrimitiveSequence<SingleTrait, [Place]> in
            
            print("ERROR: \(error.localizedDescription)")
            if let data = UserDefaults.standard.object(forKey: "places") as? Data,let places = try? JSONDecoder().decode([Place].self, from: data) {
                return Single.just(places)
            }
            
            return Single.just([])
            
        }).asObservable()
        
        observable.bind(to: places).disposed(by: disposeBag)
        
    

        
    }
    
    func loadTags() {
        let observable = Service.api.rx.request(.tags).do(onSuccess: { (response) in
            UserDefaults.standard.set(response.data, forKey: "tags")
        }).map([TagCategory].self).catchError({ (error) -> PrimitiveSequence<SingleTrait, [TagCategory]> in
            print("ERROR: \(error.localizedDescription)")
            if let data = UserDefaults.standard.object(forKey: "tags") as? Data,let tags = try? JSONDecoder().decode([TagCategory].self, from: data) {
                return Single.just(tags)
            }
            return Single.just([])
        }).asObservable()
        
        observable.bind(to: tags).disposed(by: disposeBag)
        
        tags.asObservable().map{$0.compactMap({tags in return tags.tags}).flatMap({tags in return tags})}.bind(to: allTags).disposed(by: disposeBag)
    }
    
    func getSortedTags(for place:Place) -> [Tag] {
        let categoryIds = tags.value.map {$0.id}
        
        return place.tags?.map{($0, categoryIds.firstIndex(of: $0.categoryId ?? 999) ?? 999)}
            .sorted(by: {$0.1 < $1.1})
            .map{$0.0} ?? []
    }
    
    
    init() {
        loadPlaces()
        loadTags()
    }
}
