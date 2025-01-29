//
//  WatchListView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import SwiftUI

// View to display the user's saved watchlist products
struct WatchlistView: View {
    @AppStorage("savedProductsData") var savedProductsData: Data = Data() // UserDefaults data to store saved products
    @State private var savedProducts: [Product] = [] // Array to hold decoded Product objects

    var body: some View {
        NavigationView {
            VStack {
                if savedProducts.isEmpty {
                    // Message displayed when the watchlist is empty
                    Text("Your Watchlist is empty.")
                        .padding()
                } else {
                    // List of saved products in the watchlist
                    List(savedProducts) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            HStack {
                                Text(product.base_currency) // Display product's base currency
                                Spacer() // Push quote currency to the right
                                Text(product.quote_currency) // Display product's quote currency
                            }
                            .contentShape(Rectangle()) // Make the entire row tappable
                        }
                    }
                    .listStyle(PlainListStyle()) // Use plain style to remove default List padding
                }
            }
            .onAppear {
                savedProducts = loadSavedProducts() // Load saved products when view appears
            }
            .applyTheme() // Apply the custom theme and accent color
        }
    }

    // Function to load saved products from UserDefaults
    func loadSavedProducts() -> [Product] {
        guard let products = try? JSONDecoder().decode([Product].self, from: savedProductsData) else {
            return [] // Return empty array if decoding fails
        }
        return products
    }
}
