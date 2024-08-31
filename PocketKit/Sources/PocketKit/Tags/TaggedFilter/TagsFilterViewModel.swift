// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Sync
import Analytics
import Foundation
import Textile
import SharedPocketKit

@MainActor
class TagsFilterViewModel: ObservableObject {
    /// Grab the latest tags from the database on each ask for them to ensure we are up to date
    private var fetchedTags: [Tag] {
        self.source.fetchAllTags() ?? []
    }
    private let tracker: Tracker
    private let source: Source
    private let userDefaults: UserDefaults
    private let user: User
    private let recentTagsFactory: RecentTagsProvider

    var selectAllAction: () -> Void?

    /// Fetches recent tags to display to the user only if premium and user has more than 3 tags
    var recentTags: [TagType] {
        guard user.status == .premium && fetchedTags.count > 3 else { return [] }
        return recentTagsFactory.recentTags.compactMap { TagType.recent($0) }.reversed()
    }

    @Published var selectedTag: TagType?
    @Published var presentExistingTagAlert: Bool = false

    init(source: Source, tracker: Tracker, userDefaults: UserDefaults, user: User, selectAllAction: @escaping () -> Void?) {
        self.source = source
        self.tracker = tracker
        self.selectAllAction = selectAllAction
        self.userDefaults = userDefaults
        self.user = user
        self.recentTagsFactory = RecentTagsProvider(userDefaults: userDefaults, key: UserDefaults.Key.recentTags)
        recentTagsFactory.getInitialRecentTags(with: self.fetchedTags.map({ $0.name }))
    }

    func trackEditAsOverflowAnalytics() {
        let event = SnowplowEngagement(type: .general, value: nil)
        let context = UIContext.button(identifier: .tagsOverflow)
        tracker.track(event: event, [context])
    }

    func selectTag(_ tag: TagType) {
        selectedTag = tag
        trackSelectedTag(with: tag)
    }

    func delete(tags: [String]) {
        trackTagsDelete(tags)
        tags.forEach { tag in
            guard let tag: Tag = fetchedTags.filter({ $0.name == tag }).first else { return }
            source.deleteTag(tag: tag)
        }
    }

    func rename(from oldName: String?, to newName: String) -> Bool {
        guard let oldName else {
            Log.capture(message: "Unable to rename tag due to oldName being nil")
            return false
        }
        let newName = newName.lowercased()

        // TODO: To be updated when working on https://getpocket.atlassian.net/browse/IN-1350
        guard let tag: Tag = fetchedTags.filter({ $0.name == oldName }).first,
              !fetchedTags.compactMap({ $0.name }).contains(newName) else {
            presentExistingTagAlert = true
            Log.capture(message: "Unable to rename tag due to name already existing")
            return false
        }
        source.renameTag(from: tag, to: newName)
        trackTagRename(from: oldName, to: newName)
        return true
    }
}

// MARK: Analytics
extension TagsFilterViewModel {
    func trackSelectedTag(with tagType: TagType) {
        switch tagType {
        case .notTagged:
            tracker.track(event: Events.Tags.selectNotTaggedToFilter())
        case .recent:
            tracker.track(event: Events.Tags.selectRecentTagToFilter(tagType.name))
        case .tag:
            tracker.track(event: Events.Tags.selectTagToFilter(tagType.name))
        }
    }

    func trackTagRename(from oldTag: String, to newTag: String) {
        tracker.track(event: Events.Tags.renameTag(from: oldTag, to: newTag))
    }

    func trackTagsDelete(_ tags: [String]) {
        tracker.track(event: Events.Tags.deleteTags(tags))
    }
}
