import Foundation
@testable import Sync


extension Image {
    @discardableResult
    static func build(
        in space: Space = Space(container: .testContainer),
        source: URL?
    ) -> Image {
        let image: Image = space.new()
        image.source = source

        return image
    }
}
