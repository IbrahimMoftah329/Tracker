//
//  ProductsView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import SwiftUI

// Main view for displaying the products list
struct ProductsView: View {
    @StateObject private var viewModel = ProductViewModel() // ViewModel to manage product data and stats
    @AppStorage("preferredProduct") var preferredProduct: String = "USD" // User's preferred product currency, default is "USD"
    @State private var isPulsing = false // State for pulsing animation on loading indicator
    @State private var productsLoaded = false // Tracks if products have finished loading to trigger animations

    var body: some View {
        NavigationView {
            VStack {
                // Show loading indicator if no products are loaded
                if viewModel.products.isEmpty {
                    Spacer() // Space above the loading indicator
                    VStack { // Centered loading indicator and message
                        ProgressView("Loading products...")
                            .scaleEffect(isPulsing ? 1.1 : 1.0) // Apply pulsing animation
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing) // Smooth pulsing effect
                            .onAppear { isPulsing = true } // Start pulsing when loading appears
                    }
                    Spacer() // Space below the loading indicator
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center the VStack in the frame
                } else {
                    // Filter products to show only those matching the preferred currency and with valid stats
                    let displayedProducts = preferredProduct.isEmpty ?
                        viewModel.products.filter { hasValidStats(for: $0) } : // Show products with valid stats if no preferred currency
                        viewModel.products.filter { $0.quote_currency == preferredProduct && hasValidStats(for: $0) } // Show preferred currency products with valid stats
                    
                    // Display list of products
                    List(displayedProducts) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) { // Link to product detail view
                            ProductRowView(product: product, stats: viewModel.stats[product.display_name])
                                .transition(.move(edge: .leading)) // Slide in each row from the left
                                .animation(.easeInOut(duration: 0.6), value: productsLoaded) // Animate row appearance
                        }
                    }
                    .listStyle(PlainListStyle()) // Use plain style for list
                    .padding(.horizontal, 0) // Set horizontal padding
                    .onAppear {
                        productsLoaded = true // Set flag to trigger animations once products are loaded
                    }
                    
                    // Show message if no products with valid stats are found
                    if displayedProducts.isEmpty {
                        Spacer() // Space above the message
                        VStack {
                            ProgressView("No valid products found...") // Message for no valid products
                        }
                        Spacer() // Space below the message
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center) // Center message vertically and horizontally
                    }
                }
            }
            .onAppear {
                viewModel.fetchProducts() // Trigger product fetching when the view appears
            }
            .applyTheme() // Apply any custom theming to the view
        }
    }
    
    // Helper function to check if a product has valid stats
    private func hasValidStats(for product: Product) -> Bool {
        if let stats = viewModel.stats[product.display_name] {
            return stats.isValid // Return true if stats are valid, false otherwise
        }
        return false
    }
}
