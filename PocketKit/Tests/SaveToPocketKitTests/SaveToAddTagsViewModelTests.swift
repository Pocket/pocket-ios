import XCTest

@testable import Sync
@testable import SaveToPocketKit

class SaveToAddTagsViewModelTests: XCTestCase {
    private var space: Space!

    override func setUp() {
        space = .testSpace()
    }

    override func tearDown() async throws {
        try space.clear()
    }

    private func subject(item: SavedItem, retrieveAction: @escaping ([String]) -> [Tag]?, saveAction: @escaping ([String]) -> Void) -> SaveToAddTagsViewModel {
        SaveToAddTagsViewModel(item: item, retrieveAction: retrieveAction, saveAction: saveAction)
    }

    func test_addTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let retrieveAction: ([String]) -> [Tag]? = { _ in
            return nil
        }
        let viewModel = subject(item: item, retrieveAction: retrieveAction) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addTag(with: "tag 2")

        XCTAssertTrue(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2"])
    }

    func test_addTag_withAlreadyExistingName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let retrieveAction: ([String]) -> [Tag]? = { _ in
            return nil
        }
        let viewModel = subject(item: item, retrieveAction: retrieveAction) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addTag(with: "tag 1")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTag_withWhitespaceName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let retrieveAction: ([String]) -> [Tag]? = { _ in
            return nil
        }
        let viewModel = subject(item: item, retrieveAction: retrieveAction) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addTag(with: "  ")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTags_delegatesToSaveServiceAndCallsSaveAction() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let retrieveAction: ([String]) -> [Tag]? = { _ in
            return nil
        }

        let viewModel = subject(item: item, retrieveAction: retrieveAction) { tags in
            XCTAssert(true, "expect call to save action")
            var tags: [Tag] = []
            for index in 1...2 {
                let tag: Tag = self.space.new()
                tag.name = "tag \(index)"
                tags.append(tag)
            }
            item.tags = NSOrderedSet(array: tags.compactMap { $0 })
        }

        viewModel.addTags()
        XCTAssertEqual(item.tags?.compactMap { ($0 as? Tag)?.name }, ["tag 1", "tag 2"])
    }

    func test_allOtherTags_retrievesValidTagNames() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(
            item: item,
            retrieveAction: { _ in
            var tags: [Tag] = []
            for index in 2...3 {
                let tag: Tag = self.space.new()
                tag.name = "tag \(index)"
                tags.append(tag)
            }
            return tags
        }) { _ in
        }

        guard let tags = viewModel.allOtherTags() else {
            XCTFail("tags should not be nil")
            return
        }

        XCTAssertEqual(tags, ["tag 2", "tag 3"])
    }

    func test_removeTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let retrieveAction: ([String]) -> [Tag]? = { _ in
            return nil
        }
        let viewModel = subject(item: item, retrieveAction: retrieveAction) { _ in }
        viewModel.tags = ["tag 1", "tag 2", "tag 3"]
        viewModel.removeTag(with: "tag 2")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 3"])
    }

    func test_removeTag_withNotExistingName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let retrieveAction: ([String]) -> [Tag]? = { _ in
            return nil
        }
        let viewModel = subject(item: item, retrieveAction: retrieveAction) { _ in }
        viewModel.tags = ["tag 1", "tag 2", "tag 3"]
        viewModel.removeTag(with: "tag 4")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2", "tag 3"])
    }
}
