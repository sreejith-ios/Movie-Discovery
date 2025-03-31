//
//  MovieDetailViewModel.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import Combine

enum MovieDetailState {
    case idle
    case loading
    case loaded(MovieDetail)
    case error(String)
}

class MovieDetailViewModel: ObservableObject {
    @Published var state: MovieDetailState = .idle

    private let apiClient: MovieAPIClient
    private let movieId: Int
    private var cancellables = Set<AnyCancellable>()

    init(movieId: Int, apiClient: MovieAPIClient = MovieAPIClient()) {
        self.movieId = movieId
        self.apiClient = apiClient
    }

    func fetchMovieDetails() {
        state = .loading

        apiClient.fetchMovieDetails(movieId: movieId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(error.description)
                }
            }, receiveValue: { [weak self] movieDetail in
                self?.state = .loaded(movieDetail)
            })
            .store(in: &cancellables)
    }

    @MainActor
    func fetchMovieDetailsAsync() async {
        state = .loading

        do {
            let movieDetail = try await apiClient.fetchMovieDetailsAsync(movieId: movieId)
            state = .loaded(movieDetail)
        } catch let error as APIError {
            state = .error(error.description)
        } catch {
            state = .error("An unknown error occurred")
        }
    }
}
