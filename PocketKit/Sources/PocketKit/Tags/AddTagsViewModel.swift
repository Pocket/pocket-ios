import Combine
import Sync

class AddTagsViewModel: ObservableObject {
    private let item: SavedItem
    private let source: Source
    private let saveAction: () -> Void

    @Published
    var tags: [String] = []

    init(item: SavedItem, source: Source, saveAction: @escaping () -> Void) {
        self.item = item
        self.source = source
        self.saveAction = saveAction

        tags = item.tags?.compactMap { $0 as? Tag }.map { $0.name ?? "" } ?? []
    }

    var placeholderText: String {
        "Enter tag name..."
    }

    var emptyStateText: String {
        "Organize your items with Tags.\n To create a tag, enter one below."
    }

    func addTag(with tag: String) -> Bool {
        let tagName = validateInput(tag)
        guard !tagName.isEmpty,
              !tags.contains(tagName) else {
            return false
        }
        tags.append(tagName)
        return true
    }

    func addTags() {
        source.addTags(item: item, tags: tags)
        saveAction()
    }

    func allOtherTags() -> [String]? {
        let fetchedTags = source.retrieveTags(excluding: tags)
        return fetchedTags?.compactMap { $0.name }
    }

    func removeTag(with tag: String) {
        guard let tag = tags.firstIndex(of: tag) else { return }
        tags.remove(at: tag)
    }

    private func validateInput(_ tagName: String) -> String {
        return tagName.trimmingCharacters(in: .whitespaces).lowercased()
    }
}
