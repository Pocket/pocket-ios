import Foundation

extension UnmanagedItem {
    public var bestURL: URL? {
        resolvedURL ?? givenURL
    }
}
