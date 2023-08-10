// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import Textile
import SharedPocketKit

@testable import Sync
@testable import PocketKit

class TagsFilterViewModelTests: XCTestCase {
    private var subscriptions: [AnyCancellable]!
    var source: MockSource!
    var space: Space!
    private var tracker: MockTracker!
    private var userDefaults: UserDefaults!
    private var user: MockUser!

    override func setUp() {
        super.setUp()
        space = .testSpace()
        source = MockSource()
        tracker = MockTracker()
        userDefaults = UserDefaults(suiteName: "TagsFilterViewModelTests")
        user = MockUser()
        subscriptions = []
    }

    override func tearDown() async throws {
        UserDefaults.standard.removePersistentDomain(forName: "TagsFilterViewModelTests")
        source = nil
        subscriptions = []
        try space.clear()
        try await super.tearDown()
    }

    private func subject(
        source: MockSource? = nil,
        userDefaults: UserDefaults? = nil,
        user: User? = nil,
        fetchedTags: [Tag]?,
        selectAllAction: @escaping () -> Void
    ) -> TagsFilterViewModel {
        let source: MockSource = source ?? self.source
        source.stubFetchAllTags {
            fetchedTags
        }
        return TagsFilterViewModel(source: source, tracker: tracker ?? self.tracker, userDefaults: userDefaults ?? self.userDefaults, user: user ?? self.user, selectAllAction: selectAllAction)
    }

    func test_recentTags_withThreeTags_andPremiumUser_returnsNoRecentTags() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["tag 3"])
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(user: MockUser(status: .premium), fetchedTags: savedTags) { }

        XCTAssertEqual(viewModel.recentTags, [])
    }

    func test_recentTags_withMoreThanThreeTags_andPremiumUser_returnsRecentTags() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["tag 3"])
        _ = try? space.createSavedItem(createdAt: Date() + 3, tags: ["tag 4"])

        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(user: MockUser(status: .premium), fetchedTags: savedTags) { }
        XCTAssertEqual(viewModel.recentTags, [TagType.recent("tag 3"), TagType.recent("tag 2"), TagType.recent("tag 1")])
    }

    func test_recentTags_withMoreThanThreeTags_andFreeUser_returnsNoRecentTags() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])
        _ = try? space.createSavedItem(createdAt: Date() + 2, tags: ["tag 3"])
        _ = try? space.createSavedItem(createdAt: Date() + 3, tags: ["tag 4"])
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(user: MockUser(status: .free), fetchedTags: savedTags) { }

        XCTAssertEqual(viewModel.recentTags, [])
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
            deletedTags.append(tag.name)
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

    func test_renameTag_withNoOldName_doesNotRenameTag() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])

        source.stubRenameTag { _, tag in
            XCTFail("Should not have been called")
        }
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(fetchedTags: savedTags) { }
        viewModel.rename(from: nil, to: "tag 0")
    }

    func test_renameTag_withTagThatDoesNotExist_doesNotRenameTag() {
        _ = try? space.createSavedItem(createdAt: Date(), tags: ["tag 1"])
        _ = try? space.createSavedItem(createdAt: Date() + 1, tags: ["tag 2"])

        source.stubRenameTag { _, tag in
            XCTFail("Should not have been called")
        }
        let savedTags = try? space.fetchTags(isArchived: false)
        let viewModel = subject(fetchedTags: savedTags) { }
        viewModel.rename(from: "tag does not exist", to: "tag 2")
    }
}
