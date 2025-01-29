//
//  MainTabView.swift
//  Tracker
//
//  Created by Ibrahim Moftah on 9/24/24.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    init() {
        // Customize the tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // Set background color of the tab bar
        appearance.backgroundColor = UIColor.black
        
        // Set the color of the selected item
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        
        // Set the color of the unselected item
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.lightGray
        
        // Apply appearance settings to all appearances of the tab bar
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            Color(.gray)  // Dark grey background for the entire view
                .ignoresSafeArea()  // Make sure the background extends to the edges

            TabView {
                // Tracker Tab
                ProductsView()
                    .tabItem {
                        Label("Tracker", systemImage: "list.dash")
                    }
                
                // Search Tab
                SearchView()
                    .tabItem {
                        Label("Search", systemImage: "magnifyingglass")
                    }

                // Watchlist Tab
                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "star.fill")
                    }

                // Settings Tab
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}

