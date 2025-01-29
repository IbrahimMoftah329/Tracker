//
//  ProductViewModel.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import Combine

// ViewModel to manage products and their stats, fetching data from the API
class ProductViewModel: ObservableObject {
    @Published var products: [Product] = [] // Array of products to be displayed
    @Published var stats: [String: Stats] = [:] // Dictionary to store stats keyed by product display name
    
    private var apiManager = CoinbaseAPIManager() // API manager to handle network requests
    private var cancellables = Set<AnyCancellable>() // Set to store Combine subscriptions

    // Function to fetch list of products
    func fetchProducts() {
        apiManager.fetchProducts()
            .receive(on: DispatchQueue.main) // Ensure UI updates occur on the main thread
            .sink { [weak self] products in
                self?.products = products // Update products list
                products.forEach { self?.fetchStats(for: $0) } // Fetch stats for each product
            }
            .store(in: &cancellables) // Store subscription to manage memory
    }

    // Function to fetch stats for a specific product
    private func fetchStats(for product: Product) {
        apiManager.fetchStats(for: product.display_name)
            .receive(on: DispatchQueue.main) // Ensure UI updates occur on the main thread
            .sink { [weak self] stats in
                // Update stats dictionary if valid stats are received
                if let stats = stats, stats.isValid {
                    self?.stats[product.display_name] = stats
                }
            }
            .store(in: &cancellables) // Store subscription to manage memory
    }
}
