import Foundation


extension Item {
    var hasImage: ItemImageness? {
        imageness.flatMap(ItemImageness.init)
    }

    var hasVideo: ItemVideoness? {
        videoness.flatMap(ItemVideoness.init)
    }
}
