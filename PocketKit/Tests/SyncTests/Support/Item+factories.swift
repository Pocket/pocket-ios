import Foundation
@testable import Sync


extension Item {
    static func build(
        in space: Space = Space(container: .testContainer),
        remoteID: String? = "item-1",
        title: String? = "Item 1 Title",
        resolvedURL: URL? = URL(string: "https://getpocket.com")!
    ) -> Item {
        let item: Item = space.new()
        item.remoteID = remoteID
        item.title = title
        item.resolvedURL = resolvedURL
        return item
    }
}
