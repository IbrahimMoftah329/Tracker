//
//  ProductRowView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 10/22/24.
//

import Foundation
import SwiftUI

// View to display a single product row, including its last price and base currency
struct ProductRowView: View {
    let product: Product // The product being displayed in the row
    let stats: Stats? // Optional stats data for the product

    var body: some View {
        HStack {
            // Display product's base currency
            Text(product.base_currency)
                .frame(maxWidth: .infinity, alignment: .leading) // Align text to the left and use full width
            
            if let stats = stats {
                // Check if the last price is up or down relative to the open price
                let isPriceUp = (Double(stats.last) ?? 0) > (Double(stats.open) ?? 0)
                
                // Display last price with color-coded background based on price movement
                Text(stats.last)
                    .padding(.horizontal, 10) // Horizontal padding for the price text
                    .padding(.vertical, 5) // Vertical padding for the price text
                    .background(isPriceUp ? Color.green.opacity(0.2) : Color.red.opacity(0.2)) // Green if up, red if down
                    .foregroundColor(isPriceUp ? Color.green : Color.red) // Text color matches background
                    .clipShape(Capsule()) // Rounded capsule shape for the price text background
            }
        }
        .contentShape(Rectangle()) // Make entire row tappable
    }
}
