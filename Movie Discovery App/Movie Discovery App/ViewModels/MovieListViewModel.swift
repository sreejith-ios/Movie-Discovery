//
//  MovieListViewModel.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import Combine

enum MovieListState {
    case idle
    case loading
    case loaded([Movie])
    case error(String)
}

class MovieListViewModel: ObservableObject {
    @Published var state: MovieListState = .idle
    @Published var searchText: String = ""

    private let apiClient: MovieAPIClient
    var cancellables = Set<AnyCancellable>()
    private var searchPublisher: AnyPublisher<String, Never> {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init(apiClient: MovieAPIClient = MovieAPIClient()) {
        self.apiClient = apiClient
        setupSearchSubscription()
    }
    private func setupSearchSubscription() {
        searchPublisher
            .sink { [weak self] searchTerm in
                if searchTerm.isEmpty {
                    self?.fetchMovies()
                } else {
                    self?.searchMovies(query: searchTerm)
                }
            }
            .store(in: &cancellables)
    }
    func fetchMovies() {
        state = .loading

        apiClient.fetchMovies()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(error.description)
                }
            }, receiveValue: { [weak self] response in
                self?.state = .loaded(response.results)
            })
            .store(in: &cancellables)
    }
    private func searchMovies(query: String) {
        state = .loading

        apiClient.searchMovies(query: query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .error(error.description)
                }
            }, receiveValue: { [weak self] response in
                self?.state = .loaded(response.results)
            })
            .store(in: &cancellables)
    }
    @MainActor
    func fetchMoviesAsync() async {
        state = .loading

        do {
            let response = try await apiClient.fetchMoviesAsync()
            state = .loaded(response.results)
        } catch let error as APIError {
            state = .error(error.description)
        } catch {
            state = .error("An unknown error occurred")
        }
    }
    @MainActor
    func searchMoviesAsync(query: String) async {
        state = .loading

        do {
            let response = try await apiClient.searchMoviesAsync(query: query)
            state = .loaded(response.results)
        } catch let error as APIError {
            state = .error(error.description)
        } catch {
            state = .error("An unknown error occurred")
        }
    }
}
