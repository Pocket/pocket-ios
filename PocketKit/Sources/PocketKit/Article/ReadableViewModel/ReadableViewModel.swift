import Combine
import Sync
import Foundation
import Textile
import UIKit
import Analytics


protocol ReadableViewModel: ReadableViewControllerDelegate {
    typealias EventPublisher = AnyPublisher<ReadableEvent, Never>
    
    var mainViewModel: MainViewModel { get }
    var tracker: Tracker { get }
    
    var actions: Published<[ReadableAction]>.Publisher { get }
    var events: EventPublisher { get }
    
    var components: [ArticleComponent]? { get }
    var textAlignment: TextAlignment { get }
    var title: String? { get }
    var authors: [ReadableAuthor]? { get }
    var domain: String? { get }
    var publishDate: Date? { get }
    var url: URL? { get }
    
    func delete()
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
        mainViewModel.isPresentingReaderSettings = true
    }
    
    func open(url: URL) {
        mainViewModel.presentedWebReaderURL = url
        
        let additionalContexts: [Context] = [ContentContext(url: url)]

        let contentOpen = ContentOpenEvent(destination: .external, trigger: .click)
        let link = UIContext.articleView.link
        let contexts = additionalContexts + [link]
        tracker.track(event: contentOpen, contexts)
    }
    
    func share(additionalText: String? = nil) {
        guard let url = url else {
            return
        }
        
        mainViewModel.sharedActivity = PocketItemActivity(url: url, additionalText: additionalText)
        
        track(identifier: .itemShare)
    }
    
    func confirmDelete() {
        let actions = [
            UIAlertAction(title: "No", style: .default) { [weak self] _ in
                self?.mainViewModel.presentedAlert = nil
            },
            UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
                self?.mainViewModel.presentedAlert = nil

                guard let self = self else {
                    return
                }
                
                self.delete()
            }
        ]

        let alert = PocketAlert(
            title: "Are you sure you want to delete this item?",
            message: nil,
            preferredStyle: .alert,
            actions: actions,
            preferredAction: nil
        )
        mainViewModel.presentedAlert = alert

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
