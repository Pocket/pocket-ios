import CoreData

@testable import Sync

extension PersistentContainer {
    static let testContainer = PersistentContainer(storage: .inMemory)
}
