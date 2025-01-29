//
//  Stats.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation

// Model representing stats data from the Coinbase API
struct Stats: Codable {
    let open: String // Opening price of the product
    let high: String // Highest price in the last 24 hours
    let low: String // Lowest price in the last 24 hours
    let last: String // Last traded price
    let volume: String // Trading volume in the last 24 hours
    let volume_30day: String // Trading volume in the last 30 days
    
    // Check if all necessary fields are present and not empty
    var isValid: Bool {
        return !open.isEmpty && !high.isEmpty && !low.isEmpty &&
               !last.isEmpty && !volume.isEmpty && !volume_30day.isEmpty
    }
}
