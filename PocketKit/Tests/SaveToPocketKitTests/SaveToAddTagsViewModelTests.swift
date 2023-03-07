import XCTest
import Combine
import Analytics

@testable import Sync
@testable import SaveToPocketKit

class SaveToAddTagsViewModelTests: XCTestCase {
    private var space: Space!
    private var tracker: MockTracker!
    private var subscriptions: [AnyCancellable] = []
    private let retrieveAction: ([String]) -> [Tag]? = { _ in
        return nil
    }
    private let filterAction: (String, [String]) -> [Tag]? = { _, _  in
        return nil
    }

    override func setUp() {
        tracker = MockTracker()
        space = .testSpace()
    }

    override func tearDown() async throws {
        try space.clear()
    }

    private func subject(item: SavedItem, tracker: Tracker? = nil, retrieveAction: (([String]) -> [Tag]?)? = nil, filterAction: ((String, [String]) -> [Tag]?)? = nil, saveAction: @escaping ([String]) -> Void) -> SaveToAddTagsViewModel {
        SaveToAddTagsViewModel(
            item: item,
            tracker: tracker ?? self.tracker,
            retrieveAction: retrieveAction ?? self.retrieveAction,
            filterAction: filterAction ?? self.filterAction,
            saveAction: saveAction
        )
    }

    func test_addTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addTag(with: "tag 2")

        XCTAssertTrue(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2"])
    }

    func test_addTag_withAlreadyExistingName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addTag(with: "tag 1")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTag_withWhitespaceName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addTag(with: "  ")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    func test_addTags_delegatesToSaveServiceAndCallsSaveAction() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { tags in
            XCTAssert(true, "expect call to save action")
            var tags: [Tag] = []
            for index in 1...2 {
                let tag: Tag = Tag(context: self.space.context)
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
                let tag: Tag = Tag(context: self.space.context)
                tag.name = "tag \(index)"
                tags.append(tag)
            }
                return tags
            }
        ) { _ in
        }

        viewModel.allOtherTags()

        XCTAssertEqual(viewModel.otherTags, ["tag 2", "tag 3"])
    }

    func test_removeTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1", "tag 2", "tag 3"]
        viewModel.removeTag(with: "tag 2")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 3"])
        XCTAssertEqual(viewModel.otherTags, ["tag 2"])
    }

    func test_removeTag_withNotExistingName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1", "tag 2", "tag 3"]
        viewModel.removeTag(with: "tag 4")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2", "tag 3"])
    }

    func test_newTagInput_withTags_showFiltersTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(
            item: item,
            filterAction: { _, _  in
                var tags: [Tag] = []
                for index in 2...3 {
                    let tag: Tag = Tag(context: self.space.context)
                    tag.name = "tag \(index)"
                    tags.append(tag)
                }
                return tags
            }
        ) { _ in }

        viewModel.newTagInput = "ta"

        let expectFilterTagsCall = expectation(description: "expect source.filterTags(with:excluding:)")

        viewModel.$newTagInput
            .delay(for: .seconds(1), scheduler: RunLoop.main, options: .none)
            .sink { string in
                defer { expectFilterTagsCall.fulfill() }
                XCTAssertEqual(viewModel.otherTags, ["tag 2", "tag 3"])
            }
            .store(in: &subscriptions)
        wait(for: [expectFilterTagsCall], timeout: 1)
    }

    func test_newTagInput_withNoTags_showAllTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(
            item: item,
            filterAction: { _, _  in
                var tags: [Tag] = []
                for index in 2...3 {
                    let tag: Tag = Tag(context: self.space.context)
                    tag.name = "tag \(index)"
                    tags.append(tag)
                }
                return tags
            }
        ) { _ in }

        viewModel.newTagInput = "n"

        let expectFilterTagsCall = expectation(description: "expect source.filterTags(with:excluding:)")

        viewModel.$newTagInput
            .delay(for: .seconds(1), scheduler: RunLoop.main, options: .none)
            .sink { string in
                defer { expectFilterTagsCall.fulfill() }
                XCTAssertEqual(viewModel.otherTags, ["tag 2", "tag 3"])
            }
            .store(in: &subscriptions)
        wait(for: [expectFilterTagsCall], timeout: 1)
    }
}
