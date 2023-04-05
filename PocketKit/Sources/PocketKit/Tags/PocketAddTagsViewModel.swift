import Combine
import SwiftUI
import Sync
import Textile
import Foundation
import Analytics

class PocketAddTagsViewModel: AddTagsViewModel {
    private let item: SavedItem
    private let source: Source
    private let tracker: Tracker
    private let store: SubscriptionStore
    private let saveAction: () -> Void
    private var userInputListener: AnyCancellable?
    private var user: User
    private var networkPathMonitor: NetworkPathMonitor
    private var premiumUpsellView: PremiumUpsellView
    private var premiumUpsellViewModel: PremiumUpsellViewModel
    private var premiumUpgradeViewModel: PremiumUpgradeViewModel
    var upsellView: AnyView {
        if user.status == .free {
            return AnyView(erasing: premiumUpsellView)
        } else {
            return AnyView(erasing: EmptyView())
        }
    }

    var sectionTitle: TagSectionType = .allTags

    @Published var tags: [String] = []

    @Published var newTagInput: String = ""

    @Published var otherTags: [TagType] = []

    init(item: SavedItem, source: Source, tracker: Tracker, user: User, store: SubscriptionStore, networkPathMonitor: NetworkPathMonitor, saveAction: @escaping () -> Void) {
        self.item = item
        self.source = source
        self.tracker = tracker
        self.store = store
        self.saveAction = saveAction
        self.user = user
        self.networkPathMonitor = networkPathMonitor

        self.premiumUpgradeViewModel = PremiumUpgradeViewModel(
            store: Services.shared.subscriptionStore,
            tracker: Services.shared.tracker,
            source: .tags,
            networkPathMonitor: self.networkPathMonitor
        )

        self.premiumUpsellViewModel = PremiumUpsellViewModel(networkPathMonitor: networkPathMonitor, user: user, source: source, tracker: tracker, premiumUpgradeViewModelFactory: { PremiumUpgradeSource in
            PremiumUpgradeViewModel(store: store, tracker: tracker, source: .tags, networkPathMonitor: networkPathMonitor)
        })

        self.premiumUpsellView = PremiumUpsellView(viewModel: premiumUpsellViewModel)

        tags = item.tags?.compactMap { ($0 as? Tag)?.name } ?? []
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
        source.addTags(item: item, tags: tags)
        saveAction()
    }

    /// Fetch all tags associated with an item to show user
    func allOtherTags() {
        let fetchedTags = source.retrieveTags(excluding: tags)?.compactMap({ $0.name }) ?? []
        otherTags = arrangeTags(with: fetchedTags)
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
        let fetchedTags = source.filterTags(with: text.lowercased(), excluding: tags)?.compactMap { $0.name } ?? []
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
extension PocketAddTagsViewModel {
    public func trackSaveTagsToItem() {
        tracker.track(event: Events.Tags.saveTags(itemUrl: item.url))
    }

    func trackAddTag() {
        tracker.track(event: Events.Tags.addTag(itemUrl: item.url))
    }

    func trackRemoveTag() {
        tracker.track(event: Events.Tags.remoteInputTag(itemUrl: item.url))
    }

    func trackUserEnterText(with text: String) {
        tracker.track(event: Events.Tags.userEntersText(itemUrl: item.url, text: text))
    }

    func trackAllTagsImpression() {
        tracker.track(event: Events.Tags.allTagsImpression(itemUrl: item.url))
    }

    func trackFilteredTagsImpression() {
        tracker.track(event: Events.Tags.filteredTagsImpression(itemUrl: item.url))
    }
}
