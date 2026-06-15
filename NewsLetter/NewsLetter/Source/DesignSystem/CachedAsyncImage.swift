//
//  CachedAsyncImage.swift
//  NewsLetter
//

import SwiftUI

private final class ImageCache {
    static let shared = ImageCache()
    private var cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func get(_ url: String) -> UIImage? {
        cache.object(forKey: url as NSString)
    }

    func set(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString, cost: image.jpegData(compressionQuality: 1)?.count ?? 0)
    }
}

struct CachedAsyncImage<Placeholder: View>: View {
    private let url: String
    private let placeholder: Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false

    init(url: String, @ViewBuilder placeholder: () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder()
    }

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder
                    .onAppear { load() }
            }
        }
        .onChange(of: url) { _, newURL in
            image = nil
            isLoading = false
            load(for: newURL)
        }
    }

    private func load(for targetURL: String? = nil) {
        let urlToLoad = targetURL ?? url
        if let cached = ImageCache.shared.get(urlToLoad) {
            image = cached
            return
        }
        guard !isLoading, let requestURL = URL(string: urlToLoad) else { return }
        isLoading = true

        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: requestURL)
                if let loaded = UIImage(data: data) {
                    ImageCache.shared.set(loaded, for: urlToLoad)
                    await MainActor.run { image = loaded }
                }
            } catch {}
            await MainActor.run { isLoading = false }
        }
    }
}
