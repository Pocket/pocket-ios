import Foundation


private let imageCacheBaseURL: URL = URL(string: "https://pocket-image-cache.com")!


func imageCacheURL(for imageURL: URL?) -> URL? {
    imageURL.flatMap {
        $0.absoluteString.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
    }.flatMap {
        return URL(string: $0, relativeTo: imageCacheBaseURL)
    }
}
