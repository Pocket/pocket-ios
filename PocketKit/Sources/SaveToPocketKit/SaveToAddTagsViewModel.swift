import Combine
import Sync
import Textile

class SaveToAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem?
    private let retrieveAction: ([String]) -> [Tag]?
    private let saveAction: ([String]) -> Void

    @Published
    var tags: [String] = []

    init(item: SavedItem?, retrieveAction: @escaping ([String]) -> [Tag]?, saveAction: @escaping ([String]) -> Void) {
        self.item = item
        self.retrieveAction = retrieveAction
        self.saveAction = saveAction

        tags = item?.tags?.compactMap { ($0 as? Tag)?.name } ?? []
    }

    func addTags() {
        saveAction(tags)
    }

    func allOtherTags() -> [String]? {
        let fetchedTags = retrieveAction(tags)
        return fetchedTags?.compactMap { $0.name }
    }
}
