import XCTest

@testable import Sync
@testable import PocketKit

class AddTagsViewModelTests: XCTestCase {
    private var source: MockSource!
    private var space: Space!

    override func setUp() {
        source = MockSource()
        space = .testSpace()
    }

    override func tearDown() async throws {
        source = nil
        try space.clear()
    }

    func subject(item: SavedItem, source: Source? = nil, saveAction: @escaping () -> Void) -> AddTagsViewModel {
        AddTagsViewModel(item: item, source: source ?? self.source, saveAction: saveAction)
    }

    func test_addTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { }
        let isValidTag = viewModel.addTag(with: "tag 2")

        XCTAssertTrue(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2"])
    }

    func test_addTag_withAlreadyExistingName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { }
        let isValidTag = viewModel.addTag(with: "tag 1")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTag_withWhitespaceName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { }
        let isValidTag = viewModel.addTag(with: "  ")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTags_delegatesToSourceAndCallsSaveAction() {
        let item = space.buildSavedItem(tags: ["tag 1"])

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

        source.stubRetrieveTags { [weak self] _ in
            guard let self = self else { return nil }
            defer { expectRetrieveTagsCall.fulfill() }
            let tag2: Tag = self.space.new()
            let tag3: Tag = self.space.new()
            tag2.name = "tag 2"
            tag3.name = "tag 3"
            return [tag2, tag3]
        }

        let viewModel = subject(item: item) { }

        guard let tags = viewModel.allOtherTags() else {
            XCTFail("tags should not be nil")
            return
        }

        XCTAssertEqual(tags, ["tag 2", "tag 3"])

        wait(for: [expectRetrieveTagsCall], timeout: 1)
        XCTAssertNotNil(source.retrieveTagsCall(at: 0))
    }

    func test_removeTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1", "tag 2", "tag 3"])
        let viewModel = subject(item: item) { }
        viewModel.removeTag(with: "tag 2")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 3"])
    }

    func test_removeTag_withNotExistingName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1", "tag 2", "tag 3"])
        let viewModel = subject(item: item) { }
        viewModel.removeTag(with: "tag 4")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2", "tag 3"])
    }
}
