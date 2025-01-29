//
//  ProductDetailView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import SwiftUI
import Combine

// View to display details of a specific product, including stats and watchlist functionality
struct ProductDetailView: View {
    var product: Product // The product being displayed
    @State private var stats: Stats? = nil // Stats for the product
    @State private var isLoading = true // Flag to indicate if stats are loading
    @State private var amountOwned: String = "" // Raw user input for amount owned
    @State private var totalValueIn: String = "" // Raw user input for total value in currency
    @State private var userIsEditingAmount = false // Track if user is editing amount owned
    @State private var userIsEditingTotalValue = false // Track if user is editing total value
    @AppStorage("savedProductsData") var savedProductsData: Data = Data() // Saved products data in UserDefaults
    @State private var savedProducts: [Product] = [] // List of saved products
    @State private var isInWatchlist: Bool = false // Flag indicating if the product is in the watchlist
    @FocusState private var focusedField: Field? // Track focus state of text fields
    @State private var cancellables = Set<AnyCancellable>() // Manage Combine subscriptions
    
    private let apiManager = CoinbaseAPIManager() // API manager for fetching product stats

    // Enum to represent focusable fields (amount owned or total value)
    enum Field {
        case amountOwned, totalValue
    }

    var body: some View {
        ZStack {
            Color.clear // Transparent background
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil // Dismiss keyboard on tap outside
                }

            VStack(spacing: 15) {
                // Loading indicator
                if isLoading {
                    ProgressView("Loading stats...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding(.vertical)
                } else if let stats = stats {
                    // Display stats if loaded
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        Text("OPEN: \(stats.open)")
                        Text("LAST: \(stats.last)")
                        Text("HIGH: \(stats.high)")
                        Text("LOW: \(stats.low)")
                        Text("VOLUME (24h): \(formatNumber(stats.volume))")
                        Text("VOLUME (30d): \(formatNumber(stats.volume_30day))")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.bottom, 20)
                } else {
                    // Message if stats are not available
                    Text("No stats available")
                        .foregroundColor(.red)
                }

                // Watchlist toggle button
                Button(action: {
                    toggleWatchlist() // Add/remove product from watchlist
                }) {
                    HStack {
                        Image(systemName: isInWatchlist ? "star.fill" : "star") // Star icon based on watchlist status
                        Text(isInWatchlist ? "Remove from Watchlist" : "Add to Watchlist") // Text based on watchlist status
                    }
                    .padding()
                    .background(isInWatchlist ? Color.red : Color.blue) // Red for remove, blue for add
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }

                // Conversion Section (Amount Owned & Total Value)
                VStack(spacing: 10) {
                    // Amount Owned Section
                    HStack {
                        TextField("", text: $amountOwned, onEditingChanged: { editing in
                            userIsEditingAmount = editing // Track if user is editing amount
                            if editing {
                                userIsEditingTotalValue = false // Disable editing in other field
                            }
                        })
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(userIsEditingTotalValue) // Disable if other field is being edited
                        .focused($focusedField, equals: .amountOwned) // Bind focus state
                        .onChange(of: amountOwned) {
                            if userIsEditingAmount {
                                if amountOwned.isEmpty {
                                    totalValueIn = "" // Clear total value if amount is empty
                                } else {
                                    calculateTotalValueIn() // Calculate total value when editing amount
                                }
                            }
                        }
                        // Apply blue border when focused
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(focusedField == .amountOwned ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        
                        Text(product.base_currency) // Display product currency next to input
                            .foregroundColor(.secondary)
                    }

                    // Total Value Section
                    HStack {
                        TextField("", text: $totalValueIn, onEditingChanged: { editing in
                            userIsEditingTotalValue = editing // Track if user is editing total value
                            if editing {
                                userIsEditingAmount = false // Disable editing in other field
                            }
                        })
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(userIsEditingAmount) // Disable if other field is being edited
                        .focused($focusedField, equals: .totalValue) // Bind focus state
                        .onChange(of: totalValueIn) {
                            if userIsEditingTotalValue {
                                if totalValueIn.isEmpty {
                                    amountOwned = "" // Clear amount if total value is empty
                                } else {
                                    calculateAmountOwned() // Calculate amount owned when editing total value
                                }
                            }
                        }
                        // Apply blue border when focused
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(focusedField == .totalValue ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        
                        Text(product.quote_currency) // Display product currency next to input
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                .padding(.top, 20)

            }
            .padding()
            .navigationTitle(product.id) // Set navigation title to product id
            .onAppear {
                savedProducts = loadSavedProducts() // Load saved products from UserDefaults
                isInWatchlist = savedProducts.contains(where: { $0.id == product.id }) // Check if product is in watchlist
                fetchStatsForProduct() // Fetch stats when view appears
            }
        }
    }

    // Fetch stats for the current product using Combine
    private func fetchStatsForProduct() {
        apiManager.fetchStats(for: product.display_name)
            .receive(on: DispatchQueue.main) // Ensure updates occur on the main thread
            .sink { fetchedStats in
                self.stats = fetchedStats // Set the fetched stats
                self.isLoading = false // Disable loading indicator
            }
            .store(in: &cancellables) // Store subscription to manage memory
    }

    // Load saved products from UserDefaults
    func loadSavedProducts() -> [Product] {
        guard let products = try? JSONDecoder().decode([Product].self, from: savedProductsData) else {
            return [] // Return empty array if decoding fails
        }
        return products
    }
    
    // Save products to UserDefaults
    func saveProducts(_ products: [Product]) {
        if let encoded = try? JSONEncoder().encode(products) {
            savedProductsData = encoded // Update savedProductsData with encoded products
        }
    }

    // Toggle the current product in the watchlist
    func toggleWatchlist() {
        if isInWatchlist {
            savedProducts.removeAll(where: { $0.id == product.id }) // Remove product from watchlist
        } else {
            savedProducts.append(product) // Add product to watchlist
        }

        saveProducts(savedProducts) // Update savedProductsData in UserDefaults
        isInWatchlist.toggle() // Toggle watchlist status
    }

    // Calculate and update the total value in the preferred currency
    private func calculateTotalValueIn() {
        // Ensure `stats?.last` (the last price) and `amountOwned` (the quantity owned) can be converted to Double
        guard let lastPriceString = stats?.last,
              let lastPrice = Double(lastPriceString),
              let amountOwnedDouble = Double(amountOwned) else {
            // Exit if any value is missing or invalid
            return
        }
        // Calculate total value by multiplying the owned amount by the last price
        let totalValue = amountOwnedDouble * lastPrice
        // Format the calculated total value and update the `totalValueIn` property
        totalValueIn = formatNumber(totalValue)
    }

    // Calculate and update the amount owned based on total value
    private func calculateAmountOwned() {
        // Ensure `stats?.last` (the last price) and `totalValueIn` (the total value) can be converted to Double
        guard let lastPriceString = stats?.last,
              let lastPrice = Double(lastPriceString),
              let totalValueInDouble = Double(totalValueIn) else {
            // Exit if any value is missing or invalid
            return
        }
        // Calculate amount owned by dividing the total value by the last price
        let amount = totalValueInDouble / lastPrice
        // Format the calculated amount and update the `amountOwned` property
        amountOwned = formatNumber(amount)
    }

    // Format a number with up to 6 decimal places and no grouping separator
    private func formatNumber(_ number: Any) -> String {
        // Initialize a number formatter
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal               // Use decimal style for formatting
        formatter.maximumFractionDigits = 6            // Allow up to 6 decimal places
        formatter.minimumFractionDigits = 0            // Use minimum necessary decimal places
        formatter.groupingSeparator = ""               // Remove any grouping (thousands) separators

        // Convert the input number to a Double if possible
        let doubleValue: Double?
        if let numberString = number as? String {
            // If input is a String, try to convert to Double
            doubleValue = Double(numberString)
        } else if let numberDouble = number as? Double {
            // If input is already a Double, assign directly
            doubleValue = numberDouble
        } else {
            // If input is neither, set as nil
            doubleValue = nil
        }

        // Return the formatted number as a String, or "0" if formatting fails
        return formatter.string(for: doubleValue ?? 0) ?? "0"
    }
}
