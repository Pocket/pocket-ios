// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SwiftUI
import Sync
import Textile
import Foundation
import Analytics
import SharedPocketKit

class SaveToAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem?
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let user: User
    private let recentTagsFactory: RecentTagsProvider
    private let retrieveAction: ([String]) -> [Tag]?
    private let filterAction: (String, [String]) -> [Tag]?
    private let saveAction: ([String]) -> Void
    private var userInputListener: AnyCancellable?
    var upsellView: AnyView { return AnyView(erasing: EmptyView()) }

    var recentTags: [TagType] {
        guard user.status == .premium && fetchAllTags.count > 3 else { return [] }
        return recentTagsFactory.recentTags.compactMap { TagType.recent($0) }.reversed()
    }

    /// Fetches all tags associated with item
    private var originalTagNames: [String]

    /// Fetches all tags associated with a user
    private var fetchAllTags: [Tag] {
        self.retrieveAction([]) ?? []
    }

    @Published var tags: [String] = []

    @Published var newTagInput: String = ""

    @Published var otherTags: [TagType] = []

    init(item: SavedItem?, tracker: Tracker, userDefaults: UserDefaults, user: User, retrieveAction: @escaping ([String]) -> [Tag]?, filterAction: @escaping (String, [String]) -> [Tag]?, saveAction: @escaping ([String]) -> Void) {
        self.item = item
        self.tracker = tracker
        self.retrieveAction = retrieveAction
        self.filterAction = filterAction
        self.saveAction = saveAction
        self.userDefaults = userDefaults
        self.user = user
        self.recentTagsFactory = RecentTagsProvider(userDefaults: userDefaults, key: UserDefaults.Key.recentTags)

        originalTagNames = item?.tags?.compactMap { ($0 as? Tag)?.name } ?? []
        tags = originalTagNames
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
        trackSaveTagsToItem()
        saveAction(tags)
        recentTagsFactory.updateRecentTags(with: originalTagNames, and: tags)
    }

    /// Fetch all tags associated with an item to show user
    func allOtherTags() {
        otherTags = retrieveAction(tags)?.map { .tag($0.name) }.sorted() ?? []
        trackAllTagsImpression()
    }

    /// Filter tags based on users input
    /// - Parameter text: new tag input entered in the text field
    private func filterTags(with text: String) {
        guard !text.isEmpty else {
            allOtherTags()
            return
        }
        let fetchedTags = filterAction(text.lowercased(), tags)?.compactMap { $0.name } ?? []
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
extension SaveToAddTagsViewModel {
    public func trackSaveTagsToItem() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.SaveTo.Tags.saveTags(itemUrl: url))
    }

    func trackAddTag(_ tag: String) {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.addTag")
            return
        }
        tracker.track(event: Events.SaveTo.Tags.addTag(tag, itemUrl: url))
    }

    func trackRemoveTag(_ tag: String) {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.remoteInputTag")
            return
        }
        tracker.track(event: Events.SaveTo.Tags.removeInputTag(tag, itemUrl: url))
    }

    func trackUserEnterText(with text: String) {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.SaveTo.Tags.userEntersText(itemUrl: url, text: text))
    }

    func trackAllTagsImpression() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.SaveTo.Tags.allTagsImpression(itemUrl: url))
    }

    func trackFilteredTagsImpression() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.SaveTo.Tags.filteredTagsImpression(itemUrl: url))
    }

    func trackExistingTagTapped(with tagType: TagType) {
        switch tagType {
        case .notTagged:
            return
        case .recent:
            tracker.track(event: Events.SaveTo.Tags.selectRecentTagToAddToItem(tagType.name))
        case .tag:
            tracker.track(event: Events.SaveTo.Tags.selectTagToAddToItem(tagType.name))
        }
    }
}
