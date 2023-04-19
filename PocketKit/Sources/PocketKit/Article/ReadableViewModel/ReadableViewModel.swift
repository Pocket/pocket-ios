import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics
import Localization
import SharedPocketKit

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
    var isArchived: Bool { get }
    var premiumURL: URL? { get }

    func delete()
    func openExternally(url: URL?)
    func archive()
    func moveFromArchiveToSaves(completion: (Bool) -> Void)
    func fetchDetailsIfNeeded()
    func externalActions(for url: URL) -> [ItemAction]
    func clearPresentedWebReaderURL()
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
        track(identifier: .switchToWebView)
        isPresentingReaderSettings = true
    }

    func showWebReader() {
        openExternally(url: url)
    }

    func share(additionalText: String? = nil) {
        track(identifier: .itemShare)
        // Instances conforming to this view model are used within the context
        // of an item presented within the reader
        sharedActivity = PocketItemActivity.fromReader(url: url, additionalText: additionalText)
    }

    func confirmDelete() {
        presentedAlert = PocketAlert(
            title: Localization.areYouSureYouWantToDeleteThisItem,
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: Localization.no, style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: Localization.yes, style: .destructive) { [weak self] _ in self?._delete() },
            ],
            preferredAction: nil
        )
    }

    private func _delete() {
        track(identifier: .itemDelete)
        presentedAlert = nil
        delete()
    }

    func track(identifier: UIContext.Identifier) {
        guard let url = url else {
            return
        }

        let contexts: [Context] = [
            UIContext.button(identifier: identifier),
            ContentContext(url: url)
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
                self?.moveFromArchiveToSaves { _ in }
            } else {
                self?.archive()
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

// MARK: - Analytics
extension ReadableViewModel {
    /// track when user views unsupported content cell
    func trackUnsupportedContentViewed() {
        guard let url else {
            Log.capture(message: "Reader item without an associated url, not logging analytics for unsupportedContentViewed")
            return
        }
        tracker.track(event: Events.Reader.unsupportedContentViewed(url: url))
    }

    /// track when user taps on button to open unsupported content in web view
    func trackUnsupportedContentButtonTapped() {
        guard let url else {
            Log.capture(message: "Reader item without an associated url, not logging analytics for unsupportedContentButtonTapped")
            return
        }
        tracker.track(event: Events.Reader.unsupportedContentButtonTapped(url: url))
    }

    /// track archive button tapped in reader toolbar
    /// - Parameter url: url of saved item
    func trackArchiveButtonTapped(url: URL) {
        tracker.track(event: Events.Reader.archiveClicked(url: url))
    }

    /// track move to saves from archive button tapped in reader toolbar
    /// - Parameter url: url of saved item
    func trackMoveFromArchiveToSavesButtonTapped(url: URL) {
        tracker.track(event: Events.Reader.moveFromArchiveToSavesClicked(url: url))
    }

    /// track when user taps on the safari button to open content in web view
    func trackWebViewOpen() {
        guard let url else {
            Log.capture(message: "Reader item without an associated url, not logging analytics for openInWebView")
            return
        }
        tracker.track(event: Events.Reader.openInWebView(url: url))
    }
}
