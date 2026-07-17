//
//  Item.swift
//  Shark
//
//  Created by tiscomacnb2486 on 17/7/2569 BE.
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
