//
//  Item.swift
//  KittenalLen
//
//  Created by MeowCat on 2025/11/30.
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
