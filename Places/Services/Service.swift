//
//  Service.swift
//  Places
//
//  Created by Matěj Novák on 15.06.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
import Moya
import Alamofire

class Service {
    static let api = MoyaProvider<PlacesAPI>(plugins: [NetworkLoggerPlugin(verbose: true)])

}

enum PlacesAPI {
    case tags
    case places(query:String?, tags:[Int]?)
}
extension PlacesAPI:TargetType {
    
    
    var baseURL:URL {
//                return try! "https://private-ec2c8-architekturaapi.apiary-mock.com/".asURL() //APIARY
        return try! "http://places.visualio.cz/api/".asURL()
    }
    
    var path: String {
        switch self {
        case .tags :
            return "place/tag"
        case .places :
            return "place"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    
    var task: Task {
        switch self {
        case .places(let query, let tags):
            var params:[String:Any] = [:]
            if let query = query {
                params["query"] = query
            }
            if let tags = tags {
                let tagsString = tags.map({"\($0)"}).joined(separator: ",")
                params["tags"] = tagsString
            }
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        default:
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
        let lang =  NSLocale.preferredLanguages.first?.prefix(2)
        return ["Accept-Language":String(lang ?? "en")]
    }
    var sampleData: Data {
        return Data()
    }
    
    
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

