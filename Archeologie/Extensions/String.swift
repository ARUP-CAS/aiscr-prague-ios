//
//  String.swift
//  Places
//
//  Created by Matěj Novák on 03.09.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation


extension String {
    
    var htmlAttributed:NSAttributedString {
        do {
            return try  NSAttributedString(
                data: "<style>body{font-size:14px; font-family:'Helvetica Neue', Helvetica,sans-serif;}</style> \(self)".data(using: String.Encoding.unicode, allowLossyConversion: true)!,
                options:[NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
            
        } catch {
            print("html parse error")
            return NSAttributedString(string: self)
        }
    }
    var searchable:String {
        return self.folding(options: .diacriticInsensitive, locale: .current).lowercased()
    }
    
    var loc:String {
        return NSLocalizedString(self, comment: "")
    }
    
    func truncate(length: Int, trailing: String = "…") -> String {
        if self.characters.count > length {
            return String(self.characters.prefix(length)) + trailing
        } else {
            return self
        }
    }
    
    var isoDateFromString:Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: self)
    }
    
}
