import Foundation


public enum ItemImageness: String, Equatable, Hashable {
    case noImages
    case hasImages
    case isImage
}

extension ItemImageness {
    typealias Remote = Imageness

    init?(remote: Remote) {
        switch remote {
        case .noImages:
            self = .noImages
        case .hasImages:
            self = .hasImages
        case .isImage:
            self = .isImage
        default:
            return nil
        }
    }
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
