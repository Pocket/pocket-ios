import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics


class ArchivedItemViewModel: ReadableViewModel {
    @Published
    private var _actions: [ReadableAction] = []
    var actions: Published<[ReadableAction]>.Publisher { $_actions }
    
    private var _events = PassthroughSubject<ReadableEvent, Never>()
    var events: EventPublisher {
        _events.eraseToAnyPublisher()
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
        item.item?.resolvedURL ?? item.item?.givenURL ?? item.url
    }

    private let item: ArchivedItem
    let mainViewModel: MainViewModel
    let tracker: Tracker

    init(item: ArchivedItem, mainViewModel: MainViewModel, tracker: Tracker) {
        self.item = item
        self.mainViewModel = mainViewModel
        self.tracker = tracker

        _actions = [
            .displaySettings { [weak self] in self?.displaySettings() },
            .save { [weak self] in self?.save() },
            .favorite { [weak self] in self?.favorite() },
            .delete { [weak self] in self?.confirmDelete() },
            .share { [weak self] in self?.share() },
        ]
    }
    
    func delete() {
        // TODO: Delete archived item
        _events.send(.delete)
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
