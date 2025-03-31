//
//  MovieDiscoveryApp.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import SwiftUI

@main
struct MovieDiscoveryApp: App {
    @StateObject private var favoritesManager = FavoritesManager()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(favoritesManager)
        }
    }
}
