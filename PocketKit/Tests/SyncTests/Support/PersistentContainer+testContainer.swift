import CoreData

@testable import Sync

extension PersistentContainer {
    static let testContainer = PersistentContainer(storage: .inMemory, userDefaults: .standard, groupId: "group.com.ideashower.ReadItLaterPro")
}

extension Space {
    static func testSpace() -> Space {
        Space(backgroundContext: PersistentContainer.testContainer.newBackgroundContext(), viewContext: PersistentContainer.testContainer.viewContext)
    }
}
