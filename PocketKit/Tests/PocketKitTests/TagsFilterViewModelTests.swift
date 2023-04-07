import XCTest
import Combine
import Textile

@testable import Sync
@testable import PocketKit

class TagsFilterViewModelTests: XCTestCase {
    private var subscriptions: [AnyCancellable]!
    var source: MockSource!
    var space: Space!
    private var tracker: MockTracker!

    override func setUp() {
        space = .testSpace()
        source = MockSource()
        tracker = MockTracker()
        subscriptions = []
    }

    override func tearDown() async throws {
        source = nil
        subscriptions = []
        try space.clear()
    }

    private func subject(source: Source? = nil, fetchedTags: [Tag]?, selectAllAction: @escaping () -> Void) -> TagsFilterViewModel {
        TagsFilterViewModel(source: source ?? self.source, tracker: tracker ?? self.tracker, fetchedTags: fetchedTags, selectAllAction: selectAllAction)
    }

    func test_getAllTags_withThreeTags_returnsMostRecentTags() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["tag 3"])
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(fetchedTags: savedTags) { }
        XCTAssertEqual(savedTags?.compactMap { $0.name }, ["tag 1", "tag 2", "tag 3"])
        let tags = viewModel.getAllTags()

        XCTAssertEqual(tags.count, 3)
        XCTAssertEqual(tags, [TagType.tag("tag 3"), TagType.tag("tag 2"), TagType.tag("tag 1")])
    }

    func test_getAllTags_withMoreThan3Tags_returnsSortedOrder() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["a"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["b"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["c"])
        _ = try? space.createSavedItem(createdAt: Date() + 3, tags: ["d"])
        _ = try? space.createSavedItem(createdAt: Date() + 4, tags: ["e"])

        let savedTags = try? space.fetchTags(isArchived: false)
        XCTAssertEqual(savedTags?.compactMap { $0.name }, ["a", "b", "c", "d", "e"])
        let viewModel = subject(fetchedTags: savedTags) { }

        let tags = viewModel.getAllTags()

        XCTAssertEqual(tags.count, 5)
        XCTAssertEqual(tags, [TagType.tag("e"), TagType.tag("d"), TagType.tag("c"), TagType.tag("a"), TagType.tag("b")])
    }

    func test_selectedTag_withTagName_sendsPredicate() {
        let expectSeletedTagCall = expectation(description: "expect selectedTag to be sent")
        let viewModel = subject(fetchedTags: nil) { }

        viewModel.$selectedTag.dropFirst().sink { selectedTag in
            defer { expectSeletedTagCall.fulfill() }
            guard case .notTagged = selectedTag else {
                XCTFail("should get notTagged")
                return
            }
            XCTAssertEqual(selectedTag?.name, "not tagged")
        }.store(in: &subscriptions)

        viewModel.selectTag(.notTagged)
        wait(for: [expectSeletedTagCall], timeout: 5)
    }

    func test_selectedTag_withNotTagged_sendsPredicate() {
        let expectSeletedTagCall = expectation(description: "expect selectedTag to be sent")
        let viewModel = subject(fetchedTags: nil) { }

        viewModel.$selectedTag.dropFirst().sink { selectedTag in
            defer { expectSeletedTagCall.fulfill() }
            guard case .tag(let name) = selectedTag else {
                XCTFail("should get tag")
                return
            }
            XCTAssertEqual(selectedTag?.name, name)
        }.store(in: &subscriptions)

        viewModel.selectTag(.tag("tag 0"))
        wait(for: [expectSeletedTagCall], timeout: 5)
    }

    func test_deleteTag_removesExistingTags() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["a"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["b"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["c"])
        _ = try? space.createSavedItem(createdAt: Date() + 3, tags: ["d"])
        _ = try? space.createSavedItem(createdAt: Date() + 4, tags: ["e"])
        var deletedTags: [String] = []
        let expectDelete = expectation(description: "expect source.deleteTag(_:)")
        expectDelete.assertForOverFulfill = false
        source.stubDeleteTag { tag in
            defer { expectDelete.fulfill() }
            deletedTags.append(tag.name ?? "")
        }
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(fetchedTags: savedTags) { }
        viewModel.delete(tags: ["b", "e", "q"])

        XCTAssertEqual(deletedTags, ["b", "e"])
        wait(for: [expectDelete], timeout: 10)
    }

    func test_renameTag_showsNewName() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])

        let expectRename = expectation(description: "expect source.renameTag(_:_:)")
        source.stubRenameTag { _, tag in
            defer { expectRename.fulfill() }
            XCTAssertEqual(tag, "tag 0")
        }
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(fetchedTags: savedTags) { }
        viewModel.rename(from: "tag 1", to: "tag 0")

        wait(for: [expectRename], timeout: 10)
    }
}
