import Foundation


extension Item {
    public var hasImage: ItemImageness? {
        imageness.flatMap(ItemImageness.init)
    }

    public var hasVideo: ItemVideoness? {
        videoness.flatMap(ItemVideoness.init)
    }
}
