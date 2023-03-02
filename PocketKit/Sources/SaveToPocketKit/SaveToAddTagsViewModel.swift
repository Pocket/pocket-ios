import Combine
import Sync
import Textile
import Foundation

class SaveToAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem?
    private let retrieveAction: ([String]) -> [Tag]?
    private let filterAction: (String, [String]) -> [Tag]?
    private let saveAction: ([String]) -> Void
    private var userInputListener: AnyCancellable?

    var sectionTitle: TagSectionType = .allTags

    @Published
    var tags: [String] = []

    @Published
    var newTagInput: String = ""

    @Published
    var otherTags: [String] = []

    init(item: SavedItem?, retrieveAction: @escaping ([String]) -> [Tag]?, filterAction: @escaping (String, [String]) -> [Tag]?, saveAction: @escaping ([String]) -> Void) {
        self.item = item
        self.retrieveAction = retrieveAction
        self.filterAction = filterAction
        self.saveAction = saveAction

        tags = item?.tags?.compactMap { ($0 as? Tag)?.name } ?? []
        allOtherTags()

        userInputListener = $newTagInput
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                self?.filterTags(with: text)
        })
    }

    func addTags() {
        saveAction(tags)
    }

    func allOtherTags() {
        let fetchedTags = retrieveAction(tags)
        otherTags = fetchedTags?.compactMap { $0.name } ?? []
        sectionTitle = .allTags
    }

    private func filterTags(with text: String) {
        guard !text.isEmpty else {
            allOtherTags()
            return
        }
        let fetchedTags = filterAction(text.lowercased(), tags)?.compactMap { $0.name } ?? []
        if !fetchedTags.isEmpty {
            otherTags = fetchedTags
            sectionTitle = .filterTags
        } else {
            allOtherTags()
        }
    }
}
