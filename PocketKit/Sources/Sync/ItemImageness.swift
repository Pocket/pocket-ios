import Foundation
import PocketGraph

public enum ItemImageness: String, Equatable, Hashable {
    case noImages = "NO_IMAGES"
    case hasImages = "HAS_IMAGES"
    case isImage = "IS_IMAGE"
}

extension Imageness {
    init(imageness: ItemImageness) {
        switch imageness {
        case .noImages:
            self = .noImages
        case .hasImages:
            self = .hasImages
        case .isImage:
            self = .isImage
        }
    }
}
