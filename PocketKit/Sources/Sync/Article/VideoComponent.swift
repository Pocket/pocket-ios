import Foundation
import PocketGraph

public struct VideoComponent: Codable, Equatable, Hashable {
    public let id: Int
    public let type: VideoType
    public let source: URL
    public let vid: String?
    public let width: UInt?
    public let height: UInt?
    public let length: UInt?

    enum CodingKeys: String, CodingKey {
        case id = "videoID"
        case type
        case source = "src"
        case vid
        case width
        case height
        case length
    }
}

public extension VideoComponent {
    enum VideoType: String, Codable {
        case youtube = "YOUTUBE"
        case vimeoLink = "VIMEO_LINK"
        case vimeoMoogaloop = "VIMEO_MOOGALOOP"
        case vimeoIframe = "VIMEO_IFRAME"
        case html5 = "HTML5"
        case flash = "FLASH"
        case brightcove = "BRIGHTCOVE"
        case unknown
    }
}

extension VideoComponent {
    init(_ marticle: VideoParts) {
        self.init(
            id: marticle.videoID,
            type: VideoType(rawValue: marticle.type.rawValue) ?? .unknown,
            source: URL(string: marticle.src)!,
            vid: marticle.vid,
            width: marticle.width.flatMap(UInt.init),
            height: marticle.height.flatMap(UInt.init),
            length: marticle.length.flatMap(UInt.init)
        )
    }
}
