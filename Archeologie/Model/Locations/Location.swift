// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let location = try? newJSONDecoder().decode(Location.self, from: jsonData)
//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

// MARK: - Location
struct Location: Codable, Equatable,Place {
    var id: Int
    var title:String
    var latitude, longitude: Double
    var address: String
    var externalLink:String?
    var content: [LocationContent]
    var thematics: [Int]
    var image:String
    var type:String
    var openTime:Bool
    var timeOfVisit:TimeOfVisit
    var availability:Availability
    
    var coordinate:CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    enum Availability:String,Codable {
        case easy
        case good
        case hard
    }
    enum TimeOfVisit:Int,Codable {
        case none = 0
        case fifteen = 15
        case thrity = 30
        case fourtyfive = 45
        case sixty = 60
    }
    
    var contentCount:Int {
        return content.reduce(0) { (count, content) -> Int in
            switch content.content {
            case .text(let texts):
                return count + texts.count
            case .video(let videos):
                return count + videos.count
            case .image(let images):
                return count + images.count
            default:
                return count
            }
        }
    }
}
