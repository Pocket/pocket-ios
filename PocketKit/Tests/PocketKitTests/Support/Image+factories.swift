import Foundation
@testable import Sync


extension Image {
    @discardableResult
    static func build(
        in space: Space = Space(container: .testContainer),
        source: URL?,
        isDownloaded: Bool = false
    ) -> Image {
        let image: Image = space.new()
        image.source = source
        image.isDownloaded = isDownloaded

        return image
    }
}
