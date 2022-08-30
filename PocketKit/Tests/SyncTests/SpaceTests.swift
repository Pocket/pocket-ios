import XCTest

@testable import Sync
import CoreData

class SpaceTests: XCTestCase {
    var context: NSManagedObjectContext!
    
    override func setUp() {
        context = PersistentContainer.testContainer.viewContext
    }
    
    override func tearDownWithError() throws {
        try Space.testSpace().clear()
    }
    
    func subject(context: NSManagedObjectContext? = nil) -> Space {
        Space(context: context ?? self.context)
    }
    
    func testDeletingOrphanTags() throws {
        let space = subject()
        _ = space.buildSavedItem(tags: ["tag 1"])
        let tag2: Tag = space.new()
        let tag3: Tag = space.new()
        tag2.name = "tag 2"
        tag3.name = "tag 3"
    
        try XCTAssertEqual(Set(space.fetchTags().compactMap { $0.name }), ["tag 1", "tag 2", "tag 3"])
        
        try space.deleteOrphanTags()
        
        try XCTAssertEqual(space.fetchTags().compactMap { $0.name }, ["tag 1"])
    }
    
    func testFetchTags() throws {
        let space = subject()
        let _: Tag = space.new()
        let _: Tag = space.new()
        
        let tags = try space.fetchTags()
        XCTAssertEqual(tags.count, 2)
    }
    
    func testFetchOrCreateTags() throws {
        let space = subject()
        let tag1: Tag = space.new()
        tag1.name = "tag 1"
        
        let fetchedTag1 = space.fetchOrCreateTag(byName: "tag 1")
        let fetchedTag2 = space.fetchOrCreateTag(byName: "tag 2")
        
        XCTAssertEqual(fetchedTag1.name, "tag 1")
        XCTAssertEqual(fetchedTag2.name, "tag 2")
        try XCTAssertEqual(space.fetchTags().count, 2)
    }
    
    func testRetrieveTagsExcludingCertainTags() throws {
        let space = subject()
        let tag1: Tag = space.new()
        let tag2: Tag = space.new()
        let tag3: Tag = space.new()
        tag1.name = "tag 1"
        tag2.name = "tag 2"
        tag3.name = "tag 3"

        let tags = try space.retrieveTags(excluding: ["tag 1"])
        
        XCTAssertEqual(tags.count, 2)
        XCTAssertTrue(tags.contains(tag2))
        XCTAssertTrue(tags.contains(tag3))
    }
}
