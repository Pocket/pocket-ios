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
    func showWebReader()
}

// MARK: - ReadableViewControllerDelegate

extension ReadableViewModel {
    func readableViewController(_ controller: ReadableViewController, openURL url: URL) {
        open(url: url)
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
    
    func open(url: URL) {
        trackOpen(url: url)
        presentedWebReaderURL = url
    }

    private func trackOpen(url: URL) {
        let additionalContexts: [Context] = [ContentContext(url: url)]

        let contentOpen = ContentOpenEvent(destination: .external, trigger: .click)
        let link = UIContext.articleView.link
        let contexts = additionalContexts + [link]
        tracker.track(event: contentOpen, contexts)
    }
    
    func share(additionalText: String? = nil) {
        track(identifier: .itemShare)
        sharedActivity = PocketItemActivity(url: url, additionalText: additionalText)
    }
    
    func confirmDelete() {
        presentedAlert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: [
                UIAlertAction(title: "No", style: .default) { [weak self] _ in
                    self?.presentedAlert = nil
                },
                UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in self?._delete() },
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
}
