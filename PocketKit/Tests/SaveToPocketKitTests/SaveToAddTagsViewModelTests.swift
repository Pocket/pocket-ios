// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import Combine
import Analytics
import Textile
import SharedPocketKit

@testable import Sync
@testable import SaveToPocketKit

class SaveToAddTagsViewModelTests: XCTestCase {
    private var space: Space!
    private var tracker: MockTracker!
    private var userDefaults: UserDefaults!
    private var user: MockUser!
    private var subscriptions: [AnyCancellable] = []
    private let retrieveAction: ([String]) -> [CDTag]? = { _ in
        return nil
    }
    private let filterAction: (String, [String]) -> [CDTag]? = { _, _  in
        return nil
    }

    override func setUp() {
        super.setUp()
        tracker = MockTracker()
        user = MockUser()
        userDefaults = UserDefaults(suiteName: "SaveToAddTagsViewModelTests")
        space = .testSpace()
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removePersistentDomain(forName: "SaveToAddTagsViewModelTests")
        try space.clear()
        try super.tearDownWithError()
    }

    @MainActor
    private func subject(
        item: CDSavedItem,
        tracker: Tracker? = nil,
        userDefaults: UserDefaults? = nil,
        user: User? = nil,
        retrieveAction: (([String]) -> [CDTag]?)? = nil,
        filterAction: ((String, [String]) -> [CDTag]?)? = nil,
        saveAction: @escaping ([String]) -> Void
    ) -> SaveToAddTagsViewModel {
        SaveToAddTagsViewModel(
            item: item,
            tracker: tracker ?? self.tracker,
            userDefaults: userDefaults ?? self.userDefaults,
            user: user ?? self.user,
            retrieveAction: retrieveAction ?? self.retrieveAction,
            filterAction: filterAction ?? self.filterAction,
            saveAction: saveAction
        )
    }

    @MainActor
    func test_addTag_withValidName_updatesTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addNewTag(with: "tag 2")

        XCTAssertTrue(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2"])
    }

    @MainActor
    func test_addTag_withAlreadyExistingName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addNewTag(with: "tag 1")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    @MainActor
    func test_addTag_withWhitespaceName_doesNotUpdateTags() {
        let item = space.buildSavedItem(tags: ["tag 1"])
        let viewModel = subject(item: item) { _ in }
        viewModel.tags = ["tag 1"]
        let isValidTag = viewModel.addNewTag(with: "  ")

        XCTAssertFalse(isValidTag)
        XCTAssertEqual(viewModel.tags, ["tag 1"])
    }

    @MainActor
    func test_addTags_delegatesToSaveServiceAndCallsSaveAction() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        try space.save()
        let viewModel = subject(item: space.viewObject(with: item.objectID) as! CDSavedItem) { tags in
            XCTAssert(true, "expect call to save action")
            var tags: [CDTag] = []
            for index in 1...2 {
                let tag: CDTag = CDTag(context: self.space.backgroundContext)
                tag.name = "tag \(index)"
                tag.remoteID = tag.name.uppercased()
                tags.append(tag)
            }
            item.tags = NSOrderedSet(array: tags.compactMap { $0 })
        }

