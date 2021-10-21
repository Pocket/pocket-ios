import Foundation


public struct ImageComponent: Codable, Equatable, Hashable {
    public let caption: String?
    public let credit: String?
    public let height: UInt?
    public let width: UInt?
    public let id: Int
    public let source: URL

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
            id: marticle.imageId,
            source: URL(string: marticle.src)!
        )
    }
}
