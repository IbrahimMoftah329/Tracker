//
//  CoinbaseAPIManager.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import Combine

// API manager to handle network requests to the Coinbase API
class CoinbaseAPIManager {
    
    // Function to fetch the list of products from Coinbase API using Combine
    func fetchProducts() -> AnyPublisher<[Product], Never> {
        guard let url = URL(string: "https://api.exchange.coinbase.com/products") else {
            // Return an empty array if the URL is invalid
            return Just([]).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data } // Extract data from the response
            .decode(type: [Product].self, decoder: JSONDecoder()) // Decode the data into an array of Product objects
            .replaceError(with: []) // If an error occurs, replace it with an empty array
            .eraseToAnyPublisher() // Erase the publisher type to AnyPublisher
    }

    // Function to fetch stats for a specific product using its display name
    func fetchStats(for displayName: String) -> AnyPublisher<Stats?, Never> {
        let urlString = "https://api.exchange.coinbase.com/products/\(displayName)/stats" // URL endpoint for product stats
        guard let url = URL(string: urlString) else {
            // Return nil if the URL is invalid
            return Just(nil).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data } // Extract data from the response
            .decode(type: Stats?.self, decoder: JSONDecoder()) // Decode the data into a Stats object
            .replaceError(with: nil) // If an error occurs, replace it with nil
            .eraseToAnyPublisher() // Erase the publisher type to AnyPublisher
    }
}
