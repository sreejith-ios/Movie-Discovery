//
//  FavoritesView.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        NavigationView {
            ZStack {
                if favoritesManager.favoriteMovies.isEmpty {
                    emptyStateView
                } else {
                    List {
                        ForEach(favoritesManager.favoriteMovies) { movie in
                            NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                MovieRowView(movie: movie)
                            }
                            .listRowSeparator(.hidden)
                            .swipeActions {
                                Button(role: .destructive) {
                                    withAnimation {
                                        favoritesManager.removeFavorite(movie)
                                    }
                                } label: {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("No Favorites Yet")
                .font(.headline)

            Text("Movies you add to favorites will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink(destination: MovieListView()) {
                HStack {
                    Image(systemName: "film")
                    Text("Browse Movies")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.bordered)
            .padding()
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(FavoritesManager())
    }
}
