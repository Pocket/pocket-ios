import Combine
import Sync
import Analytics
import Foundation
import Textile
import SharedPocketKit

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
        return recentTagsFactory.recentTags.sorted().compactMap { TagType.recent($0) }
    }

    @Published var selectedTag: TagType?
    @Published var refreshView: Bool? = false

    init(source: Source, tracker: Tracker, userDefaults: UserDefaults, user: User, selectAllAction: @escaping () -> Void?) {
        self.source = source
        self.tracker = tracker
        self.selectAllAction = selectAllAction
        self.userDefaults = userDefaults
        self.user = user
        self.recentTagsFactory = RecentTagsProvider(userDefaults: userDefaults, key: UserDefaults.Key.recentTags)
        recentTagsFactory.getInitialRecentTags(with: self.fetchedTags.map({ $0.name! }))
    }

    func trackEditAsOverflowAnalytics() {
        let event = SnowplowEngagement(type: .general, value: nil)
        let context = UIContext.button(identifier: .tagsOverflow)
        tracker.track(event: event, [context])
    }

    func selectTag(_ tag: TagType) {
        var tagContext = UIContext.button(identifier: .selectedTag)
        if case .notTagged = tag {
            tagContext = UIContext.button(identifier: .notTagged)
        }
        sendSelectedTagAnalytics(context: tagContext)
        selectedTag = tag
        trackRecentTagsTapped(with: tag)
    }

    private func sendSelectedTagAnalytics(context: Context) {
        let event = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: event, [context])
    }

    func delete(tags: [String]) {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: Context = UIContext.button(identifier: .tagsDelete)
        tracker.track(event: event, [contexts])
        tags.forEach { tag in
            guard let tag: Tag = fetchedTags.filter({ $0.name == tag }).first else { return }
            source.deleteTag(tag: tag)
        }
    }

    func rename(from oldName: String, to newName: String) {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: Context = UIContext.button(identifier: .tagsSaveChanges)
        tracker.track(event: event, [contexts])
        guard let tag: Tag = fetchedTags.filter({ $0.name == oldName }).first else { return }
        source.renameTag(from: tag, to: newName)
        refreshView = true
    }
}

// MARK: Analytics
extension TagsFilterViewModel {
    func trackRecentTagsTapped(with tag: TagType) {
        tracker.track(event: Events.Tags.filterTagsRecentTagTapped())
    }
}
