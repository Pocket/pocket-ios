import CoreData

@testable import Sync

extension PersistentContainer {
    static let testContainer = PersistentContainer(storage: .inMemory)
}

extension Space {
    static func testSpace() -> Space {
        Space(context: PersistentContainer.testContainer.viewContext)
    }
}
