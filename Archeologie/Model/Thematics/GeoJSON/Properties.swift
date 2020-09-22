// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let properties = try? newJSONDecoder().decode(Properties.self, from: jsonData)
//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

// MARK: - Properties
struct Properties: Codable, Equatable {
    var stroke: String
    var strokeWidth: Int
    var strokeOpacity: Double
    var fill: String
    var fillOpacity: Double
    var topicID: Int

    enum CodingKeys: String, CodingKey {
        case stroke
        case strokeWidth = "stroke-width"
        case strokeOpacity = "stroke-opacity"
        case fill
        case fillOpacity = "fill-opacity"
        case topicID = "topic-id"
    }
}
