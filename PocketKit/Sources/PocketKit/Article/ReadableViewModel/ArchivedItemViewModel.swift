import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics


class ArchivedItemViewModel: ReadableViewModel {
    @Published
    private var _actions: [ItemAction] = []
    var actions: Published<[ItemAction]>.Publisher { $_actions }

    @Published
    var presentedAlert: PocketAlert?

    @Published
    var sharedActivity: PocketActivity?

    @Published
    var presentedWebReaderURL: URL?

    @Published
    var isPresentingReaderSettings: Bool?

    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher {
        _events.eraseToAnyPublisher()
    }

    private let item: ArchivedItem
    let tracker: Tracker

    init(item: ArchivedItem, tracker: Tracker) {
        self.item = item
        self.tracker = tracker

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() },
            .save { [weak self] _ in self?.save() },
            .favorite { [weak self] _ in self?.favorite() },
            .delete { [weak self] _ in self?.confirmDelete() },
            .share { [weak self] _ in self?.share() },
        ]
    }

    var readerSettings: ReaderSettings {
        // TODO: inject this
        ReaderSettings()
    }

    var components: [ArticleComponent]? {
        item.item?.article?.components
    }

    var textAlignment: Textile.TextAlignment {
        TextAlignment(language: item.item?.language)
    }

    var title: String? {
        item.item?.title
    }

    var authors: [ReadableAuthor]? {
        item.item?.authors
    }

    var domain: String? {
        item.item?.domainMetadata?.name ?? item.item?.domain
    }

    var publishDate: Date? {
        item.item?.datePublished
    }

    var url: URL? {
        item.bestURL
    }
    
    func delete() {
        // TODO: Delete archived item
        _events.send(.delete)
    }

    func showWebReader() {
        presentedWebReaderURL = url
    }
}

extension ArchivedItemViewModel {
    private func save() {
        track(identifier: .itemSave)
    }
    
    private func favorite() {
        track(identifier: .itemFavorite)
    }
}
