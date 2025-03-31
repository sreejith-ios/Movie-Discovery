//
//  MovieAPIClient.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)

    var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from the server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        }
    }
}

class MovieAPIClient {
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "65474c2df616ad6bc02fa6effb5538fe"
    private let session = URLSession.shared
    private let jsonDecoder = JSONDecoder()

    init() {
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
    }

    // MARK: - API Calls using Combine

    func fetchMovies() -> AnyPublisher<MovieResponse, APIError> {
        let endpoint = "/discover/movie"
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        return makeRequest(endpoint: endpoint, queryItems: queryItems)
    }

    func searchMovies(query: String) -> AnyPublisher<MovieResponse, APIError> {
        let endpoint = "/search/movie"
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        queryItems.append(URLQueryItem(name: "query", value: query))

        return makeRequest(endpoint: endpoint, queryItems: queryItems)
    }

    func fetchMovieDetails(movieId: Int) -> AnyPublisher<MovieDetail, APIError> {
        let endpoint = "/movie/\(movieId)"
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        return makeRequest(endpoint: endpoint, queryItems: queryItems)
    }

    // MARK: - Helper Methods

    private func makeRequest<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]) -> AnyPublisher<T, APIError> {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .mapError { APIError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, APIError> in
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    return Fail(error: APIError.invalidResponse).eraseToAnyPublisher()
                }

                return Just(data)
                    .decode(type: T.self, decoder: self.jsonDecoder)
                    .mapError { APIError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    // MARK: - API Calls using async/await

    func fetchMoviesAsync() async throws -> MovieResponse {
        let endpoint = "/discover/movie"
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        return try await makeRequestAsync(endpoint: endpoint, queryItems: queryItems)
    }

    func searchMoviesAsync(query: String) async throws -> MovieResponse {
        let endpoint = "/search/movie"
        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        queryItems.append(URLQueryItem(name: "query", value: query))

        return try await makeRequestAsync(endpoint: endpoint, queryItems: queryItems)
    }

    func fetchMovieDetailsAsync(movieId: Int) async throws -> MovieDetail {
        let endpoint = "/movie/\(movieId)"
        let queryItems = [URLQueryItem(name: "api_key", value: apiKey)]

        return try await makeRequestAsync(endpoint: endpoint, queryItems: queryItems)
    }

    private func makeRequestAsync<T: Decodable>(endpoint: String, queryItems: [URLQueryItem]) async throws -> T {
        guard var urlComponents = URLComponents(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }

        urlComponents.queryItems = queryItems

        guard let url = urlComponents.url else {
            throw APIError.invalidURL
        }

        do {
            let (data, response) = try await session.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }

            return try jsonDecoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
