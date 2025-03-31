//
//  MovieDetailView.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import SwiftUI

struct MovieDetailView: View {
    @StateObject private var viewModel: MovieDetailViewModel
    @EnvironmentObject var favoritesManager: FavoritesManager

    init(movieId: Int) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movieId: movieId))
    }

    var body: some View {
        ScrollView {
            ZStack {
                Group {
                    switch viewModel.state {
                    case .idle:
                        Color.clear.onAppear {
                            viewModel.fetchMovieDetails()
                        }

                    case .loading:
                        loadingView

                    case .loaded(let movie):
                        movieDetailContent(movie)

                    case .error(let message):
                        errorView(message: message)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                if case .loaded(let movie) = viewModel.state {
                    Text(movie.title)
                        .font(.headline)
                        .lineLimit(1)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                if case .loaded(let movieDetail) = viewModel.state {
                    let movie = Movie(
                        id: movieDetail.id,
                        title: movieDetail.title,
                        overview: movieDetail.overview,
                        posterPath: movieDetail.posterPath,
                        releaseDate: movieDetail.releaseDate,
                        voteAverage: movieDetail.voteAverage
                    )
                    Button(action: {
                        favoritesManager.toggleFavorite(movie)
                    }) {
                        Image(systemName: favoritesManager.isFavorite(movie) ? "heart.fill" : "heart")
                            .foregroundColor(favoritesManager.isFavorite(movie) ? .red : .gray)
                    }
                }
            }
        }
    }

    // MARK: - Content Views
    private func movieDetailContent(_ movie: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let backdropURL = movie.backdropURL {
                AsyncImage(url: backdropURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    AsyncImage(url: movie.posterURL) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 180)
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
                                .frame(width: 120, height: 180)
                                .cornerRadius(8)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 180)
                                .cornerRadius(8)
                                .overlay(
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundColor(.gray)
                                )
                        @unknown default:
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 180)
                                .cornerRadius(8)
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(movie.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)

                            Text(String(format: "%.1f", movie.voteAverage))
                                .fontWeight(.semibold)

                            Text("(\(movie.voteCount) votes)")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }

                        infoRow(icon: "calendar", label: "Release Date", value: movie.formattedReleaseDate)

                        if movie.runtime != nil {
                            infoRow(icon: "clock", label: "Runtime", value: movie.formattedRuntime)
                        }

                        infoRow(icon: "film", label: "Genre", value: movie.genresText)
                    }
                    .padding(.top, 4)
                }
                Divider()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Overview")
                        .font(.headline)

                    Text(movie.overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Supporting Views
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.secondary)

            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
            }
        }
    }

    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Text("Loading movie details...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 100)
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
                viewModel.fetchMovieDetails()
            }
            .buttonStyle(.bordered)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding(.top, 100)
    }
}

struct MovieDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MovieDetailView(movieId: 550)
        }
    }
}
