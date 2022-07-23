import XCTest
import Sync
import Combine

@testable import PocketKit
@testable import Sync


class HomeRecommendationCellViewModelTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []
    var space: Space!

    override func setUp() {
        space = .testSpace()
    }

    override func tearDownWithError() throws {
        subscriptions = []
        try space.clear()
    }

    func subject(
        recommendation: Recommendation? = nil
    ) -> HomeRecommendationCellViewModel {
        HomeRecommendationCellViewModel(recommendation: recommendation ?? .build())
    }

    func test_isSaved_updatesWhenItemIsSaved() throws {
        let item = Item.build()
        let viewModel = subject(recommendation: Recommendation.build(item: item))

        XCTAssertFalse(viewModel.isSaved)

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.updated.sink {
            defer { isSavedExpectation.fulfill() }
            XCTAssertTrue(viewModel.isSaved)
        }.store(in: &subscriptions)

        item.savedItem = SavedItem.build()
        try space.save()

        wait(for: [isSavedExpectation], timeout: 1)
    }

    func test_isSaved_updatesWhenItemIsDeleted() throws {
        let savedItem = SavedItem.build()
        let rec = Recommendation.build(item: savedItem.item)
        try space.save()

        let viewModel = subject(recommendation: rec)
        XCTAssertTrue(viewModel.isSaved)

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.updated.sink {
            defer { isSavedExpectation.fulfill() }
            XCTAssertFalse(viewModel.isSaved)
        }.store(in: &subscriptions)

        space.delete(savedItem)
        try space.save()

        wait(for: [isSavedExpectation], timeout: 1)
    }

    func test_isSaved_updatesWhenItemIsArchived() throws {
        let savedItem = SavedItem.build()
        let rec = Recommendation.build(item: savedItem.item)
        try space.save()

        let viewModel = subject(recommendation: rec)
        XCTAssertTrue(viewModel.isSaved)

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.updated.sink {
            defer { isSavedExpectation.fulfill() }
            XCTAssertFalse(viewModel.isSaved)
        }.store(in: &subscriptions)

        savedItem.isArchived = true
        try space.save()

        wait(for: [isSavedExpectation], timeout: 1)
    }

    func test_isSaved_updatesWhenItemIsUnarchived() throws {
        let savedItem = SavedItem.build(isArchived: true)
        let rec = Recommendation.build(item: savedItem.item)
        try space.save()

        let viewModel = subject(recommendation: rec)
        XCTAssertFalse(viewModel.isSaved)

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.updated.sink {
            defer { isSavedExpectation.fulfill() }
            XCTAssertTrue(viewModel.isSaved)
        }.store(in: &subscriptions)

        savedItem.isArchived = false
        try space.save()

        wait(for: [isSavedExpectation], timeout: 1)
    }
}
