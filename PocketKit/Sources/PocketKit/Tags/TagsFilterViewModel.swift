import Combine
import Sync
import Analytics
import Foundation

class TagsFilterViewModel: ObservableObject {
    enum SelectedTag {
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
    private let source: Source
    var selectAllAction: () -> Void?

    @Published
    var selectedTag: SelectedTag?

    @Published
    var refreshView: Bool? = false

    init(source: Source, fetchedTags: [Tag]?, selectAllAction: @escaping () -> Void?) {
        self.source = source
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
        return allTags
    }

    func selectTag(_ tag: SelectedTag) {
        selectedTag = tag
        if case .notTagged = tag {
            // TODO: Track Analytics (IN-151)
        }
    }

    func delete(tags: [String]) {
        tags.forEach { tag in
            guard let tag: Tag = fetchedTags?.filter({ $0.name == tag }).first else { return }
            source.deleteTag(tag: tag)
        }
    }

    func rename(from oldName: String, to newName: String) {
        guard let tag: Tag = fetchedTags?.filter({ $0.name == oldName }).first else { return }
        source.renameTag(from: tag, to: newName)
        refreshView = true
    }
}
