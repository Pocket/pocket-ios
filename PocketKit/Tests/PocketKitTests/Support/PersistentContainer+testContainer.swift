import Sync

extension PersistentContainer {
    static let testContainer = PersistentContainer(storage: .inMemory, userDefaults: .standard)
}

extension Space {
    static func testSpace() -> Space {
        Space(context: PersistentContainer.testContainer.viewContext)
    }
}
