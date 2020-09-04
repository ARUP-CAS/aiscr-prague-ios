//
//  Delay.swift
//  accolade
//
//  Created by Matěj Novák on 18.01.18.
//  Copyright © 2018 Matěj Novák. All rights reserved.
//

import Foundation
func delay(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}
