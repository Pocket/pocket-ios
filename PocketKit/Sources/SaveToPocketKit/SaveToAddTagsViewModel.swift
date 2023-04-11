import Combine
import SwiftUI
import Sync
import Textile
import Foundation
import Analytics
import SharedPocketKit

class SaveToAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem?
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let user: User
    private let recentTagsFactory: RecentTagsProvider
    private let retrieveAction: ([String]) -> [Tag]?
    private let filterAction: (String, [String]) -> [Tag]?
    private let saveAction: ([String]) -> Void
    private var userInputListener: AnyCancellable?
    var upsellView: AnyView { return AnyView(erasing: EmptyView()) }

    var recentTags: [TagType] {
        guard user.status == .premium && fetchAllTags.count > 3 else { return [] }
        return recentTagsFactory.recentTags.sorted().compactMap { TagType.recent($0) }
    }

    /// Fetches all tags associated with item
    private var itemTagNames: [String] {
        item?.tags?.compactMap { ($0 as? Tag)?.name } ?? []
    }

    /// Fetches all tags associated with a user
    private var fetchAllTags: [Tag] {
        self.retrieveAction([]) ?? []
    }

    @Published var tags: [String] = []

    @Published var newTagInput: String = ""

    @Published var otherTags: [TagType] = []

    init(item: SavedItem?, tracker: Tracker, userDefaults: UserDefaults, user: User, retrieveAction: @escaping ([String]) -> [Tag]?, filterAction: @escaping (String, [String]) -> [Tag]?, saveAction: @escaping ([String]) -> Void) {
        self.item = item
        self.tracker = tracker
        self.retrieveAction = retrieveAction
        self.filterAction = filterAction
        self.saveAction = saveAction
        self.userDefaults = userDefaults
        self.user = user
        self.recentTagsFactory = RecentTagsProvider(userDefaults: userDefaults, key: UserDefaults.Key.recentTags)

        tags = itemTagNames
        allOtherTags()

        userInputListener = $newTagInput
            .dropFirst()
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] text in
                self?.trackUserEnterText(with: text)
                self?.filterTags(with: text)
        })

        recentTagsFactory.getInitialRecentTags(with: fetchAllTags.compactMap({ $0.name }))
    }

    /// Saves tags to an item
    func addTags() {
        trackSaveTagsToItem()
        saveAction(tags)
        recentTagsFactory.updateRecentTags(with: itemTagNames, and: tags)
    }

    /// Fetch all tags associated with an item to show user
    func allOtherTags() {
        let fetchedTags = retrieveAction(tags)?.compactMap { $0.name } ?? []
        otherTags = arrangeTags(with: fetchedTags)
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

    func trackRecentTagsTapped(with tag: TagType) {
        guard case .recent = tag else { return }
        tracker.track(event: Events.Tags.addTagsRecentTagTapped())
    }
}
