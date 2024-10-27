//
//  Item.swift
//  fItneSS_us
//
//  Created by 夏逸超 on 7/10/24.
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
