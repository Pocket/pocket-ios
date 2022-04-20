import XCTest
import Sync
import Combine
@testable import PocketKit


class HomeRecommendationCellViewModelTests: XCTestCase {
    var subscriptions: Set<AnyCancellable> = []

    override func tearDown() {
        subscriptions = []
    }

    func subject(
        recommendation: Recommendation? = nil
    ) -> HomeRecommendationCellViewModel {
        HomeRecommendationCellViewModel(recommendation: recommendation ?? .build())
    }

    func test_isSaved_updatesWhenItemIsSaved() {
        let item = Item.build()
        let viewModel = subject(recommendation: Recommendation.build(item: item))

        XCTAssertFalse(viewModel.isSaved)

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.$isSaved.dropFirst().sink { isSaved in
            XCTAssertTrue(isSaved)
            isSavedExpectation.fulfill()
        }.store(in: &subscriptions)

        item.savedItem = SavedItem.build()

        wait(for: [isSavedExpectation], timeout: 1)
    }

    func test_isSaved_updatesWhenItemIsDeleted() {
        let item = Item.build()
        item.savedItem = SavedItem.build()
        let viewModel = subject(recommendation: Recommendation.build(item: item))

        XCTAssertTrue(viewModel.isSaved)

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.$isSaved.dropFirst().sink { isSaved in
            XCTAssertFalse(isSaved)
            isSavedExpectation.fulfill()
        }.store(in: &subscriptions)

        item.savedItem = nil

        wait(for: [isSavedExpectation], timeout: 1)
    }

    func test_isSaved_updatesWhenItemIsArchived() {
        let item = Item.build()
        let savedItem = SavedItem.build()
        item.savedItem = savedItem
        let viewModel = subject(recommendation: Recommendation.build(item: item))

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.$isSaved.dropFirst(1).sink { isSaved in
            XCTAssertFalse(isSaved)
            isSavedExpectation.fulfill()
        }.store(in: &subscriptions)

        item.savedItem?.isArchived = true

        wait(for: [isSavedExpectation], timeout: 1)
    }

    func test_isSaved_updatesWhenItemIsUnarchived() {
        let item = Item.build()
        let savedItem = SavedItem.build(isArchived: true)
        item.savedItem = savedItem
        let viewModel = subject(recommendation: Recommendation.build(item: item))

        let isSavedExpectation = expectation(description: "expected isSaved to be updated")
        viewModel.$isSaved.dropFirst(1).sink { isSaved in
            XCTAssertTrue(isSaved)
            isSavedExpectation.fulfill()
        }.store(in: &subscriptions)

        item.savedItem?.isArchived = false

        wait(for: [isSavedExpectation], timeout: 1)
    }
}
