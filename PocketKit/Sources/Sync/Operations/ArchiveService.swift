import Apollo
import Combine
import CoreData
import PocketGraph

public protocol ArchiveService: AnyObject {
    var results: Published<[SavedItemResult]>.Publisher { get }
    var itemUpdated: AnyPublisher<SavedItem, Never> { get }
    var tagFilter: CurrentValueSubject<String, Never> { get }

    var filters: [ArchiveServiceFilter] { get set }
    var selectedSortOption: ArchiveSortOrder { get set }

    func fetch(at indexes: [Int]?)
    func refresh(completion: (() -> Void)?)

    func object(id: NSManagedObjectID) -> SavedItem?
    func index(of savedItem: SavedItem) -> Int?
}

public extension ArchiveService {
    func fetch() {
        fetch(at: nil)
    }
}

public enum ArchiveServiceFilter: Equatable {
    case favorites
    case tagged(NSPredicate, String)
}

public enum SavedItemResult: Equatable {
    case loaded(SavedItem)
    case notLoaded
}

public enum ArchiveSortOrder {
    case ascending
    case descending
}

class PocketArchiveService: NSObject, ArchiveService {
    @Published
    private var _results: [SavedItemResult]
    var results: Published<[SavedItemResult]>.Publisher { $_results }

    private let _itemUpdated: PassthroughSubject<SavedItem, Never> = .init()
    public var itemUpdated: AnyPublisher<SavedItem, Never> { _itemUpdated.eraseToAnyPublisher() }

    public var tagFilter: CurrentValueSubject<String, Never> = .init("")

    public var filters: [ArchiveServiceFilter] = [] {
        didSet {
            refresh()
        }
    }

    @MainActor
    private var isStoring = false

    @MainActor
    private var totalCount: Int = 0

    private let pageSize: Int
    private let space: Space
    private let apollo: ApolloClientProtocol
    private var archivedItemsController: NSFetchedResultsController<SavedItem>
    private let queue: OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        return q
    }()

    private var mergeCancellable: AnyCancellable?

    var selectedSortOption: ArchiveSortOrder = .descending

    public init(apollo: ApolloClientProtocol, space: Space, pageSize: Int = 100) {
        self.apollo = apollo
        self.pageSize = pageSize
        self.space = space

        archivedItemsController = space.makeArchivedItemsController()
        _results = []

        super.init()

        try? archivedItemsController.performFetch()
        archivedItemsController.delegate = self

        mergeCancellable = NotificationCenter
            .default
            .publisher(for: .NSManagedObjectContextDidMergeChangesObjectIDs, object: space.context)
            .sink { [weak self] notification in
                self?.archivedItemsController.delegate = self
            }
    }

    public func fetch(at indexes: [Int]? = nil) {
        fetch(at: indexes, firstPageReceived: nil)
    }

    private func fetch(at indexes: [Int]? = nil, firstPageReceived: (() -> Void)? = nil) {
        let isFavorite: Bool?
        if filters.contains(.favorites) {
            isFavorite = true
        } else {
            isFavorite = nil
        }

        let tagName: String?
        let containsTagged = filters.contains {
            guard case .tagged = $0 else { return false }
            return true
        }

        if containsTagged {
            tagName = tagFilter.value
        } else {
            tagName = nil
        }

        let operation = FetchArchivePagesOperation(
            apollo: apollo,
            pageSize: pageSize,
            indexes: indexes ?? [0],
            isFavorite: isFavorite,
            tagName: tagName,
            sortOrder: selectedSortOption,
            firstPageReceived: firstPageReceived
        )

        operation.delegate = self

        queue.addOperation(operation)
    }

    public func object(id: NSManagedObjectID) -> SavedItem? {
        archivedItemsController.managedObjectContext.object(with: id) as? SavedItem
    }

    public func refresh(completion: (() -> Void)? = nil) {
        Task { await _refresh(completion: completion) }
    }

    public func index(of savedItem: SavedItem) -> Int? {
        archivedItemsController.indexPath(forObject: savedItem)?.last
    }

    @MainActor
    private func _refresh(completion: (() -> Void)? = nil) {
        queue.cancelAllOperations()

        archivedItemsController = space.makeArchivedItemsController(
            filters: filters.map { filter -> NSPredicate in
                switch filter {
                case .favorites:
                    return NSPredicate(format: "isFavorite = 1")
                case .tagged(let predicate, let name):
                    tagFilter.value = name
                    return predicate
                }
            }
        )
        archivedItemsController.fetchRequest.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \SavedItem.archivedAt,
                ascending: (selectedSortOption == .ascending)
            )
        ]

        try? space.batchDeleteArchivedItems()
        totalCount = 0
        rebuildResults()

        fetch(firstPageReceived: completion)
    }

    @MainActor
    private func rebuildResults() {
        guard totalCount > 0 else {
            _results = []
            return
        }

        let fetchedObjects = archivedItemsController.fetchedObjects ?? []

        _results = (0..<totalCount).map { index in
            if index < fetchedObjects.count {
                return .loaded(fetchedObjects[index])
            } else {
                return .notLoaded
            }
        }
        tagFilter.send(tagFilter.value)
        tagFilter.value = ""
    }
}

