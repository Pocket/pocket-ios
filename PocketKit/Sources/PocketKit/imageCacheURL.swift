import UIKit

private let imageCacheFilters = "/fit-in/\(Int(UIScreen.main.nativeBounds.width))x\(Int(UIScreen.main.nativeBounds.height))/filters:format(jpeg):quality(60):no_upscale():strip_exif()"
private let imageCacheBaseURLComponents = URLComponents(string: "https://pocket-image-cache.com")!

func imageCacheURL(for imageURL: URL?) -> URL? {
    imageURL
        .flatMap { $0.absoluteString }
        .flatMap { imageURLString in
            var components = imageCacheBaseURLComponents
            components.path = [
                imageCacheFilters,
                imageURLString
            ].joined(separator: "/")

            return components.url
        }
}
