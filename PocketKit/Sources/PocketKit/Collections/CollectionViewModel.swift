// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit
import SharedPocketKit
import Combine

// View model that holds logic for the native collection view
class CollectionViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot

    @Published private(set) var _events: ReadableEvent?
    var events: Published<ReadableEvent?>.Publisher { $_events }

    @Published private(set) var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    private let slug: String
    private let source: Source
    private var collection: CollectionModel?
    private var url: String

    private var collectionItemSubscriptions: Set<AnyCancellable> = []

    init(slug: String, source: Source) {
        self.slug = slug
        self.source = source
        self.snapshot = Self.loadingSnapshot()
        url = "https://getpocket.com/collections/\(slug)"

        item?.savedItem?.publisher(for: \.isFavorite).sink { [weak self] _ in
            self?.buildActions()
        }.store(in: &collectionItemSubscriptions)
    }

    var title: String {
        collection?.title ?? ""
    }

    var authors: [String] {
        collection?.authors ?? []
    }

    var storiesCount: Int? {
        collection?.stories.count
    }

    var intro: Markdown? {
        collection?.intro
    }

    var item: Item? {
        return source.fetchItem(url)
    }

    var isArchived: Bool? {
        guard let item else { return nil }
        return item.savedItem?.isArchived
    }

    func fetch() {
        Task {
            do {
                self.collection = try await source.fetchCollection(by: slug)
                let snapshot = buildSnapshot()
                guard snapshot.numberOfItems != 0 else { return }
                self.snapshot = snapshot
            } catch {
                Log.capture(message: "Failed to fetch details for CollectionViewModel: \(error)")
            }
        }
    }

    func archive() {
        guard let savedItem = item?.savedItem else {
            Log.capture(message: "Failed to archive item due to savedItem being nil")
            return
        }

        source.archive(item: savedItem)
        _events = .archive
    }

    // If savedItem exists, then unarchive the item to appear in Saves, otherwise save the item
    func moveToSaves(completion: (Bool) -> Void) {
        guard let savedItem = item?.savedItem else {
            source.save(url: url)
            completion(true)
            return
        }
        source.unarchive(item: savedItem)
        completion(true)
    }

    // TODO: Update actions for Collections
    private func buildActions() {
        guard let savedItem = item?.savedItem else {
            _actions = []
            return
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { _ in }
        } else {
            favoriteAction = .favorite { _ in }
        }

        _actions = [
            favoriteAction,
            tagsAction(for: savedItem),
            .delete { _ in },
            .share { _ in }
        ]
    }

    private func tagsAction(for item: SavedItem) -> ItemAction {
        let hasTags = (item.tags?.count ?? 0) > 0
        if hasTags {
            return .editTags { _ in }
        } else {
            return .addTags { _ in }
        }
    }
}

// MARK: - Cell Selection
extension CollectionViewModel {
    func select(cell: CollectionViewModel.Cell, at indexPath: IndexPath) {
        switch cell {
        case .loading:
            return
        case .collectionHeader:
            return
        case .stories:
            return
        }
    }
}

private extension CollectionViewModel {
    static func loadingSnapshot() -> Snapshot {
        var snapshot = Snapshot()
        snapshot.appendSections([.loading])
        snapshot.appendItems([.loading], toSection: .loading)
        return snapshot
    }

    func buildSnapshot() -> Snapshot {
        var snapshot = Snapshot()

        guard let collection else { return snapshot }

        let section: CollectionViewModel.Section = .collection(collection)
        snapshot.appendSections([.collectionHeader, section])
        snapshot.appendItems([.collectionHeader], toSection: .collectionHeader)

        collection.stories.forEach { story in
            let storyViewModel = CollectionStoryViewModel(story: story)
            snapshot.appendItems(
                [.stories(storyViewModel)],
                toSection: section
            )
        }

        return snapshot
    }
}

extension CollectionViewModel {
    enum Section: Hashable {
        case loading
        case collectionHeader
        case collection(CollectionModel)
    }

    enum Cell: Hashable {
        case loading
        case collectionHeader
        case stories(CollectionStoryViewModel)
    }
}
