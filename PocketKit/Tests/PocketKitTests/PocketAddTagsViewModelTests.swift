import XCTest
import Combine
import Analytics
import Textile

@testable import Sync
@testable import PocketKit

class PocketAddTagsViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var space: Space!
    private var subscriptions: [AnyCancellable] = []
    private var user: MockUser!
    private var subscriptionStore: SubscriptionStore!
    private var networkPathMonitor: MockNetworkPathMonitor!

    override func setUp() {
        source = MockSource()
        tracker = MockTracker()
        space = .testSpace()
        networkPathMonitor = MockNetworkPathMonitor()
        subscriptionStore = MockSubscriptionStore()
    }

    override func tearDown() async throws {
        source = nil
        try space.clear()
        networkPathMonitor = nil
        subscriptionStore = nil
    }

    private func subject(
        item: SavedItem,
        source: Source? = nil,
        tracker: Tracker? = nil,
        saveAction: @escaping () -> Void,
        networkPathMonitor: NetworkPathMonitor? = nil
    ) -> PocketAddTagsViewModel {
        PocketAddTagsViewModel(
            item: item,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            user: user ?? self.user,
            store: subscriptionStore ?? self.subscriptionStore,
            networkPathMonitor: networkPathMonitor ?? self.networkPathMonitor,
            saveAction: saveAction
        )
    }

    func test_addTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }

        let viewModel = subject(item: item) { }
        let isValidTag = viewModel.addNewTag(with: "tag 2")

        XCTAssertTrue(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2"])
    }

    func test_addTag_withAlreadyExistingName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }

        let viewModel = subject(item: item) { }
        let isValidTag = viewModel.addNewTag(with: "tag 1")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTag_withWhitespaceName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }

        let viewModel = subject(item: item) { }
        let isValidTag = viewModel.addNewTag(with: "  ")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTags_delegatesToSourceAndCallsSaveAction() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }

        let expectAddTagsCall = expectation(description: "expect source.addTags(_:_:)")

        source.stubAddTagsSavedItem { savedItem, tags in
            defer { expectAddTagsCall.fulfill() }
            XCTAssertEqual(savedItem, item)
            XCTAssertEqual(tags, ["tag 1"])
        }

        let viewModel = subject(item: item) {
            XCTAssert(true, "expect call to save action")
        }

        viewModel.addTags()

        wait(for: [expectAddTagsCall], timeout: 1)
        XCTAssertNotNil(source.addTagsToSavedItemCall(at: 0))
    }

    func test_allOtherTags_retrievesValidTagNames() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let expectRetrieveTagsCall = expectation(description: "expect source.retrieveTags(excluding:)")
        expectRetrieveTagsCall.assertForOverFulfill = false
        source.stubRetrieveTags { [weak self] _ in
            defer { expectRetrieveTagsCall.fulfill() }
            let tag2: Tag = Tag(context: self!.space.backgroundContext)
            let tag3: Tag = Tag(context: self!.space.backgroundContext)
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            return [tag2, tag3]
        }

        let viewModel = subject(item: item) { }
        viewModel.allOtherTags()

        wait(for: [expectRetrieveTagsCall], timeout: 1)
        XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 3"), TagType.tag("tag 2")])
        XCTAssertNotNil(source.retrieveTagsCall(at: 0))
    }

    func test_removeTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1", "tag 2", "tag 3"])
        source.stubRetrieveTags { _ in
            return nil
        }

        let viewModel = subject(item: item) { }
        viewModel.removeTag(with: "tag 2")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 3"])
        XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 2")])
    }

    func test_removeTag_withNotExistingName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1", "tag 2", "tag 3"])
        source.stubRetrieveTags { _ in
            return nil
        }

        let viewModel = subject(item: item) { }
        viewModel.removeTag(with: "tag 4")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2", "tag 3"])
    }

    func test_newTagInput_withTags_showFiltersTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }

        source.stubFilterTags { [weak self] _ in
            let tag2: Tag = Tag(context: self!.space.backgroundContext)
            let tag3: Tag = Tag(context: self!.space.backgroundContext)
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            return [tag2, tag3]
        }

        let viewModel = subject(item: item) { }
        viewModel.newTagInput = "ta"

        let expectFilterTagsCall = expectation(description: "expect source.filterTags(with:excluding:)")

        viewModel.$newTagInput
            .delay(for: .seconds(1), scheduler: RunLoop.main, options: .none)
            .sink { string in
                defer { expectFilterTagsCall.fulfill() }
                XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 2"), TagType.tag("tag 3")])
            }
            .store(in: &subscriptions)
        wait(for: [expectFilterTagsCall], timeout: 1)
    }

    func test_newTagInput_withNoTags_showAllTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }

        source.stubFilterTags { [weak self] _ in
            let tag2: Tag = Tag(context: self!.space.backgroundContext)
            let tag3: Tag = Tag(context: self!.space.backgroundContext)
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            return [tag2, tag3]
        }

        let viewModel = subject(item: item) { }
        viewModel.newTagInput = "ta"

        let expectFilterTagsCall = expectation(description: "expect source.filterTags(with:excluding:)")

        viewModel.$newTagInput
            .delay(for: .seconds(1), scheduler: RunLoop.main, options: .none)
            .sink { string in
                defer { expectFilterTagsCall.fulfill() }
                XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 2"), TagType.tag("tag 3")])
            }
            .store(in: &subscriptions)
        wait(for: [expectFilterTagsCall], timeout: 1)
    }
}
