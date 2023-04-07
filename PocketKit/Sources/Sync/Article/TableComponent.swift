import PocketGraph

public struct TableComponent: Codable, Equatable, Hashable {
    public let html: String
}

extension TableComponent {
    init(_ marticle: MarticleTableParts) {
        self.init(html: marticle.html)
    }
}
