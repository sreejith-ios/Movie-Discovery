//
//  MovieModels.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation

// Response model for list of movies
struct MovieResponse: Decodable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
}

// Basic movie model for list view
struct Movie: Identifiable, Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double

    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var thumbnailURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w200\(posterPath)")
    }

    var releaseYear: String {
        guard let releaseDate = releaseDate, releaseDate.count >= 4 else {
            return "Unknown"
        }
        return String(releaseDate.prefix(4))
    }
}

// Detailed movie model for detail view
struct MovieDetail: Identifiable, Decodable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int?
    let genres: [Genre]?

    var posterURL: URL? {
        guard let posterPath = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath = backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/original\(backdropPath)")
    }

    var formattedReleaseDate: String {
        guard let releaseDate = releaseDate else { return "Unknown" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        guard let date = dateFormatter.date(from: releaseDate) else {
            return releaseDate
        }

        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }

    var formattedRuntime: String {
        guard let runtime = runtime else { return "Unknown" }
        let hours = runtime / 60
        let minutes = runtime % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var genresText: String {
        guard let genres = genres, !genres.isEmpty else {
            return "No genres"
        }

        return genres.map { $0.name }.joined(separator: ", ")
    }
}

struct Genre: Decodable {
    let id: Int
    let name: String
}
