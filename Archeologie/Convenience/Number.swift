//
//  Number.swift
//  MSMT
//
//  Created by Matěj Novák on 30/10/2019.
//  Copyright © 2019 Matěj Novák. All rights reserved.
//

import Foundation

extension Double {
    
    var formattedPrice:String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current // Change this to another locale if you want to force a specific locale, otherwise this is redundant as the current locale is the default already
        formatter.numberStyle = .currency
        
        return formatter.string(from: self as NSNumber) ?? ""
    }
}
