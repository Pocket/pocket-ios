// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SwiftUI
import Sync
import SharedPocketKit
import Textile
import Foundation
import Analytics

@MainActor
class PocketAddTagsViewModel: AddTagsViewModel {
    private let item: CDSavedItem
    private let source: Source
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let recentTagsFactory: RecentTagsProvider
    private let store: SubscriptionStore
    private let saveAction: () -> Void
    private var userInputListener: AnyCancellable?
    private var user: User
    private var networkPathMonitor: NetworkPathMonitor
    private var premiumUpsellView: PremiumUpsellView
    private var premiumUpsellViewModel: PremiumUpsellViewModel
    private var premiumUpgradeViewModel: PremiumUpgradeViewModel
    var upsellView: AnyView {
        if user.status == .free {
            return AnyView(erasing: premiumUpsellView)
        } else {
            return AnyView(erasing: EmptyView())
        }
    }

    /// Fetches recent tags to display to the user only if premium and user has more than 3 tags
    var recentTags: [TagType] {
        guard user.status == .premium && fetchAllTags.count > 3 else { return [] }
        return recentTagsFactory.recentTags.compactMap { TagType.recent($0) }.reversed()
    }

    /// Fetches all tags associated with item
    private var itemTagNames: [String] {
        item.tags?.compactMap { ($0 as? CDTag)?.name }.sorted() ?? []
    }

    /// Fetches all tags associated with a user
    private var fetchAllTags: [CDTag] {
        self.source.fetchAllTags() ?? []
    }

    @Published var tags: [String] = []

    @Published var newTagInput: String = ""

    @Published var otherTags: [TagType] = []

    init(item: CDSavedItem, source: Source, tracker: Tracker, userDefaults: UserDefaults, user: User, store: SubscriptionStore, networkPathMonitor: NetworkPathMonitor, saveAction: @escaping () -> Void) {
        self.item = item
        self.source = source
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.recentTagsFactory = RecentTagsProvider(userDefaults: userDefaults, key: UserDefaults.Key.recentTags)
        self.store = store
        self.saveAction = saveAction
        self.user = user
        self.networkPathMonitor = networkPathMonitor

        self.premiumUpgradeViewModel = PremiumUpgradeViewModel(
            store: store,
            tracker: tracker,
            source: .tags,
            networkPathMonitor: self.networkPathMonitor
        )

        self.premiumUpsellViewModel = PremiumUpsellViewModel(networkPathMonitor: networkPathMonitor, user: user, source: source, tracker: tracker, premiumUpgradeViewModelFactory: { PremiumUpgradeSource in
            PremiumUpgradeViewModel(store: store, tracker: tracker, source: .tags, networkPathMonitor: networkPathMonitor)
        })

        self.premiumUpsellView = PremiumUpsellView(viewModel: premiumUpsellViewModel, itemURL: item.url)

        tags = itemTagNames
        allOtherTags()

        userInputListener = $newTagInput
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                self?.trackUserEnterText(with: text)
                self?.filterTags(with: text)
            })

        recentTagsFactory.getInitialRecentTags(with: fetchAllTags.compactMap({ $0.name }))
    }

    /// Saves tags to an item
    func saveTags() {
        addNewTag(with: newTagInput)
        trackSaveTagsToItem()
        source.replaceTags(item, tags: tags)
        saveAction()
        recentTagsFactory.updateRecentTags(with: itemTagNames, and: tags)
    }

    /// Fetch all tags associated with an item to show user
    func allOtherTags() {
        // TODO: Remove ! when we have non-null on tagName
        otherTags = source.retrieveTags(excluding: tags)?.compactMap({ .tag($0.name) }).sorted() ?? []
        trackAllTagsImpression()
    }

    /// Filter tags based on users input
    /// - Parameter text: new tag input entered in the text field
    private func filterTags(with text: String) {
        guard !text.isEmpty else {
            allOtherTags()
            return
        }
        let fetchedTags = source.filterTags(with: text.lowercased(), excluding: tags)?.compactMap { $0.name }.sorted() ?? []
        let tagTypes = fetchedTags.compactMap { TagType.tag($0) }
        if !tagTypes.isEmpty {
            otherTags = tagTypes
            trackFilteredTagsImpression()
        } else {
            allOtherTags()
        }
    }
}

// MARK: Analytics
extension PocketAddTagsViewModel {
    public func trackSaveTagsToItem() {
        tracker.track(event: Events.Tags.saveTags(itemUrl: item.url))
    }

    func trackAddTag(_ tag: String) {
        tracker.track(event: Events.Tags.addTag(tag, itemUrl: item.url))
    }

    func trackRemoveTag(_ tag: String) {
        tracker.track(event: Events.Tags.removeInputTag(tag, itemUrl: item.url))
    }

    func trackUserEnterText(with text: String) {
        tracker.track(event: Events.Tags.userEntersText(itemUrl: item.url, text: text))
    }

    func trackAllTagsImpression() {
        tracker.track(event: Events.Tags.allTagsImpression(itemUrl: item.url))
    }

    func trackFilteredTagsImpression() {
        tracker.track(event: Events.Tags.filteredTagsImpression(itemUrl: item.url))
    }

    func trackExistingTagTapped(with tagType: TagType) {
        switch tagType {
        case .notTagged:
            return
        case .recent:
            tracker.track(event: Events.Tags.selectRecentTagToAddToItem(tagType.name))
        case .tag:
            tracker.track(event: Events.Tags.selectTagToAddToItem(tagType.name))
        }
    }
}
