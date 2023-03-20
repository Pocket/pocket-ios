import Sync

extension PersistentContainer {
    static let testContainer = PersistentContainer(storage: .inMemory, userDefaults: .standard)
}

extension Space {
    static func testSpace() -> Space {
        Space(backgroundContext: PersistentContainer.testContainer.newBackgroundContext(), viewContext: PersistentContainer.testContainer.viewContext)
    }
}
