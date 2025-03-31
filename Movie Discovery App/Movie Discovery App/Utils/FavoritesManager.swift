//
//  FavoritesManager.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import Combine

// MARK: - Favorites Manager
class FavoritesManager: ObservableObject {
    @Published var favoriteMovies: [Movie] = []

    private let favoritesKey = "favoriteMovies"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        loadFavorites()
    }
    func addFavorite(_ movie: Movie) {
        if !isFavorite(movie) {
            favoriteMovies.append(movie)
            saveFavorites()
        }
    }
    func removeFavorite(_ movie: Movie) {
        favoriteMovies.removeAll { $0.id == movie.id }
        saveFavorites()
    }
    func toggleFavorite(_ movie: Movie) {
        if isFavorite(movie) {
            removeFavorite(movie)
        } else {
            addFavorite(movie)
        }
    }
    func isFavorite(_ movie: Movie) -> Bool {
        return favoriteMovies.contains(where: { $0.id == movie.id })
    }
    private func saveFavorites() {
        do {
            let data = try encoder.encode(favoriteMovies)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("Error saving favorites: \(error)")
        }
    }

    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }

        do {
            favoriteMovies = try decoder.decode([Movie].self, from: data)
        } catch {
            print("Error loading favorites: \(error)")
        }
    }
}
