import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics

protocol ReadableViewModel: ReadableViewControllerDelegate {
    typealias EventPublisher = AnyPublisher<ReadableEvent, Never>

    var tracker: Tracker { get }

    var readerSettings: ReaderSettings { get }
    var presentedAlert: PocketAlert? { get set }
    var sharedActivity: PocketActivity? { get set }
    var presentedWebReaderURL: URL? { get set }
    var isPresentingReaderSettings: Bool? { get set }

    var actions: Published<[ItemAction]>.Publisher { get }
    var events: EventPublisher { get }

    var components: [ArticleComponent]? { get }
    var textAlignment: TextAlignment { get }
    var title: String? { get }
    var authors: [ReadableAuthor]? { get }
    var domain: String? { get }
    var publishDate: Date? { get }
    var url: URL? { get }

    func delete()
    func openExternally(url: URL?)
    func archiveArticle()
    func fetchDetailsIfNeeded()
    func externalActions(for url: URL) -> [ItemAction]
    func clearPresentedWebReaderURL()
    func moveToSaves()
    func unfavorite()
    func favorite()
}

// MARK: - ReadableViewControllerDelegate

extension ReadableViewModel {
    func readableViewController(_ controller: ReadableViewController, openURL url: URL) {
        openExternally(url: url)
    }

    func readableViewController(_ controller: ReadableViewController, shareWithAdditionalText text: String?) {
        share(additionalText: text)
    }
}

// MARK: - Shared Actions

extension ReadableViewModel {
    func displaySettings() {
        if let url = url {
            tracker.track(event: Events.Reader.ArticleViewOriginal(url: url))
        }
        isPresentingReaderSettings = true
    }

    func openExternally(url: URL?) {
        presentedWebReaderURL = url

        if let url = url {
            trackOpen(url: url)
        }
    }

    func showWebReader() {
        openExternally(url: url)
    }

    private func trackOpen(url: URL) {
        let additionalContexts: [OldEntity] = [ContentEntity(url: url)]

        let contentOpen = OldContentOpenEvent(destination: .external, trigger: .click)
        let link = OldUIEntity.articleView.link
        let contexts = additionalContexts + [link]
        tracker.track(event: contentOpen, contexts)
    }

    func share(additionalText: String? = nil) {
        if let url = url {
            tracker.track(event: Events.Reader.ArticleShare(url: url))
        }
        sharedActivity = PocketItemActivity(url: url, additionalText: additionalText)
    }

    func confirmDelete() {
        presentedAlert = PocketAlert(
            title: L10n.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: L10n.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: L10n.yes, style: .destructive) { [weak self] _ in self?._delete() },
            ],
            preferredAction: nil
        )
    }

    private func _delete() {
        if let url = url {
            tracker.track(event: Events.Reader.ArticleDelete(url: url))
        }
        presentedAlert = nil
        delete()
    }

    func track(identifier: OldUIEntity.Identifier) {
        guard let url = url else {
            return
        }

        let contexts: [OldEntity] = [
            OldUIEntity.button(identifier: identifier),
            ContentEntity(url: url)
        ]

        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, contexts)
    }

    func webViewActivityItems(for item: SavedItem) -> [UIActivity] {
        let archiveActivityTitle: WebActivityTitle = (item.isArchived
                                                      ? .moveToSaves
                                                       : .archive)
        let archiveActivity = ReaderActionsWebActivity(title: archiveActivityTitle) { [weak self] in
            if item.isArchived == true {
                self?.moveToSaves()
            } else {
                self?.archiveArticle()
            }
        }

        let deleteActivity = ReaderActionsWebActivity(title: .delete) { [weak self] in
            self?.confirmDelete()
        }

        let favoriteActivityTitle: WebActivityTitle = (item.isFavorite
                                                        ? .unfavorite
                                                        : .favorite
        )

        let favoriteActivity = ReaderActionsWebActivity(title: favoriteActivityTitle) { [weak self] in
            if item.isFavorite == true {
                self?.unfavorite()
            } else {
                self?.favorite()
            }
        }

        return [archiveActivity, deleteActivity, favoriteActivity]
    }
}
