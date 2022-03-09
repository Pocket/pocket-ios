import Foundation


public enum ItemVideoness: String, Equatable, Hashable {
    case noVideos
    case hasVideos
    case isVideo
}

extension ItemVideoness {
    typealias Remote = Videoness

    init?(remote: Remote) {
        switch remote {
        case .noVideos:
            self = .noVideos
        case .hasVideos:
            self = .hasVideos
        case .isVideo:
            self = .isVideo
        default:
            return nil
        }
    }
}

extension Videoness {
    init(videoness: ItemVideoness) {
        switch videoness {
        case .noVideos:
            self = .noVideos
        case .hasVideos:
            self = .hasVideos
        case .isVideo:
            self = .isVideo
        }
    }
}