extension PocketArchiveService: NSFetchedResultsControllerDelegate {
    @MainActor
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        guard !isStoring else { return }

        switch type {
        case .insert:
            totalCount += 1
            rebuildResults()
        case .delete:
            totalCount -= 1
            rebuildResults()
        case .update:
            guard let savedItem = anObject as? SavedItem else {
                break
            }

            _itemUpdated.send(savedItem)
        default:
            break
        }
    }
}

extension PocketArchiveService: FetchArchivePagesOperationDelegate {
    @MainActor
    func numberOfPagesToFetch(for indexes: [Int]) throws -> Int {
        let highestIndex = Double(indexes.max() ?? 0)
        let numberOfLocalItems = Double(archivedItemsController.fetchedObjects?.count ?? 0)
        let numberOfItemsToFetch = highestIndex + 1 - numberOfLocalItems
        let pagesToFetch = numberOfItemsToFetch / Double(pageSize)

        return Int(pagesToFetch.rounded(.up))
    }

    @MainActor
    func currentCursor() -> String? {
        return archivedItemsController.fetchedObjects?.last?.cursor
    }

    @MainActor
    func fetchArchivePagesOperationDidFetch(data: SavedItemSummariesQuery.Data?) throws {
        guard let savedItems = data?.user?.savedItems,
              let edges = savedItems.edges else {
            return
        }

        totalCount = savedItems.totalCount
        guard savedItems.totalCount > 0 else {
            return
        }

        for edge in edges {
            guard let edge = edge,
                  let summary = edge.node?.fragments.savedItemSummary else {
                continue
            }

            let savedItem = try space.fetchOrCreateSavedItem(byRemoteID: summary.remoteID)
            savedItem.cursor = edge.cursor
            savedItem.update(from: summary, with: space)

            if savedItem.deletedAt != nil {
                space.delete(savedItem)
            }
        }

        isStoring = true
        try space.save()
        isStoring = false

        try archivedItemsController.performFetch()
        rebuildResults()
    }
}

protocol FetchArchivePagesOperationDelegate: AnyObject {
    @MainActor
    func currentCursor() throws -> String?

    @MainActor
    func numberOfPagesToFetch(for indexes: [Int]) throws -> Int

    @MainActor
    func fetchArchivePagesOperationDidFetch(data: SavedItemSummariesQuery.Data?) throws
}

private class FetchArchivePagesOperation: AsyncOperation {
    weak var delegate: FetchArchivePagesOperationDelegate?

    private let apollo: ApolloClientProtocol
    private let pageSize: Int
    private let indexes: [Int]
    private let isFavorite: Bool?
    private let tagName: String?
    private let sortOrder: ArchiveSortOrder
    private var firstPageReceived: (() -> Void)?

    init(
        apollo: ApolloClientProtocol,
        pageSize: Int,
        indexes: [Int],
        isFavorite: Bool?,
        tagName: String?,
        sortOrder: ArchiveSortOrder,
        firstPageReceived: (() -> Void)?
    ) {
        self.apollo = apollo
        self.pageSize = pageSize
        self.indexes = indexes
        self.isFavorite = isFavorite
        self.tagName = tagName
        self.firstPageReceived = firstPageReceived
        self.sortOrder = sortOrder
        super.init()
    }

    override func start() {
        guard !isCancelled else {
            finishOperation()
            return
        }

        Task {
            await _start()
        }
    }

    private func _start() async {
        do {
            try await fetch()
        } catch {
            print(error)
        }

        finishOperation()
    }

    private func fetch() async throws {
        guard let delegate = delegate else { return }

        let pagesToFetch = try await delegate.numberOfPagesToFetch(for: indexes)
        guard !isCancelled, pagesToFetch > 0 else { return }

        for _ in (0..<pagesToFetch) {
            let cursor = try await delegate.currentCursor()
            guard !isCancelled else { return }

            let sortOrder: SavedItemsSortOrder
            switch self.sortOrder {
            case .descending:
                sortOrder = .desc
            case .ascending:
                sortOrder = .asc
            }

            var tagNames: [String] = []
            if let tagName = tagName {
                tagNames = tagName == "not tagged" ? ["_untagged_"] : [tagName]
            }
            let result = try await apollo.fetch(
                query: SavedItemSummariesQuery(
                    pagination: .some(PaginationInput(
                        after: cursor ?? .none,
                        first: .some(pageSize)
                    )),

                    filter: .some(SavedItemsFilter(isFavorite: isFavorite ?? .none, isArchived: true, tagNames: .some(tagNames))),
                    sort: .some(SavedItemsSort(sortBy: .init(.archivedAt), sortOrder: .init(sortOrder)))
                )
            )
            guard !isCancelled else { return }

            try await delegate.fetchArchivePagesOperationDidFetch(data: result.data)
            guard !isCancelled else { return }

            await invokeFirstPageReceived()
        }

    }

    @MainActor
    private func invokeFirstPageReceived() {
        firstPageReceived?()
        firstPageReceived = nil
    }
}
