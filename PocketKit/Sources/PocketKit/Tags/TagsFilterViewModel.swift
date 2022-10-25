import Combine
import Sync
import Analytics
import Foundation

class TagsFilterViewModel: ObservableObject {
    enum SelectedTag : Equatable {
        case notTagged
        case tag(String)

        var name: String {
            switch self {
            case .notTagged:
                return "not tagged"
            case .tag(let name):
                return name
            }
        }
    }

    private var fetchedTags: [Tag]?
    private let tracker: Tracker
    private let source: Source
    private let tracker: Tracker
    var selectAllAction: () -> Void?

    @Published
    var selectedTag: SelectedTag?

    @Published
    var refreshView: Bool? = false

    init(source: Source, tracker: Tracker, fetchedTags: [Tag]?, selectAllAction: @escaping () -> Void?) {
        self.source = source
        self.tracker = tracker
        self.fetchedTags = fetchedTags
        self.selectAllAction = selectAllAction
    }

    func getAllTags() -> [String] {
        var allTags: [String] = []
        guard let fetchedTags = fetchedTags?.compactMap({ $0.name }).reversed() else { return allTags }

        if fetchedTags.count > 3 {
            let topRecentTags = Array(fetchedTags)[..<3]
            let sortedTags = Array(fetchedTags)[3...].sorted()
            allTags.append(contentsOf: topRecentTags)
            allTags.append(contentsOf: sortedTags)
        } else {
            allTags.append(contentsOf: fetchedTags)
        }

        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: [Context] = [UIContext.home.screen, UIContext.myList.taggedChip]
        tracker.track(event: event, contexts)

        return allTags
    }

    func selectTag(tag: SelectedTag) {
        let tagContext = tag == .notTagged ? UIContext.myList.notTagged : UIContext.myList.taggedChip
        sendSelectedTagAnalytics(context: tagContext)
    }

    private func sendSelectedTagAnalytics(context: Context) {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: [Context] = [UIContext.home.screen, context]
        tracker.track(event: event, contexts)
    }

    func delete(tags: [String]) {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: [Context] = [UIContext.myList.tagsDelete]
        tracker.track(event: event, contexts)
        tags.forEach { tag in
            guard let tag: Tag = fetchedTags?.filter({ $0.name == tag }).first else { return }
            source.deleteTag(tag: tag)
        }
    }

    func rename(from oldName: String, to newName: String) {
        let event = SnowplowEngagement(type: .general, value: nil)
        let contexts: [Context] = [UIContext.myList.tagsSaveChanges]
        tracker.track(event: event, contexts)
        guard let tag: Tag = fetchedTags?.filter({ $0.name == oldName }).first else { return }
        source.renameTag(from: tag, to: newName)
        refreshView = true
    }
}
