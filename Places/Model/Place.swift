/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct Place : Codable {
	let id : Int
	let title : String?
	let location : Location?
	let address : String?
	var tags : [Tag]?
	let photos : [Photo]?
	let link : String?
	let text : String?

	enum CodingKeys: String, CodingKey {

		case id
		case title
		case location
		case address
		case tags
		case photos
		case link
		case text
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(Int.self, forKey: .id)
		title = try values.decodeIfPresent(String.self, forKey: .title)
		location = try values.decodeIfPresent(Location.self, forKey: .location)
		address = try values.decodeIfPresent(String.self, forKey: .address)
		tags = try values.decodeIfPresent([Tag].self, forKey: .tags)
		photos = try values.decodeIfPresent([Photo].self, forKey: .photos)
		link = try values.decodeIfPresent(String.self, forKey: .link)
		text = try values.decodeIfPresent(String.self, forKey: .text)
	}

}
