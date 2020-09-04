// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let thematics = try? newJSONDecoder().decode(Thematics.self, from: jsonData)
//
// Hashable or Equatable:
// The compiler will not be able to synthesize the implementation of Hashable or Equatable
// for types that require the use of JSONAny, nor will the implementation of Hashable be
// synthesized for types that have collections (such as arrays or dictionaries).

import Foundation

// MARK: - Thematics
struct Thematics: Codable, Equatable {
    var thematics: [Thematic]
    var status: String
    var statusCode: Int
  
}
