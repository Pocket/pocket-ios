// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import Sync
import Combine
import Analytics
import Localization
import WidgetKit

class SavedItemViewModel {
    private let appSession: AppSession
    private let saveService: SaveService
    private let dismissTimer: Timer.TimerPublisher
    private let tracker: Tracker
    private let consumerKey: String
    private let userDefaults: UserDefaults
    private let user: User

    private var dismissTimerCancellable: AnyCancellable?

    @Published var infoViewModel: InfoView.Model = .empty

    @Published var presentedAddTags: SaveToAddTagsViewModel?

    var savedItem: SavedItem?

    var tagsActionAttributedText: NSAttributedString {
        let tagCount = savedItem?.tags?.count ?? 0
        let hasTags = tagCount > 0
        return NSAttributedString(
            string: hasTags ? Localization.ItemAction.editTags : Localization.ItemAction.addTags,
            style: .buttonText
        )
    }

    let dismissAttributedText = NSAttributedString(
        string: Localization.SaveToPocket.tapToDismiss,
        style: .dismiss
    )

    init(appSession: AppSession,
         saveService: SaveService,
         dismissTimer: Timer.TimerPublisher,
         tracker: Tracker,
         consumerKey: String,
         userDefaults: UserDefaults,
         user: User
    ) {
        self.appSession = appSession
        self.saveService = saveService
        self.dismissTimer = dismissTimer
        self.tracker = tracker
        self.consumerKey = consumerKey
        self.userDefaults = userDefaults
        self.user = user

        guard appSession.currentSession != nil else { return }
    }

    func save(from context: ExtensionContext?) async {
        guard appSession.currentSession != nil else {
            autodismiss(from: context)

            return
        }

        guard let extensionItems = context?.extensionItems else {
            tracker.track(event: Events.SaveTo.unableToSave())
            autodismiss(from: context)

            return
        }

        guard let url = await parse(extensionItems: extensionItems) else {
            tracker.track(event: Events.SaveTo.unableToSave())
            infoViewModel = .error

            return
        }

        save(url)

        autodismiss(from: context)
    }

    private func parse(extensionItems: [ExtensionItem]) async -> String? {
        for item in extensionItems {
            guard let url = try? await url(from: item) else {
                continue
            }

            return url
        }

        return nil
    }

    private func save(_ url: String) {
        tracker.track(event: Events.SaveTo.saveEngagement(url: url))

        let result = saveService.save(url: url)
        switch result {
        case .existingItem(let savedItem):
            self.savedItem = savedItem
            infoViewModel = .existingItem
        case .newItem(let savedItem):
            self.savedItem = savedItem
            infoViewModel = .newItem
        default:
            break
        }
    }

    func showAddTagsView(from context: ExtensionContext?) {
        if let url = savedItem?.url {
            tracker.track(event: Events.SaveTo.addTagsEngagement(url: url))
        }

        presentedAddTags = SaveToAddTagsViewModel(
            item: savedItem,
            tracker: tracker,
            userDefaults: userDefaults,
            user: user,
            retrieveAction: { [weak self] tags in
                self?.retrieveTags(excluding: tags)
            },
            filterAction: { [weak self] text, tags in
                self?.filterTags(with: text, excluding: tags)
            },
            saveAction: { [weak self] tags in
                self?.addTags(tags: tags, from: context)
            }
        )
    }

    func addTags(tags: [String], from context: ExtensionContext?) {
        guard let savedItem = savedItem else { return }
        let result = saveService.addTags(savedItem: savedItem, tags: tags)
        if case let .taggedItem(savedItem) = result {
            self.savedItem = savedItem
            infoViewModel = .taggedItem
        }
        finish(context: context)
    }

    func retrieveTags(excluding tags: [String]) -> [Tag]? {
        return saveService.retrieveTags(excluding: tags)
    }

    func filterTags(with text: String, excluding tags: [String]) -> [Tag]? {
        return saveService.filterTags(with: text, excluding: tags)
    }

    func finish(context: ExtensionContext?, completionHandler: ((Bool) -> Void)? = nil) {
        context?.completeRequest(returningItems: nil, completionHandler: completionHandler)
    }

    func cancelDismissTimer() {
        dismissTimerCancellable?.cancel()
    }
}

extension SavedItemViewModel {
    private func autodismiss(from context: ExtensionContext?) {
        dismissTimerCancellable = dismissTimer.autoconnect().first().sink { [weak self] _ in
            self?.finish(context: context)
        }
    }

    private func url(from item: ExtensionItem) async throws -> String? {
        guard let providers = item.itemProviders else {
            return nil
        }

        for provider in providers {
            if let url = await URLExtractor.url(from: provider) {
                return URL(string: url)?.absoluteString
            }
        }

        return nil
    }
}

private extension InfoView.Model {
    static let empty = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(string: ""),
        attributedDetailText: NSAttributedString(string: "")
    )

    static let newItem = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(
            string: "Saved to Pocket",
            style: .mainText
        ),
        attributedDetailText: nil
    )

    static let existingItem = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(
            string: "Saved to Pocket",
            style: .mainText
        ),
        attributedDetailText: NSAttributedString(
            string: "You've already saved this. We'll move it to the top of your list.",
            style: .detailText
        )
    )

    static let error = InfoView.Model(
        style: .error,
        attributedText: NSAttributedString(
            string: "Pocket couldn't save this link",
            style: .mainTextError
        ),
        attributedDetailText: nil
    )

    static let taggedItem = InfoView.Model(
        style: .default,
        attributedText: NSAttributedString(
            string: "Tags Added!",
            style: .mainText
        ),
        attributedDetailText: nil
    )
}
