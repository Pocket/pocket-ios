import Combine

public enum TagSectionType: String {
    case allTags = "All Tags"
    case filterTags = "Tags"
}

public protocol AddTagsViewModel: ObservableObject {
    var placeholderText: String { get }
    var emptyStateText: String { get }
    var tags: [String] { get set }
    var newTagInput: String { get set }
    var otherTags: [String] { get set }
    var sectionTitle: TagSectionType { get }
    func addTag(with tag: String) -> Bool
    func addTags()
    func allOtherTags()
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
        if let index = otherTags.firstIndex(of: tagName) {
            otherTags.remove(at: index)
        }
        if otherTags.isEmpty {
            allOtherTags()
        }
        return true
    }

    func removeTag(with tag: String) {
        guard let index = tags.firstIndex(of: tag) else { return }
        tags.remove(at: index)
        otherTags.append(tag)
    }

    private func validateInput(_ tagName: String) -> String {
        return tagName.trimmingCharacters(in: .whitespaces).lowercased()
    }
}
