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
    var currentActions: [ItemAction] {
        _actions
    }

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

    private var item: ArchivedItem
    private let source: Source
    let tracker: Tracker

    init(item: ArchivedItem, source: Source, tracker: Tracker) {
        self.item = item
        self.source = source
        self.tracker = tracker

        buildActions()
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
        Task { await _delete() }
    }

    func _delete() async {
        do {
            try await source.delete(item: item)
            _events.send(.delete)
        } catch {
            presentedAlert = PocketAlert(error) { [weak self] in
                self?.presentedAlert = nil
            }
        }
    }

    func showWebReader() {
        presentedWebReaderURL = url
    }
}

extension ArchivedItemViewModel {
    private func buildActions() {
        let favoriteAction: ItemAction
        if item.isFavorite {
            favoriteAction = .unfavorite {[weak self] _ in self?.unfavorite() }
        } else {
            favoriteAction = .favorite { [weak self] _ in self?.favorite() }
        }

        _actions = [
            .displaySettings { [weak self] _ in self?.displaySettings() }
        ] + [
            favoriteAction
        ] + [
            .reAdd { [weak self] _ in self?.reAdd() },
            .delete { [weak self] _ in self?.confirmDelete() },
            .share { [weak self] _ in self?.share() },
        ]
    }

    private func reAdd() {
        Task { await _reAdd() }
        track(identifier: .itemSave) // TODO: Identifier
    }

    private func _reAdd() async {
        do {
            try await source.reAdd(item: item)
            await source.refresh()
        } catch {
            presentedAlert = PocketAlert(error) { [weak self] in
                self?.presentedAlert = nil
            }
        }
    }
    
    private func favorite() {
        Task { await _favorite() }
    }

    private func _favorite() async {
        item = item.with(isFavorite: true)
        buildActions()
        track(identifier: .itemFavorite)

        do {
            try await source.favorite(item: item)
        } catch {
            presentedAlert = PocketAlert(error) { [weak self] in
                self?.presentedAlert = nil
            }

            item = item.with(isFavorite: false)
            buildActions()
        }
    }

    private func unfavorite() {
        Task { await _unfavorite() }
    }

    private func _unfavorite() async {
        item = item.with(isFavorite: false)
        buildActions()
        track(identifier: .itemUnfavorite)

        do {
            try await source.unfavorite(item: item)
        } catch {
            presentedAlert = PocketAlert(error) { [weak self] in
                self?.presentedAlert = nil
            }

            item = item.with(isFavorite: true)
            buildActions()
        }
    }
}
