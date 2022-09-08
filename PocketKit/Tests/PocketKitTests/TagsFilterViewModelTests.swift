import XCTest
import Combine

@testable import Sync
@testable import PocketKit

class TagsFilterViewModelTests: XCTestCase {
    private var subscriptions: [AnyCancellable]!
    var space: Space!

    override func setUp() {
        space = .testSpace()
        subscriptions = []
    }

    override func tearDown() async throws {
        subscriptions = []
        try space.clear()
    }

    private func subject(fetchedTags: [Tag]?, selectAllAction: @escaping () -> Void) -> TagsFilterViewModel {
        TagsFilterViewModel(fetchedTags: fetchedTags, selectAllAction: selectAllAction)
    }

    func test_getAllTags_withNoUserTags_returnsNotTagged() {
        let viewModel = subject(fetchedTags: nil) { }

        let tags = viewModel.getAllTags()

        XCTAssertEqual(tags.count, 1)
        XCTAssertEqual(tags, ["not tagged"])
    }

    func test_getAllTags_withThreeTags_returnsMostRecentTags() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["tag 3"])
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(fetchedTags: savedTags) { }
        XCTAssertEqual(savedTags?.compactMap { $0.name }, ["tag 1", "tag 2", "tag 3"])
        let tags = viewModel.getAllTags()

        XCTAssertEqual(tags.count, 4)
        XCTAssertEqual(tags, ["not tagged", "tag 3", "tag 2", "tag 1"])
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

        XCTAssertEqual(tags.count, 6)
        XCTAssertEqual(tags, ["not tagged", "e", "d", "c", "a", "b"])
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
        wait(for: [expectSeletedTagCall], timeout: 1)
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
        wait(for: [expectSeletedTagCall], timeout: 1)
    }
}
