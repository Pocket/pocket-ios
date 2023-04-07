import Foundation
import PocketGraph

public enum ItemVideoness: String, Equatable, Hashable {
    case noVideos = "NO_VIDEOS"
    case hasVideos = "HAS_VIDEOS"
    case isVideo = "IS_VIDEO"
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
