//
//  TimeInterval.swift
//  accolade
//
//  Created by Matěj Novák on 15.01.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation

extension TimeInterval {
    var mediumDateString:String {
        let df = DateFormatter()
        df.dateStyle = .long
        df.locale = Locale.current
        return df.string(from: Date(timeIntervalSince1970: self))
    }
}

extension Float {
    var toString:String {
        let nf = NumberFormatter()
        nf.minimumFractionDigits = 0
        nf.maximumFractionDigits = 2
        nf.minimumIntegerDigits = 1
        return nf.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
extension Double {
    var formattedBytes: String {
        guard self > 0 else {
            return "0 bytes"
        }
        
        // Adapted from http://stackoverflow.com/a/18650828
        let suffixes = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        let k: Double = 1000
        let i = floor(log(self) / log(k))
        
        // Format number with thousands separator and everything below 1 GB with no decimal places.
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = i < 3 ? 0 : 1
        numberFormatter.numberStyle = .decimal
        
        let numberString = numberFormatter.string(from: NSNumber(value: self / pow(k, i))) ?? "Unknown"
        let suffix = suffixes[Int(i)]
        return "\(numberString) \(suffix)"
    }
}
