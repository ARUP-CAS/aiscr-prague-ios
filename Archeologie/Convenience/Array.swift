//
//  Array.swift
//  Archeologie
//
//  Created by Matěj Novák on 10/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import Foundation
extension Sequence where Iterator.Element : Hashable {

    func intersects<S : Sequence>(with sequence: S) -> Bool
        where S.Iterator.Element == Iterator.Element
    {
        let sequenceSet = Set(sequence)
        return self.contains(where: sequenceSet.contains)
    }
}