        viewModel.saveTags()
        XCTAssertEqual(item.tags?.compactMap { ($0 as? CDTag)?.name }, ["tag 1", "tag 2"])
    }

    @MainActor
    func test_recentTags_withThreeTags_andPremiumUser_returnsNoRecentTags() throws {
        let item = space.buildSavedItem(tags: [])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            user: MockUser(status: .premium),
            retrieveAction: { _ in
                var tags: [CDTag] = []
                for index in 1...3 {
                    let tag: CDTag = CDTag(context: self.space.viewContext)
                    tag.name = "tag \(index)"
                    tag.remoteID = tag.name.uppercased()
                    tags.append(tag)
                }
                return tags
            }
        ) { _ in
        }
        XCTAssertEqual(viewModel.recentTags, [])
    }

    @MainActor
    func test_recentTags_withMoreThanThreeTags_andPremiumUser_returnsRecentTags() throws {
        let item = space.buildSavedItem(tags: [])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            user: MockUser(status: .premium),
            retrieveAction: { _ in
                var tags: [CDTag] = []
                for index in 1...4 {
                    let tag: CDTag = CDTag(context: self.space.viewContext)
                    tag.name = "tag \(index)"
                    tag.remoteID = tag.name.uppercased()
                    tags.append(tag)
                }
                return tags
            }
        ) { _ in
        }
        XCTAssertEqual(viewModel.recentTags, [TagType.recent("tag 3"), TagType.recent("tag 2"), TagType.recent("tag 1")])
    }

    @MainActor
    func test_recentTags_withMoreThanThreeTags_andFreeUser_returnsNoRecentTags() throws {
        let item = space.buildSavedItem(tags: [])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            user: MockUser(status: .free),
            retrieveAction: { _ in
                var tags: [CDTag] = []
                for index in 1...4 {
                    let tag: CDTag = CDTag(context: self.space.viewContext)
                    tag.name = "tag \(index)"
                    tag.remoteID = tag.name.uppercased()
                    tags.append(tag)
                }
                return tags
            }
        ) { _ in
        }
        XCTAssertEqual(viewModel.recentTags, [])
    }

    @MainActor
    func test_recentTags_withTags_returnsRecentTags() throws {
        let item = space.buildSavedItem(tags: [])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            retrieveAction: { _ in
                var tags: [CDTag] = []
                for index in 1...3 {
                    let tag: CDTag = CDTag(context: self.space.viewContext)
                    tag.name = "tag \(index)"
                    tag.remoteID = tag.name.uppercased()
                    tags.append(tag)
                }
                return tags
            }
        ) { _ in
        }
        XCTAssertEqual(viewModel.recentTags, [])
    }

    @MainActor
    func test_allOtherTags_retrievesValidTagNames_inSortedOrder() throws {
        let item = space.buildSavedItem(tags: ["a"])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            retrieveAction: { _ in
                let tag2: CDTag = CDTag(context: self.space.viewContext)
                let tag3: CDTag = CDTag(context: self.space.viewContext)
                tag2.name = "c"
                tag2.remoteID = tag2.name.uppercased()
                tag3.name = "b"
                return [tag2, tag3]
            }
        ) { _ in
        }

        viewModel.allOtherTags()

        XCTAssertEqual(viewModel.otherTags, [TagType.tag("b"), TagType.tag("c")])
    }

    @MainActor
    func test_recentTags_inMostRecentOrder() throws {
        let item = space.buildSavedItem(tags: ["a"])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            retrieveAction: { _ in
                let tag2: CDTag = CDTag(context: self.space.viewContext)
                let tag3: CDTag = CDTag(context: self.space.viewContext)
                tag2.name = "c"
                tag2.remoteID = tag2.name.uppercased()
                tag3.name = "b"
                return [tag2, tag3]
            }
        ) { _ in
        }

        viewModel.allOtherTags()

        XCTAssertEqual(viewModel.otherTags, [TagType.tag("b"), TagType.tag("c")])
    }

    @MainActor
    func test_removeTag_withValidName_updatesTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        try space.save()
        let viewModel = subject(item: space.viewObject(with: item.objectID) as! CDSavedItem) { _ in }
        viewModel.tags = ["tag 1", "tag 2", "tag 3"]
        viewModel.removeTag(with: "tag 2")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 3"])
    }

    @MainActor
    func test_removeTag_withNotExistingName_updatesTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        try space.save()
        let viewModel = subject(item: space.viewObject(with: item.objectID) as! CDSavedItem) { _ in }
        viewModel.tags = ["tag 1", "tag 2", "tag 3"]
        viewModel.removeTag(with: "tag 4")

        XCTAssertEqual(viewModel.tags, ["tag 1", "tag 2", "tag 3"])
    }

    @MainActor
    func test_newTagInput_withTags_showFiltersTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            filterAction: { _, _  in
                var tags: [CDTag] = []
                for index in 2...3 {
                    let tag: CDTag = CDTag(context: self.space.viewContext)
                    tag.name = "tag \(index)"
                    tag.remoteID = tag.name.uppercased()
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
                XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 2"), TagType.tag("tag 3")])
            }
            .store(in: &subscriptions)
        wait(for: [expectFilterTagsCall], timeout: 2)
    }

    @MainActor
    func test_newTagInput_withNoTags_showAllTags() throws {
        let item = space.buildSavedItem(tags: ["tag 1"])
        try space.save()
        let viewModel = subject(
            item: space.viewObject(with: item.objectID) as! CDSavedItem,
            filterAction: { _, _  in
                var tags: [CDTag] = []
                for index in 2...3 {
                    let tag: CDTag = CDTag(context: self.space.viewContext)
                    tag.name = "tag \(index)"
                    tag.remoteID = tag.name.uppercased()
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
                XCTAssertEqual(viewModel.otherTags, [TagType.tag("tag 2"), TagType.tag("tag 3")])
            }
            .store(in: &subscriptions)
        wait(for: [expectFilterTagsCall], timeout: 2)
    }
}
