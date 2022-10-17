import Combine
import Sync
import Textile

class PocketAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem
    private let source: Source
    private let saveAction: () -> Void

    @Published
    var tags: [String] = []

    init(item: SavedItem, source: Source, saveAction: @escaping () -> Void) {
        self.item = item
        self.source = source
        self.saveAction = saveAction

        tags = item.tags?.compactMap { ($0 as? Tag)?.name } ?? []
    }

    func addTags() {
        source.addTags(item: item, tags: tags)
        saveAction()
    }

    func allOtherTags() -> [String]? {
        let fetchedTags = source.retrieveTags(excluding: tags)
        return fetchedTags?.compactMap { $0.name }
    }
}
