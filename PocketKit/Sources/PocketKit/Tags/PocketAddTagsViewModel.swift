import Combine
import Sync
import Textile
import Foundation
import SharedPocketKit

class PocketAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem
    private let source: Source
    private let saveAction: () -> Void
    private var userInputListener: AnyCancellable?

    var sectionTitle: TagSectionType = .allTags

    @Published
    var tags: [String] = []

    @Published
    var newTagInput: String = ""

    @Published
    var otherTags: [String] = []

    init(item: SavedItem, source: Source, saveAction: @escaping () -> Void) {
        self.item = item
        self.source = source
        self.saveAction = saveAction

        tags = item.tags?.compactMap { ($0 as? Tag)?.name } ?? []
        allOtherTags()

        userInputListener = $newTagInput
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                self?.filterTags(with: text)
            })
    }

    func addTags() {
        source.addTags(item: item, tags: tags)
        saveAction()
    }

    func allOtherTags() {
        let fetchedTags = source.retrieveTags(excluding: tags)
        otherTags = fetchedTags?.compactMap { $0.name } ?? []
        sectionTitle = .allTags
    }

    /// Filter tags based on users input
    /// - Parameter text: new tag input entered in the text field
    private func filterTags(with text: String) {
        guard !text.isEmpty else {
            allOtherTags()
            return
        }
        let fetchedTags = source.filterTags(with: text.lowercased(), excluding: tags)?.compactMap { $0.name } ?? []

        if !fetchedTags.isEmpty {
            otherTags = fetchedTags
            sectionTitle = .filterTags
        } else {
            allOtherTags()
        }
    }
}
