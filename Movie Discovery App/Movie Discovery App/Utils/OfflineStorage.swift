//
//  OfflineStorage.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import Combine

// MARK: - Offline Storage Manager
class OfflineStorageManager {
    private let cacheKey = "cachedMovies"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    func cacheMovies(_ movies: [Movie]) {
        do {
            let data = try encoder.encode(movies)
            UserDefaults.standard.set(data, forKey: cacheKey)
        } catch {
            print("Error caching movies: \(error)")
        }
    }

    func getCachedMovies() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else { return [] }

        do {
            return try decoder.decode([Movie].self, from: data)
        } catch {
            print("Error retrieving cached movies: \(error)")
            return []
        }
    }

    func hasCachedMovies() -> Bool {
        return UserDefaults.standard.data(forKey: cacheKey) != nil
    }
}

extension MovieListViewModel {
    func enableOfflineSupport() {
        let offlineStorage = OfflineStorageManager()
        $state
            .sink { [weak self] state in
                if case .loaded(let movies) = state {
                    offlineStorage.cacheMovies(movies)
                }
            }
            .store(in: &self.cancellables)
        $state
            .sink { [weak self] state in
                if case .error = state, offlineStorage.hasCachedMovies() {
                    let cachedMovies = offlineStorage.getCachedMovies()
                    if !cachedMovies.isEmpty {
                        self?.state = .loaded(cachedMovies)
                    }
                }
            }
            .store(in: &self.cancellables)
    }
}
