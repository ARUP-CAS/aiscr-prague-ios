//
//  ArchFloatingPanelLayout.swift
//  Archeologie
//
//  Created by Matěj Novák on 03/09/2020.
//  Copyright © 2020 Matěj Novák. All rights reserved.
//

import Foundation
import FloatingPanel

class ArchFloatingPanelLayout: FloatingPanelLayout {
    
    var offset:CGFloat = 0
    var fullEnabled = true
    var type:LayoutType = .thematics
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        
        switch type {
        case .thematics:
            switch position {
            case .full: return 0
            case .half: return 335 - offset
            case .tip: return 214 - offset
            default: return nil
            }
        case .locations:
            switch position {
            case .half: return 427 - offset
            case .tip: return 210  - offset
            case .full: return 0
            default: return nil
            }
        }
        
    }
    var supportedPositions: Set<FloatingPanelPosition> {
//        return fullEnabled ? [.tip,.half,.full] :  [.tip,.half]
        return  [.tip,.half]

    }
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    enum LayoutType {
        case thematics
        case locations
    }
}
