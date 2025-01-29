//
//  SettingsView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import SwiftUI

// Enum for available app themes
enum AppTheme: String, CaseIterable {
    case light = "Light" // Light theme
    case dark = "Dark" // Dark theme
    case system = "System" // System default theme
}

// View for adjusting app settings like preferred currency, theme, and accent color
struct SettingsView: View {
    @AppStorage("preferredProduct") var preferredProduct: String = "USD" // User's preferred quote currency
    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .system // Selected app theme, default is system
    @AppStorage("accentColor") var accentColorName: String = "Blue" // User's preferred accent color, default is Blue

    // Available products and accent colors
    let products = ["USD", "BTC", "ETH", "USDT", "USDC", "EUR", "GBP", "DAI"] // List of available products
    let accentColors: [Color] = [.clear, .red, .blue, .green, .yellow, .orange, .purple, .pink] // Array of accent colors
    let accentColorNames: [String] = ["Default", "Red", "Blue", "Green", "Yellow", "Orange", "Purple", "Pink"] // Names of accent colors

    @Environment(\.colorScheme) var colorScheme // Environment variable for current color scheme (light or dark)

    var body: some View {
        Form {
            // Section for selecting preferred quote currency
            Section(header: Text("Preferred Pair")) {
                Picker("Quote Currency", selection: $preferredProduct) {
                    ForEach(products, id: \.self) { product in
                        Text(product).tag(product) // Each product option in the picker
                    }
                }
                .pickerStyle(MenuPickerStyle()) // Display picker as a dropdown menu
            }

            // Section for selecting the app theme
            Section(header: Text("Theme")) {
                Picker("Select Theme", selection: $selectedTheme) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        Text(theme.rawValue).tag(theme) // Each theme option in the picker
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // Display picker in a segmented control style
            }

            // Section for selecting the accent color
            Section(header: Text("Accent Color")) {
                ForEach(0..<accentColors.count, id: \.self) { index in
                    Button(action: {
                        accentColorName = accentColorNames[index] // Save selected accent color name
                    }) {
                        HStack {
                            Text(accentColorNames[index]) // Display name of accent color
                                .foregroundColor(colorScheme == .dark ? .white : .black) // Set text color based on theme
                            
                            Spacer() // Push text to the left
                            
                            if accentColorName == accentColorNames[index] {
                                // Highlight selected color with a circle
                                Circle()
                                    .fill(accentColors[index]) // Fill circle with the selected color
                                    .frame(width: 12, height: 12) // Circle dimensions
                            }
                        }
                        .padding(15) // Padding for the color selection row
                        .frame(height: 35) // Fixed height for the button
                        .background(accentColorName == accentColorNames[index] ? Color.gray.opacity(0.3) : Color.clear) // Highlight selected button
                        .cornerRadius(8) // Rounded corners for button
                    }
                }
            }
        }
        .navigationTitle("Settings") // Title for the settings view
    }
}
