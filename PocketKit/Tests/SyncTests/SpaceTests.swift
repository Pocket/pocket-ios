import XCTest

@testable import Sync
import CoreData

class SpaceTests: XCTestCase {
    var viewContext: NSManagedObjectContext!
    var backgroundContext: NSManagedObjectContext!

    override func setUp() {
        viewContext = PersistentContainer.testContainer.viewContext
        backgroundContext = PersistentContainer.testContainer.newBackgroundContext()
    }

    override func tearDownWithError() throws {
        try Space.testSpace().clear()
    }

    func subject() -> Space {
        Space(backgroundContext: backgroundContext, viewContext: viewContext)
    }

    func testDeleteTags() throws {
        let space = subject()
        let items = createItemsWithTags(2)
        try XCTAssertEqual(Set(space.fetchAllTags().compactMap { $0.name }), ["tag 1", "tag 2"])
        XCTAssertEqual(items[0].tags?.count, 1)

        try space.deleteTag(byID: "id 1")

        try XCTAssertEqual(space.fetchAllTags().compactMap { $0.name }, ["tag 2"])
        XCTAssertEqual(items[0].tags?.count, 0)
    }

    func testFetchTagsForSavedAndArchivedItems() throws {
        let space = subject()
        let tag: Tag = Tag(context: space.backgroundContext)
        tag.name = "tag 0"
        tag.remoteID = tag.name.uppercased()
        _ = space.buildSavedItem(tags: [tag])
        _ = createItemsWithTags(2, isArchived: true)

        try XCTAssertEqual(space.fetchTags(isArchived: false).count, 1)
        try XCTAssertEqual(space.fetchTags(isArchived: true).count, 2)
    }

    func testFetchOrCreateTags() throws {
        let space = subject()
        let tag1: Tag = Tag(context: space.backgroundContext)
        tag1.name = "tag 1"
        tag1.remoteID = tag1.name.uppercased()

        let fetchedTag1 = space.fetchOrCreateTag(byName: "tag 1")
        let fetchedTag2 = space.fetchOrCreateTag(byName: "tag 2")

        XCTAssertEqual(fetchedTag1.name, "tag 1")
        XCTAssertEqual(fetchedTag2.name, "tag 2")
        try XCTAssertEqual(space.fetchAllTags().count, 2)
    }

    func testFetchTagsByID() throws {
        let space = subject()
        let tag1: Tag = Tag(context: space.backgroundContext)
        tag1.name = "tag 1"

        let fetchedTag1 = try space.fetchTag(by: "tag 1")
        let fetchedTag2 = try space.fetchTag(by: "tag 2")

        XCTAssertEqual(fetchedTag1?.name, "tag 1")
        XCTAssertNil(fetchedTag2)
    }

    func testRetrieveTagsExcludingCertainTags() throws {
        let space = subject()
        let items = createItemsWithTags(3)
        guard let tag1 = items[1].tags?[0] as? Tag, let tag2 = items[2].tags?[0] as? Tag else {
            XCTFail("Should not be nil")
            return
        }
        let tags = try space.retrieveTags(excluding: ["tag 1"])

        XCTAssertEqual(tags.count, 2)
        XCTAssertTrue(tags.contains(tag1))
        XCTAssertTrue(tags.contains(tag2))
    }

    func testFilterTagsExcludingCertainTags() throws {
        let space = subject()
        let items = createItemsWithTags(3)
        guard let tag0 = items[0].tags?[0] as? Tag, let tag2 = items[2].tags?[0] as? Tag else {
            XCTFail("Should not be nil")
            return
        }
        let tags = try space.filterTags(with: "t", excluding: ["tag 2"])

        XCTAssertEqual(tags.count, 2)
        XCTAssertTrue(tags.contains(tag0))
        XCTAssertTrue(tags.contains(tag2))
    }

    private func createItemsWithTags(_ number: Int, isArchived: Bool = false) -> [SavedItem] {
        guard number > 0 else { return [] }
        return (1...number).compactMap { num in
            let space = subject()
            let tag: Tag = Tag(context: space.backgroundContext)
            tag.remoteID = "id \(num)"
            tag.name = "tag \(num)"
            return space.buildSavedItem(isArchived: isArchived, tags: [tag])
        }
    }
}
