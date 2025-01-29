//
//  SearchView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import SwiftUI

// View to search and display products by base currency
struct SearchView: View {
    @State private var searchText = "" // Holds the text entered by the user in the search field
    @State private var results = [Product]() // Array to store search results
    @StateObject private var viewModel = ProductViewModel() // ViewModel to manage product data and fetching
    @FocusState private var isSearchFieldFocused: Bool // Focus state for the search TextField

    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search by base currency...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle()) // Style the search field
                    .padding()
                    .focused($isSearchFieldFocused) // Bind focus state to the TextField
                    .onChange(of: searchText) {
                        performSearch() // Call search function on each text change
                    }

                // Display search results
                if results.isEmpty && !searchText.isEmpty {
                    // Message if no results are found
                    Text("No results found")
                        .padding()
                } else {
                    // List of search results
                    List(results) { product in
                        NavigationLink(destination: ProductDetailView(product: product)) {
                            HStack {
                                Text(product.base_currency) // Display base currency
                                Spacer() // Push the quote currency to the right
                                Text(product.quote_currency) // Display quote currency
                            }
                            .contentShape(Rectangle()) // Make entire row tappable
                        }
                    }
                    .listStyle(PlainListStyle()) // Use plain style to remove default List padding
                }
            }
            .onAppear {
                viewModel.fetchProducts() // Fetch products when the view appears
                isSearchFieldFocused = true // Automatically focus on the search field when the view appears
            }
            .applyTheme() // Apply custom theme and accent color
        }
    }

    // Function to filter products based on search text matching base currency
    func performSearch() {
        // If search text is empty, clear results
        if searchText.isEmpty {
            results = []
        } else {
            // Filter products whose base currency matches the search text
            results = viewModel.products.filter { product in
                product.base_currency.uppercased().hasPrefix(searchText.uppercased())
            }
        }
    }
}
