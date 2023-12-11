// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PocketGraph

public enum VideoComponentError: Error {
    case invalidURL
}

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
    /// Convenience initalizer using a `VideoParts` instance.
    /// Throws an error if the parts does not contain a valid `URL`
    /// - Parameter marticle: the `VideoParts` instance
    init(_ videoParts: VideoParts) throws {
        guard let url = URL(string: videoParts.src) else {
            throw VideoComponentError.invalidURL
        }
        self.init(
            id: videoParts.videoID,
            type: VideoType(rawValue: videoParts.type.rawValue) ?? .unknown,
            source: url,
            vid: videoParts.vid,
            width: videoParts.width.flatMap(UInt.init),
            height: videoParts.height.flatMap(UInt.init),
            length: videoParts.length.flatMap(UInt.init)
        )
    }
}
