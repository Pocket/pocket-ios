import Combine

public protocol AddTagsViewModel: ObservableObject {
    var placeholderText: String { get }
    var emptyStateText: String { get }
    var tags: [String] { get set }
    func addTag(with tag: String) -> Bool
    func addTags()
    func allOtherTags() -> [String]?
    func removeTag(with tag: String)
}

public extension AddTagsViewModel {
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

    func removeTag(with tag: String) {
        guard let tag = tags.firstIndex(of: tag) else { return }
        tags.remove(at: tag)
    }

    private func validateInput(_ tagName: String) -> String {
        return tagName.trimmingCharacters(in: .whitespaces).lowercased()
    }
}
