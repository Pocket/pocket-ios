import Combine
import Sync
import Analytics
import Foundation
import Textile

class TagsFilterViewModel: ObservableObject {
    private var fetchedTags: [Tag]?
    private let tracker: Tracker
    private let source: Source
    var selectAllAction: () -> Void?

    @Published
    var selectedTag: TagType?

    @Published
    var refreshView: Bool? = false

    init(source: Source, tracker: Tracker, fetchedTags: [Tag]?, selectAllAction: @escaping () -> Void?) {
        self.source = source
        self.tracker = tracker
        self.fetchedTags = fetchedTags
        self.selectAllAction = selectAllAction
    }

    func getAllTags() -> [TagType] {
        var allTags: [String] = []
        guard let fetchedTags = fetchedTags?.compactMap({ $0.name }).reversed() else { return [] }

        if fetchedTags.count > 3 {
            let topRecentTags = Array(fetchedTags)[..<3]
            let sortedTags = Array(fetchedTags)[3...].sorted()
            allTags.append(contentsOf: topRecentTags)
            allTags.append(contentsOf: sortedTags)
        } else {
            allTags.append(contentsOf: fetchedTags)
        }

        return allTags.compactMap { TagType.tag($0) }
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
            guard let tag: Tag = fetchedTags?.filter({ $0.name == tag }).first else { return }
            source.deleteTag(tag: tag)
        }
    }

    func rename(from oldName: String, to newName: String) {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: Context = UIContext.button(identifier: .tagsSaveChanges)
        tracker.track(event: event, [contexts])
        guard let tag: Tag = fetchedTags?.filter({ $0.name == oldName }).first else { return }
        source.renameTag(from: tag, to: newName)
        refreshView = true
    }
}
