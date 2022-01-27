import Sync
import Foundation
import CoreData


class MockSource: Source {
    private var implementations: [String: Any] = [:]

    var mainContext: NSManagedObjectContext {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func clear() {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func refresh(maxItems: Int, completion: (() -> ())?) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func makeItemsController() -> NSFetchedResultsController<SavedItem> {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func object<T>(id: NSManagedObjectID) -> T? where T : NSManagedObject {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func favorite(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func unfavorite(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func delete(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func archive(item: SavedItem) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func fetchSlateLineup(_ identifier: String) async throws -> SlateLineup? {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func fetchSlate(_ slateID: String) async throws -> Slate? {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func savedRecommendationsService() -> SavedRecommendationsService {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func save(recommendation: Slate.Recommendation) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }

    func archive(recommendation: Slate.Recommendation) {
        fatalError("\(Self.self)#\(#function) is not implemented")
    }
}

extension MockSource {
    typealias FetchArchivedItemsImpl = () async throws -> [ArchivedItem]

    func stubFetchArchivedItems(impl: @escaping FetchArchivedItemsImpl) {
        implementations["fetchArchivedItems()"] = impl
    }


    func fetchArchivedItems() async throws -> [ArchivedItem] {
        guard let impl = implementations["fetchArchivedItems()"] as? FetchArchivedItemsImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        return try await impl()
    }
}
