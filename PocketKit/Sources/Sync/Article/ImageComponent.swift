import Foundation
import PocketGraph

public struct ImageComponent: Encodable, Equatable, Hashable {
    public let caption: String?
    public let credit: String?
    public let height: UInt?
    public let width: UInt?
    public let id: Int
    public let source: URL?

    enum CodingKeys: String, CodingKey {
        case caption
        case credit
        case height
        case width
        case id = "imageID"
        case source = "src"
    }
}

extension ImageComponent {
    init(_ marticle: ImageParts) {
        self.init(
            caption: marticle.caption,
            credit: marticle.credit,
            height: marticle.height.flatMap(UInt.init),
            width: marticle.width.flatMap(UInt.init),
            id: marticle.imageID,
            source: marticle.src.addingPercentEncoding(withAllowedCharacters: .whitespaces.inverted).flatMap(URL.init)
        )
    }
}

extension ImageComponent: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        caption = try container.decodeIfPresent(String.self, forKey: .caption)
        credit = try container.decodeIfPresent(String.self, forKey: .credit)
        height = try container.decodeIfPresent(UInt.self, forKey: .height)
        width = try container.decodeIfPresent(UInt.self, forKey: .width)
        id = try container.decode(Int.self, forKey: .id)

        source = try container.decode(String.self, forKey: .source)
            .addingPercentEncoding(withAllowedCharacters: .whitespaces.inverted)
            .flatMap(URL.init)
    }
}
