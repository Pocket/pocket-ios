import Combine

public enum TagSectionType: String {
    case allTags = "All Tags"
    case filterTags = "Tags"
}

public enum TagType: Hashable {
    case notTagged
    case tag(String)

    public var name: String {
        switch self {
        case .notTagged:
            return "not tagged"
        case .tag(let name):
            return name
        }
    }
}

public protocol AddTagsViewModel: ObservableObject {
    var placeholderText: String { get }
    var emptyStateText: String { get }
    var tags: [String] { get set }
    var newTagInput: String { get set }
    var otherTags: [TagType] { get set }
    var sectionTitle: TagSectionType { get }
    func addNewTag(with tag: String) -> Bool
    func addExistingTag(with tag: TagType)
    func addTags()
    func allOtherTags()
    func removeTag(with tag: String)

    func trackAddTag()
    func trackRemoveTag()
}

public extension AddTagsViewModel {
    var placeholderText: String {
        "Enter tag name..."
    }

    var emptyStateText: String {
        "Organize your items with Tags.\n To create a tag, enter one below."
    }

    /// Add tag after user enters tag name in the text field
    /// - Parameter tag: tag name user input in the text field
    /// - Returns: true if tag is a valid input
    func addNewTag(with tag: String) -> Bool {
        let tagName = validateInput(tag)
        guard !tagName.isEmpty,
              !tags.contains(tagName) else {
            return false
        }
        addTag(with: tagName)
        return true
    }

    /// Add tag from users list of tags
    /// - Parameter tag: tag name user tapped on in the list
    func addExistingTag(with tag: TagType) {
        addTag(with: tag.name)
    }

    /// Add tag to the input area and remove from the list
    /// - Parameter tag: tag name to add in the input area
    private func addTag(with tagName: String) {
        tags.append(tagName)
        if let index = otherTags.firstIndex(where: { $0.name == tagName}) {
            otherTags.remove(at: index)
        }
        if otherTags.isEmpty {
            allOtherTags()
        }
        trackAddTag()
    }

    /// Removes tag from the `InputTagsView` and adds to list of `OtherTagsView`
    /// - Parameter tag: tag user tapped on in the `InputTagsView`
    func removeTag(with tag: String) {
        guard let index = tags.firstIndex(of: tag) else { return }
        tags.remove(at: index)
        otherTags.append(TagType.tag(tag))
        trackRemoveTag()
    }

    /// Validates user input and formats to proper string
    /// - Parameter tagName: string that user inputs in the text field
    /// - Returns: returns tag name in the proper format to be saved locally
    private func validateInput(_ tagName: String) -> String {
        return tagName.trimmingCharacters(in: .whitespaces).lowercased()
    }
}
