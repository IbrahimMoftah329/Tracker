//
//  ThemedModifier.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/30/24.
//

import Foundation
import SwiftUI

struct ThemedModifier: ViewModifier {
    @AppStorage("selectedTheme") var selectedTheme: AppTheme = .system // Accesses the selected theme from user settings (AppStorage)
    @AppStorage("accentColor") var accentColorName: String = "Blue" // Accesses the selected accent color from user settings (AppStorage)
    @Environment(\.colorScheme) private var colorScheme // Gets the current system color scheme (light or dark) from the environment

    // Determines the current accent color based on the stored color name
    var currentAccentColor: Color {
        // If accent color is empty or set to "Default", returns clear color
        if accentColorName.isEmpty || accentColorName == "Default" {
            return Color.clear
        } else {
            // Otherwise, fetches the actual color based on name
            return getAccentColor()
        }
    }

    // Helper function to map color name strings to actual Color values
    private func getAccentColor() -> Color {
        switch accentColorName {
        case "Red": return .red
        case "Green": return .green
        case "Yellow": return .yellow
        case "Orange": return .orange
        case "Purple": return .purple
        case "Pink": return .pink
        default: return .blue // Defaults to blue if no match is found
        }
    }

    // Determines the text color based on the theme (dark/light or system)
    var textColor: Color {
        if selectedTheme == .system {
            // If theme is set to system, adapts to system appearance (light or dark)
            return colorScheme == .dark ? .white : .black
        } else {
            // If theme is explicitly set, uses either white (dark mode) or black (light mode)
            return selectedTheme == .dark ? .white : .black
        }
    }

    // Determines the background color based on the theme (dark/light or system)
    var backgroundColor: Color {
        if selectedTheme == .system {
            // Uses system background color which adapts automatically
            return Color(.systemBackground)
        } else {
            // Explicitly sets background color to black (dark mode) or white (light mode)
            return selectedTheme == .dark ? Color.black : Color.white
        }
    }

    // Defines the body of the modifier
    func body(content: Content) -> some View {
        content
            // Sets the text color to either the accent color or the theme text color
            .foregroundColor(currentAccentColor == .clear ? textColor : currentAccentColor)
            // Sets the background color with safe area ignored, filling the whole view
            .background(backgroundColor.ignoresSafeArea())
            // Applies the preferred color scheme based on theme selection
            .preferredColorScheme(selectedTheme == .system ? nil : (selectedTheme == .dark ? .dark : .light))
    }
}

// Extension for easy application of ThemedModifier
extension View {
    func applyTheme() -> some View {
        // Applies the ThemedModifier to any view using the `applyTheme` function
        self.modifier(ThemedModifier())
    }
}
