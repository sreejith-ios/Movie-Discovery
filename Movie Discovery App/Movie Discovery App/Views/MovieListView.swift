//
//  MovieListView.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import SwiftUI

struct MovieListView: View {
    @StateObject private var viewModel = MovieListViewModel()
    @State private var selectedMovie: Movie?

    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    switch viewModel.state {
                    case .idle:
                        Color.clear.onAppear {
                            viewModel.fetchMovies()
                        }

                    case .loading:
                        loadingView

                    case .loaded(let movies):
                        if movies.isEmpty {
                            emptyStateView
                        } else {
                            movieListContent(movies)
                        }

                    case .error(let message):
                        errorView(message: message)
                    }
                }
            }
            .navigationTitle("Movie Discovery")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search movies")
        }
    }

    // MARK: - Content Views
    private func movieListContent(_ movies: [Movie]) -> some View {
        List {
            ForEach(movies) { movie in
                NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                    MovieRowView(movie: movie)
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.fetchMoviesAsync()
        }
    }

    // MARK: - Supporting Views
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading movies...")
                .foregroundColor(.secondary)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No movies found")
                .font(.headline)

            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button("Browse Popular Movies") {
                viewModel.searchText = ""
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.orange)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Try Again") {
                viewModel.fetchMovies()
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

struct MovieRowView: View {
    let movie: Movie
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: movie.thumbnailURL) { phase in
                switch phase {
                case .empty:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "film")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                        .clipped()
                case .failure:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                        .overlay(
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.gray)
                        )
                @unknown default:
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 120)
                        .cornerRadius(8)
                }
            }

            // Movie info
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)

                Text(movie.releaseYear)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)

                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.subheadline)
                }

                Text(movie.overview)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }

            Spacer()

            // Favorite button
            Button(action: {
                favoritesManager.toggleFavorite(movie)
            }) {
                Image(systemName: favoritesManager.isFavorite(movie) ? "heart.fill" : "heart")
                    .foregroundColor(favoritesManager.isFavorite(movie) ? .red : .gray)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
    }
}

struct MovieListView_Previews: PreviewProvider {
    static var previews: some View {
        MovieListView()
    }
}
