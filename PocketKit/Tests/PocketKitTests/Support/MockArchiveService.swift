import Sync
import Combine
import CoreData


class MockArchiveService: ArchiveService {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    @Published
    var _results: [SavedItemResult] = []
    var results: Published<[SavedItemResult]>.Publisher { $_results }

    let _itemUpdated: PassthroughSubject<SavedItem, Never> = .init()
    var itemUpdated: AnyPublisher<SavedItem, Never> { _itemUpdated.eraseToAnyPublisher() }

    var filters: [ArchiveServiceFilter] = []

    func object(id: NSManagedObjectID) -> SavedItem? {
        for result in _results {
            switch result {
            case .loaded(let savedItem):
                if savedItem.objectID == id {
                    return savedItem
                }
            default:
                break
            }
        }

        return nil
    }
}

extension MockArchiveService {
    static let fetchAt = "fetchAt"
    typealias FetchImpl = ([Int]?) -> Void
    struct FetchCall {
        let indexes: [Int]?
        let isFavorite: Bool?
    }

    func stubFetch(impl: @escaping FetchImpl) {
        implementations[Self.fetchAt] = impl
    }

    func fetchCall(at index: Int) -> FetchCall? {
        guard let calls = calls[Self.fetchAt],
              calls.count > index else {
            return nil
        }

        return calls[index] as? FetchCall
    }

    func fetch(at indexes: [Int]?) {
        guard let impl = implementations[Self.fetchAt] as? FetchImpl else {
            fatalError("\(Self.self) has not been stubbed")
        }

        calls[Self.fetchAt] = (calls[Self.fetchAt] ?? []) + [
            FetchCall(indexes: indexes, isFavorite: nil)
        ]

        impl(indexes)
    }
}

extension MockArchiveService {
    static let refresh = "refresh"
    typealias RefreshImpl = ((() -> Void)?) -> Void
    struct RefreshCall {
        let completion: (() -> Void)?
    }

    func stubRefresh(impl: @escaping RefreshImpl) {
        implementations[Self.refresh] = impl
    }

    func refreshCall(at index: Int) -> RefreshCall? {
        guard let calls = calls[Self.refresh],
              calls.count > index else {
            return nil
        }

        return calls[index] as? RefreshCall
    }

    func refresh(completion: (() -> Void)?) {
        guard let impl = implementations[Self.refresh] as? RefreshImpl else {
            fatalError("\(Self.self) has not been stubbed")
        }

        calls[Self.refresh] = (calls[Self.refresh] ?? []) + [
            RefreshCall(completion: completion)
        ]

        impl(completion)
    }
}

