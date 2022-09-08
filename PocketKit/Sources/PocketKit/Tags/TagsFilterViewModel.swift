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

    private let fetchedTags: [Tag]?
    var selectAllAction: () -> Void?

    @Published
    var selectedTag: SelectedTag?

    init(fetchedTags: [Tag]?, selectAllAction: @escaping () -> Void?) {
        self.fetchedTags = fetchedTags
        self.selectAllAction = selectAllAction
    }

    func getAllTags() -> [String] {
        var allTags = [SelectedTag.notTagged.name]
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
            // TODO: Track Analytics
        }
    }
}
