import Foundation

extension Item {
    public var bestURL: String {
        resolvedURL ?? givenURL
    }

    public var hasImage: ItemImageness? {
        imageness.flatMap(ItemImageness.init)
    }

    public var hasVideo: ItemVideoness? {
        videoness.flatMap(ItemVideoness.init)
    }
}
