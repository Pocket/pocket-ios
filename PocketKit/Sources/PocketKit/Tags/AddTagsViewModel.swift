import Combine
import Sync


class AddTagsViewModel: ObservableObject {
    let item: SavedItem
    let source: Source
    let saveAction: () -> ()
    
    @Published
    var tags: [String] = []
    
    init(item: SavedItem, source: Source, saveAction: @escaping () -> ()) {
        self.item = item
        self.source = source
        self.saveAction = saveAction
        
        tags = item.tags?.compactMap { $0 as? Tag }.map { $0.name ?? "" } ?? []
    }
    
    var placeholderText: String {
        "Enter tag name..."
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
    
    func removeTag(with tag: String) {
        guard let tag = tags.firstIndex(of: tag) else { return }
        tags.remove(at: tag)
    }
    
    private func validateInput(_ tagName: String) -> String {
        return tagName.trimmingCharacters(in: .whitespaces).lowercased()
    }
}
