import Sync
import Foundation

class MockSavedItemsController: SavedItemsController {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    var delegate: SavedItemsControllerDelegate?

    var predicate: NSPredicate?

    var fetchedObjects: [SavedItem]?
}

extension MockSavedItemsController {
    static let performFetch = "performFetch"
    typealias PerformFetchImpl = () -> Void
    struct PerformFetchCall { }

    func stubPerformFetch(impl: @escaping PerformFetchImpl) {
        implementations[Self.performFetch] = impl
    }

    func performFetch() throws {
        guard let impl = implementations[Self.performFetch] as? PerformFetchImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.performFetch] = (calls[Self.performFetch] ?? []) + [PerformFetchCall()]

        impl()
    }

    func performFetchCall(at index: Int) -> PerformFetchCall? {
        guard let calls = calls[Self.performFetch], calls.count > index else {
            return nil
        }

        return calls[index] as? PerformFetchCall
    }
}

extension MockSavedItemsController {
    static let indexPathForObject = "indexPathForObject"
    typealias IndexPathForObjectImpl = (SavedItem) -> IndexPath?
    struct IndexPathForObjectCall {
        let savedItem: SavedItem
    }

    func stubIndexPathForObject(impl: @escaping IndexPathForObjectImpl) {
        implementations[Self.indexPathForObject] = impl
    }

    func indexPath(forObject savedItem: SavedItem) -> IndexPath? {
        guard let impl = implementations[Self.indexPathForObject] as? IndexPathForObjectImpl else {
            fatalError("\(Self.self).\(#function) has not been implemented")
        }

        calls[Self.indexPathForObject] = (calls[Self.indexPathForObject] ?? []) + [
            IndexPathForObjectCall(savedItem: savedItem)
        ]

        return impl(savedItem)
    }
}
