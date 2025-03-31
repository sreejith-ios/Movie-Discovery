//
//  MainTabView.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some View {
        TabView {
            MovieListView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Discover", systemImage: "film")
                }

            FavoritesView()
                .environmentObject(favoritesManager)
                .tabItem {
                    Label("Favorites", systemImage: "heart")
                }
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
