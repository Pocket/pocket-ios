import Foundation
import Apollo
import Sync


class PocketSaveService: SaveService {
    private let apollo: ApolloClientProtocol
    private let backgroundActivityPerformer: ExpiringActivityPerformer
    private let queue: OperationQueue
    private let space: Space

    init(
        apollo: ApolloClientProtocol,
        backgroundActivityPerformer: ExpiringActivityPerformer,
        space: Space
    ) {
        self.apollo = apollo
        self.backgroundActivityPerformer = backgroundActivityPerformer
        self.space = space

        self.queue = OperationQueue()
    }

    func save(url: URL) {
        backgroundActivityPerformer.performExpiringActivity(withReason: "com.mozilla.pocket.next.save") { [weak self] expiring in
            self?._save(expiring: expiring, url: url)
        }
    }

    private func _save(expiring: Bool, url: URL) {
        guard !expiring else {
            queue.cancelAllOperations()
            queue.waitUntilAllOperationsAreFinished()
            return
        }

        queue.addOperation(SaveOperation(apollo: apollo, space: space, url: url))
        queue.waitUntilAllOperationsAreFinished()
    }
}

class SaveOperation: AsyncOperation {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let url: URL

    private var task: Cancellable?
    private var savedItem: SavedItem?

    init(apollo: ApolloClientProtocol, space: Space, url: URL) {
        self.apollo = apollo
        self.space = space
        self.url = url
    }

    override func start() {
        guard !isCancelled else { return }

        storeLocalSkeletonItem()
        performMutation()
    }

    override func cancel() {
        task?.cancel()
        finishOperation()

        super.cancel()
    }

    private func storeLocalSkeletonItem() {
        savedItem = space.new()
        savedItem?.url = url
        try? space.save()
    }

    private func performMutation() {
        let mutation = SaveItemMutation(input: SavedItemUpsertInput(url: url.absoluteString))
        task = apollo.perform(mutation: mutation, publishResultToStore: false, queue: .main) { [weak self] result in
            self?.handle(result: result)
        }
    }

    private func handle(result: Result<GraphQLResult<SaveItemMutation.Data>, Error>) {
        guard case .success(let graphQLResult) = result,
              let savedItemParts = graphQLResult.data?.upsertSavedItem.fragments.savedItemParts else {
            finishOperation()
            return
        }

        savedItem?.update(from: savedItemParts)
        try? space.save()
        finishOperation()
    }
}
