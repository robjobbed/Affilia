//
//  Item.swift
//  Solomine
//
//  Created by Rob Behbahani on 2/3/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
