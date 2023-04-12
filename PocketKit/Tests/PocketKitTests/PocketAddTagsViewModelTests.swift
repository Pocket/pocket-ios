import XCTest
import Combine
import Analytics
import Textile
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class PocketAddTagsViewModelTests: XCTestCase {
    private var source: MockSource!
    private var tracker: MockTracker!
    private var userDefaults: UserDefaults!
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
        user = MockUser()

        userDefaults = UserDefaults(suiteName: "PocketAddTagsViewModelTests")
    }

    override func tearDown() async throws {
        UserDefaults.standard.removePersistentDomain(forName: "PocketAddTagsViewModelTests")
        source = nil
        try space.clear()
        networkPathMonitor = nil
        subscriptionStore = nil
    }

    private func subject(
        item: SavedItem,
        source: Source? = nil,
        tracker: Tracker? = nil,
        userDefaults: UserDefaults? = nil,
        user: User? = nil,
        saveAction: @escaping () -> Void,
        networkPathMonitor: NetworkPathMonitor? = nil
    ) -> PocketAddTagsViewModel {
        PocketAddTagsViewModel(
            item: item,
            source: source ?? self.source,
            tracker: tracker ?? self.tracker,
            userDefaults: userDefaults ?? self.userDefaults,
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
        source.stubFetchAllTags { return [] }
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
        source.stubFetchAllTags { return [] }
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
        source.stubFetchAllTags { return [] }
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
        source.stubFetchAllTags { return [] }
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

        wait(for: [expectAddTagsCall], timeout: 10)
        XCTAssertNotNil(source.addTagsToSavedItemCall(at: 0))
    }

    func test_recentTags_withLessThanThreeTags_andPremiumUser_returnsNoRecentTags() {
        let item = space.buildSavedItem(tags: [])
        let expectFetchAllTagsCall = expectation(description: "expect source.fetchAllTags()")
        expectFetchAllTagsCall.assertForOverFulfill = false

        source.stubRetrieveTags { _ in
            return nil
        }

        source.stubFetchAllTags {
            defer { expectFetchAllTagsCall.fulfill() }
            let tag1: Tag = Tag(context: self.space.backgroundContext)
            let tag2: Tag = Tag(context: self.space.backgroundContext)
            let tag3: Tag = Tag(context: self.space.backgroundContext)
            tag1.name = "tag 1"
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            return [tag1, tag2, tag3]
        }

        let viewModel = subject(item: item, user: MockUser(status: .premium)) { }
        wait(for: [expectFetchAllTagsCall], timeout: 10)
        XCTAssertEqual(viewModel.recentTags, [])
    }

    func test_recentTags_withMoreThanThreeTags_andPremiumUser_returnsRecentTags() {
        let item = space.buildSavedItem(tags: [])
        let expectRetrieveTagsCall = expectation(description: "expect source.retrieveTags(excluding:)")
        expectRetrieveTagsCall.assertForOverFulfill = false

        source.stubRetrieveTags { _ in
            return nil
        }

        source.stubFetchAllTags {
            defer { expectRetrieveTagsCall.fulfill() }
            let tag1: Tag = Tag(context: self.space.backgroundContext)
            let tag2: Tag = Tag(context: self.space.backgroundContext)
            let tag3: Tag = Tag(context: self.space.backgroundContext)
            let tag4: Tag = Tag(context: self.space.backgroundContext)
            tag1.name = "tag 1"
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            tag4.name = "tag 4"
            return [tag1, tag2, tag3, tag4]
        }

        let viewModel = subject(item: item, user: MockUser(status: .premium)) { }
        wait(for: [expectRetrieveTagsCall], timeout: 10)
        XCTAssertEqual(viewModel.recentTags, [TagType.recent("tag 1"), TagType.recent("tag 2"), TagType.recent("tag 3")])
    }

    func test_recentTags_withMoreThanThreeTags_andFreeUser_returnsNoRecentTags() {
        let item = space.buildSavedItem(tags: [])
        let expectRetrieveTagsCall = expectation(description: "expect source.retrieveTags(excluding:)")
        expectRetrieveTagsCall.assertForOverFulfill = false

        source.stubRetrieveTags { _ in
            return nil
        }

        source.stubFetchAllTags {
            defer { expectRetrieveTagsCall.fulfill() }
            let tag1: Tag = Tag(context: self.space.backgroundContext)
            let tag2: Tag = Tag(context: self.space.backgroundContext)
            let tag3: Tag = Tag(context: self.space.backgroundContext)
            let tag4: Tag = Tag(context: self.space.backgroundContext)
            tag1.name = "tag 1"
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            tag4.name = "tag 4"
            return [tag1, tag2, tag3, tag4]
        }

        let viewModel = subject(item: item, user: MockUser(status: .free)) { }
        wait(for: [expectRetrieveTagsCall], timeout: 10)
        XCTAssertEqual(viewModel.recentTags, [])
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
        source.stubFetchAllTags { return [] }

        let viewModel = subject(item: item) { }
        viewModel.allOtherTags()

        wait(for: [expectRetrieveTagsCall], timeout: 10)
        XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 2"), TagType.tag("tag 3")])
        XCTAssertNotNil(source.retrieveTagsCall(at: 0))
    }

    func test_removeTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1", "tag 2", "tag 3"])
        source.stubRetrieveTags { _ in
            return nil
        }
        source.stubFetchAllTags { return [] }

        let viewModel = subject(item: item) { }
        viewModel.removeTag(with: "tag 2")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 3"])
    }

    func test_removeTag_withNotExistingName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1", "tag 2", "tag 3"])
        source.stubRetrieveTags { _ in
            return nil
        }
        source.stubFetchAllTags { return [] }

        let viewModel = subject(item: item) { }
        viewModel.removeTag(with: "tag 4")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2", "tag 3"])
    }

    func test_newTagInput_withTags_showFiltersTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }
        source.stubFetchAllTags { return [] }

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
        wait(for: [expectFilterTagsCall], timeout: 10)
    }

    func test_newTagInput_withNoTags_showAllTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        source.stubRetrieveTags { _ in
            return nil
        }
        source.stubFetchAllTags { return [] }

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
        wait(for: [expectFilterTagsCall], timeout: 10)
    }
}
