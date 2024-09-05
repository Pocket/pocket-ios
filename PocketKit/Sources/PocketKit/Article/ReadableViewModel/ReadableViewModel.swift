// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics
import Localization
import SharedPocketKit

enum ItemSaveStatus {
    case unsaved
    case saved
    case archived
}

protocol ReadableViewModelDelegate: AnyObject {
    /// Called when a ReadableViewModel requests that Listen be presented with a given view model.
    /// - Parameters:
    ///   - readableViewModel: The view model requesting that Listen be presented.
    ///   - viewModel: The view model to use when presenting Listen.
    func viewModel(_ readableViewModel: ReadableViewModel, didRequestListen configuration: ListenConfiguration)
}

@MainActor
protocol ReadableViewModel: ReadableViewControllerDelegate {
    typealias EventPublisher = AnyPublisher<ReadableEvent, Never>

    var delegate: ReadableViewModelDelegate? { get set }

    var tracker: Tracker { get }

    var readableSource: ReadableSource { get }

    var readerSettings: ReaderSettings { get }
    var presentedAlert: PocketAlert? { get set }
    var sharedActivity: PocketActivity? { get set }
    var presentedWebReaderURL: URL? { get set }
    var isPresentingReaderSettings: Bool? { get set }

    var isListenSupported: Bool { get }
    var actions: Published<[ItemAction]>.Publisher { get }
    var events: EventPublisher { get }

    var components: [ArticleComponent]? { get }
    var textAlignment: TextAlignment { get }
    var title: String? { get }
    var authors: [ReadableAuthor]? { get }
    var domain: String? { get }
    var publishDate: Date? { get }
    var url: String { get }
    var shareUrl: String? { get }
    var itemSaveStatus: ItemSaveStatus { get }
    var premiumURL: String? { get }
    var shouldAllowHighlights: Bool { get }
    var shouldOpenListenOnAppear: Bool { get }

    func delete()
    /// Opens an item presented in the reader in a web view instead
    /// - Parameters:
    ///     - url: The URL of the item to open in a web view
    /// - Note: A typical callee of this function will be the handler for when the Safari icon in the navigation bar is tapped
    func openInWebView(url: String)
    /// Opens a link that was tapped within an item opened in the reader
    /// - Parameters:
    ///     - url: The URL of the link that was tapped within the reader
    /// - Note: A typical callee of this function will be the handler for when a link in the reader is tapped,
    /// or when a link is long-pressed, and "Open" is selected beneath the preview
    func openExternalLink(url: URL)
    func archive()
    func moveFromArchiveToSaves(completion: (Bool) -> Void)
    func save(completion: (Bool) -> Void)
    func fetchDetailsIfNeeded()
    func externalActions(for url: URL) -> [ItemAction]
    func clearPresentedWebReaderURL()
    func unfavorite()
    func favorite()
    func beginBulkEdit()
    func trackReadingProgress(index: IndexPath)
    func readingProgress() -> IndexPath?
    func listen()
}

// MARK: - ReadableViewControllerDelegate

extension ReadableViewModel {
    func readableViewController(_ controller: ReadableViewController, openURL url: URL) {
        openExternalLink(url: url)
    }

    func readableViewController(_ controller: ReadableViewController, shareWithAdditionalText text: String?) {
        share(additionalText: text)
    }
}

// MARK: - Shared Actions

extension ReadableViewModel {
    func displaySettings() {
        trackDisplaySettings()
        isPresentingReaderSettings = true
    }

    func showWebReader() {
        openInWebView(url: url)
    }

    func share(additionalText: String? = nil) {
        trackShare()
        // Instances conforming to this view model are used within the context
        // of an item presented within the reader
        sharedActivity = PocketItemActivity.fromReader(url: shareUrl ?? url, additionalText: additionalText)
    }

    func confirmDelete() {
        trackDelete()
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
        presentedAlert = nil
        delete()
    }

    func webViewActivityItems(for item: CDSavedItem) -> [UIActivity] {
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
        tracker.track(event: Events.Reader.unsupportedContentViewed(url: url))
    }

    /// track when user taps on button to open unsupported content in web view
    func trackUnsupportedContentButtonTapped() {
        tracker.track(event: Events.Reader.unsupportedContentButtonTapped(url: url))
    }

    /// track archive button tapped in reader toolbar
    /// - Parameter url: url of saved item
    func trackArchiveButtonTapped(url: String) {
        tracker.track(event: Events.ReaderToolbar.archiveClicked(url: url))
    }

    /// track move to saves from archive button tapped in reader toolbar
    /// - Parameter url: url of saved item
    func trackMoveFromArchiveToSavesButtonTapped(url: String) {
        tracker.track(event: Events.ReaderToolbar.moveFromArchiveToSavesClicked(url: url))
    }

    /// track overflow menu tapped in reader toolbar
    func trackOverflow() {
        tracker.track(event: Events.ReaderToolbar.overflowClicked(url: url))
    }

    /// track display settings in reader toolbar overflow menu
    func trackDisplaySettings() {
        tracker.track(event: Events.ReaderToolbar.textSettingsClicked(url: url))
    }

    /// track favorite button tapped in reader toolbar overflow menu
    /// - Parameter url: url of saved item
    func trackFavorite(url: String) {
        tracker.track(event: Events.ReaderToolbar.favoriteClicked(url: url))
    }

    /// track unfavorite button tapped in reader toolbar overflow menu
    /// - Parameter url: url of saved item
    func trackUnfavorite(url: String) {
        tracker.track(event: Events.ReaderToolbar.unfavoriteClicked(url: url))
    }

    /// track add tags button tapped in reader toolbar overflow menu
    /// - Parameter url: url of saved item
    func trackAddTags(url: String) {
        tracker.track(event: Events.ReaderToolbar.addTagsClicked(url: url))
    }

    /// track delete button tapped in reader toolbar overflow menu
    func trackDelete() {
        tracker.track(event: Events.ReaderToolbar.deleteClicked(url: url))
    }

    /// track share button tapped in reader toolbar overflow menu
    func trackShare() {
        tracker.track(event: Events.ReaderToolbar.shareClicked(url: shareUrl ?? url))
    }

    /// track save button tapped in reader toolbar overflow menu
    func trackSave() {
        tracker.track(event: Events.ReaderToolbar.saveClicked(url: url))
    }

    /// track report button tapped in reader toolbar overflow menu
    func trackReport() {
        tracker.track(event: Events.ReaderToolbar.reportClicked(url: url))
    }

    /// track when user taps on the safari button to open content in web view
    func trackWebViewOpen() {
        tracker.track(event: Events.ReaderToolbar.openInWebView(url: url))
    }

    func trackExternalLinkOpen(url: String) {
        tracker.track(event: Events.Reader.openExternalLink(url: url))
    }
}
