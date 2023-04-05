import Combine
import Sync
import Textile
import Foundation
import Analytics

class SaveToAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem?
    private let tracker: Tracker
    private let retrieveAction: ([String]) -> [String]?
    private let filterAction: (String, [String]) -> [Tag]?
    private let saveAction: ([String]) -> Void
    private var userInputListener: AnyCancellable?

    var sectionTitle: TagSectionType = .allTags

    @Published var tags: [String] = []

    @Published var newTagInput: String = ""

    @Published var otherTags: [TagType] = []

    init(item: SavedItem?, tracker: Tracker, retrieveAction: @escaping ([String]) -> [String]?, filterAction: @escaping (String, [String]) -> [Tag]?, saveAction: @escaping ([String]) -> Void) {
        self.item = item
        self.tracker = tracker
        self.retrieveAction = retrieveAction
        self.filterAction = filterAction
        self.saveAction = saveAction

        tags = item?.tags?.compactMap { ($0 as? Tag)?.name } ?? []
        allOtherTags()

        userInputListener = $newTagInput
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                self?.trackUserEnterText(with: text)
                self?.filterTags(with: text)
        })
    }

    /// Saves tags to an item
    func addTags() {
        trackSaveTagsToItem()
        saveAction(tags)
    }

    /// Fetch all tags associated with an item to show user
    func allOtherTags() {
        otherTags = []
        sectionTitle = .allTags
        trackAllTagsImpression()
    }

    /// Filter tags based on users input
    /// - Parameter text: new tag input entered in the text field
    private func filterTags(with text: String) {
        guard !text.isEmpty else {
            allOtherTags()
            return
        }
        let fetchedTags = filterAction(text.lowercased(), tags)?.compactMap { $0.name } ?? []
        let tagTypes = fetchedTags.compactMap { TagType.tag($0) }
        if !tagTypes.isEmpty {
            otherTags = tagTypes
            sectionTitle = .filterTags
            trackFilteredTagsImpression()
        } else {
            allOtherTags()
        }
    }
}

// MARK: Analytics
extension SaveToAddTagsViewModel {
    public func trackSaveTagsToItem() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.Tags.saveTags(itemUrl: url))
    }

    func trackAddTag() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.addTag")
            return
        }
        tracker.track(event: Events.Tags.addTag(itemUrl: url))
    }

    func trackRemoveTag() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.remoteInputTag")
            return
        }
        tracker.track(event: Events.Tags.remoteInputTag(itemUrl: url))
    }

    func trackUserEnterText(with text: String) {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.Tags.userEntersText(itemUrl: url, text: text))
    }

    func trackAllTagsImpression() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.Tags.allTagsImpression(itemUrl: url))
    }

    func trackFilteredTagsImpression() {
        guard let url = item?.url else {
            Log.capture(message: "Adding tags to an item without an associated url, not logging analytics for Tags.saveTags")
            return
        }
        tracker.track(event: Events.Tags.filteredTagsImpression(itemUrl: url))
    }
}
