//
//  Image.swift
//  Archeologie
//
//  Created by Matěj on 28/10/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import UIKit

extension UIImage {

    convenience init?(withContentsOfUrl url: URL) throws {
        let imageData = try Data(contentsOf: url)
    
        self.init(data: imageData)
    }

}
