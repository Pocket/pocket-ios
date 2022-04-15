@testable import Sync


extension Item {
    static func build(
        in space: Space = Space(container: .testContainer),
        remoteID: String = "item-1"
    ) -> Item {
        let item: Item = space.new()
        item.remoteID = remoteID
        return item
    }
}
