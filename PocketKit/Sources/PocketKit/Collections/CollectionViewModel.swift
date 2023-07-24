// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import UIKit
import SharedPocketKit

// View model that holds logic for the native collection view
class CollectionViewModel {
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Cell>

    @Published var snapshot: Snapshot

    private let slug: String
    private let source: Source
    private var collection: CollectionModel?

    init(slug: String, source: Source) {
        self.slug = slug
        self.source = source
        self.snapshot = Self.loadingSnapshot()
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
