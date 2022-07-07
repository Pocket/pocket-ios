import XCTest
import Combine

@testable import Sync


class RecentSavesControllerTests: XCTestCase {
    private var space: Space!
    private var subscriptions: [AnyCancellable]!

    override func setUp() async throws {
        subscriptions = []
        space = Space(container: .testContainer)
    }

    override func tearDown() async throws {
        subscriptions = []
        try space.clear()
    }

    func test_itInitializesRecentSavesTo5MostRecentlySavedItems() throws {
        let savedItems = try (0...9).map { index in
            try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(index)))
        }

        let controller = RecentSavesController(space: space)

        let recentSavesWasSet = expectation(description: "recentSavesWasSet")
        controller.$recentSaves.sink { _ in
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)
        wait(for: [recentSavesWasSet], timeout: 1)

        XCTAssertEqual(controller.recentSaves, Array(savedItems[(5...)]).reversed())
    }

    func test_recentSaves_whenANewItemIsSaved_updatesTheArray() throws {
        let controller = RecentSavesController(space: space)

        let recentSavesWasSet = expectation(description: "recentSavesWasSet")
        controller.$recentSaves.dropFirst().sink { _ in
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)

        let newItem = try space.seedSavedItem()
        wait(for: [recentSavesWasSet], timeout: 1)

        XCTAssertEqual(controller.recentSaves, [newItem])
    }

    func test_recentSaves_whenAnIrrelevantItemIsArchived_doesNotUpdateTheArray() throws {
        let savedItems = try (0...9).map { index in
            try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(index)))
        }

        let controller = RecentSavesController(space: space)
        let recentSavesWasSet = expectation(description: "recentSavesWasSet")
        recentSavesWasSet.isInverted = true

        controller.$recentSaves.dropFirst().sink { _ in
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)

        savedItems.first?.isArchived = true
        try space.save()

        wait(for: [recentSavesWasSet], timeout: 1)
    }

    func test_recentSaves_whenARelevantItemIsArchived_doesUpdateTheArray() throws {
        let savedItems = try (0...9).map { index in
            try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(index)))
        }

        let controller = RecentSavesController(space: space)
        let recentSavesWasSet = expectation(description: "recentSavesWasSet")

        controller.$recentSaves.dropFirst().sink { _ in
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)

        savedItems.last?.isArchived = true
        try space.save()

        wait(for: [recentSavesWasSet], timeout: 1)
    }

    func test_recentSaves_whenARelevantItemIsChanged_doesUpdateTheArray() throws {
        let savedItems = try (0...9).map { index in
            try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(index)))
        }

        let controller = RecentSavesController(space: space)
        let recentSavesWasSet = expectation(description: "recentSavesWasSet")

        controller.itemChanged.sink { item in
            XCTAssertEqual(item, savedItems.last)
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)

        savedItems.last?.isFavorite = true
        try space.save()

        wait(for: [recentSavesWasSet], timeout: 1)
    }

    func test_recentSaves_whenAnIrrelevantItemIsChanged_doesNotUpdateTheArray() throws {
        let savedItems = try (0...9).map { index in
            try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(index)))
        }

        let controller = RecentSavesController(space: space)
        let recentSavesWasSet = expectation(description: "recentSavesWasSet")
        recentSavesWasSet.isInverted = true

        controller.itemChanged.sink { item in
            XCTAssertEqual(item, savedItems.last)
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)

        savedItems.first?.isFavorite = true
        try space.save()

        wait(for: [recentSavesWasSet], timeout: 1)
    }

    func test_recentSaves_whenARelevantItemIsArchived_andDoesNotSendAnEvent() throws {
        let savedItems = try (0...9).map { index in
            try space.seedSavedItem(createdAt: .init(timeIntervalSince1970: TimeInterval(index)))
        }

        let controller = RecentSavesController(space: space)
        let recentSavesWasSet = expectation(description: "recentSavesWasSet")
        recentSavesWasSet.isInverted = true

        controller.itemChanged.sink { item in
            XCTAssertEqual(item, savedItems.last)
            recentSavesWasSet.fulfill()
        }.store(in: &subscriptions)

        savedItems.last?.isArchived = true
        try space.save()

        wait(for: [recentSavesWasSet], timeout: 1)
    }
}
