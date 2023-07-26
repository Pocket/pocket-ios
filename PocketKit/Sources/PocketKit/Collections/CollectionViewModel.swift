// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import UIKit
import SharedPocketKit
import Combine
import Localization

// View model that holds logic for the native collection view
class CollectionViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot
    @Published var presentedAlert: PocketAlert?

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

    private func buildActions() {
        guard let savedItem = item?.savedItem else {
            // TODO: Handle actions for when collection is not saved
            _actions = []
            return
        }

        let favoriteAction: ItemAction
        if savedItem.isFavorite {
            favoriteAction = .unfavorite { [weak self] _ in self?.unfavorite(savedItem) }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite(savedItem) }
        }

        _actions = [
            favoriteAction,
            tagsAction(for: savedItem),
            .delete { [weak self] _ in self?.confirmDelete(for: savedItem) },
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

    private func favorite(_ savedItem: SavedItem) {
        source.favorite(item: savedItem)
    }

    private func unfavorite(_ savedItem: SavedItem) {
        source.unfavorite(item: savedItem)
    }

    private func confirmDelete(for savedItem: SavedItem) {
        presentedAlert = PocketAlert(
            title: Localization.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: Localization.yes, style: .destructive) { [weak self] _ in self?.delete(savedItem) },
            ],
            preferredAction: nil
        )
    }

    private func delete(_ savedItem: SavedItem) {
        presentedAlert = nil
        source.delete(item: savedItem)
        _events = .delete
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
