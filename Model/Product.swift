//
//  Product.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation

// Model representing a product from the Coinbase API
struct Product: Codable, Identifiable, Equatable {
    let id: String // Unique identifier for the product
    let base_currency: String // The base currency of the product
    let quote_currency: String // The quote currency of the product
    let status: String // Current status of the product (e.g., active, offline)
    let display_name: String // Display name of the product, typically in "BASE-QUOTE" format
}
