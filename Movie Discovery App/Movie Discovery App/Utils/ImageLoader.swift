//
//  ImageLoader.swift
//  Movie Discovery App
//
//  Created by Sreejith Rajan on 31/03/25.
//

import Foundation
import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?
    private var cache = URLCache.shared
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    deinit {
        cancel()
    }

    func load() {
        guard let url = url else {
            return
        }
        if let cachedResponse = cache.cachedResponse(for: URLRequest(url: url)),
           let image = UIImage(data: cachedResponse.data) {
            self.image = image
            return
        }
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                self?.image = image
            }
    }

    func cancel() {
        cancellable?.cancel()
    }
}

struct CachedAsyncImage<Content: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (Image?) -> Content
    private let placeholder: Content

    init(url: URL?, @ViewBuilder content: @escaping (Image?) -> Content, @ViewBuilder placeholder: () -> Content) {
        self._loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.content = content
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let image = loader.image {
                content(Image(uiImage: image))
            } else {
                placeholder
            }
        }
        .onAppear(perform: loader.load)
        .onDisappear(perform: loader.cancel)
    }
}

extension CachedAsyncImage where Content == AnyView {
    init(url: URL?) {
        self.init(
            url: url,
            content: { image in
                if let image = image {
                    return AnyView(image.resizable())
                } else {
                    return AnyView(Color.gray)
                }
            },
            placeholder: {
                AnyView(ProgressView())
            }
        )
    }
}
