//
//  Movie_Discovery_AppTests.swift
//  Movie Discovery AppTests
//
//  Created by Sreejith Rajan on 31/03/25.
//

import XCTest
import Combine
@testable import Movie_Discovery_App

class MockMovieAPIClient: MovieAPIClient {
    var mockMovieResponse = MovieResponse(
        page: 1,
        results: [
            Movie(
                id: 1,
                title: "Test Movie",
                overview: "This is a test movie",
                posterPath: "/test.jpg",
                releaseDate: "2023-01-01",
                voteAverage: 7.5
            )
        ],
        totalPages: 1,
        totalResults: 1
    )

    var shouldFail = false
    var error: APIError = .invalidResponse

    override func fetchMovies() -> AnyPublisher<MovieResponse, APIError> {
        if shouldFail {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Just(mockMovieResponse)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
    }

    override func searchMovies(query: String) -> AnyPublisher<MovieResponse, APIError> {
        if shouldFail {
            return Fail(error: error).eraseToAnyPublisher()
        } else {
            return Just(mockMovieResponse)
                .setFailureType(to: APIError.self)
                .eraseToAnyPublisher()
        }
    }
}

class MovieListViewModelTests: XCTestCase {
    var viewModel: MovieListViewModel!
    var mockAPIClient: MockMovieAPIClient!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockMovieAPIClient()
        viewModel = MovieListViewModel(apiClient: mockAPIClient)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAPIClient = nil
        cancellables = nil
        super.tearDown()
    }

    func testFetchMoviesSuccess() {
        let expectation = XCTestExpectation(description: "Movies loaded successfully")
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .loaded(let movies) = state {
                    XCTAssertEqual(movies.count, 1)
                    XCTAssertEqual(movies.first?.title, "Test Movie")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.fetchMovies()
        wait(for: [expectation], timeout: 1.0)
    }

    func testFetchMoviesFailure() {
        let expectation = XCTestExpectation(description: "Error when loading movies")
        mockAPIClient.shouldFail = true
        mockAPIClient.error = .networkError(NSError(domain: "test", code: 404, userInfo: nil))
        viewModel.$state
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertTrue(message.contains("Network error"))
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        viewModel.fetchMovies()
        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchMovies() {
        let expectation = XCTestExpectation(description: "Search results loaded")
        mockAPIClient.mockMovieResponse = MovieResponse(
            page: 1,
            results: [
                Movie(
                    id: 2,
                    title: "Search Result",
                    overview: "This is a search result",
                    posterPath: "/search.jpg",
                    releaseDate: "2023-02-02",
                    voteAverage: 8.0
                )
            ],
            totalPages: 1,
            totalResults: 1
        )
        viewModel.$state
            .dropFirst(2)
            .sink { state in
                if case .loaded(let movies) = state {
                    XCTAssertEqual(movies.count, 1)
                    XCTAssertEqual(movies.first?.title, "Search Result")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchText = "test query"
        wait(for: [expectation], timeout: 1.0)
    }
}
