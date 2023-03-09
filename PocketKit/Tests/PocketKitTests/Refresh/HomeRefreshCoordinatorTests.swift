import XCTest
import Sync
import Combine

@testable import PocketKit

class HomeRefreshCoordinatorTests: XCTestCase {
    private var notificationCenter: NotificationCenter!
    private var userDefaults: UserDefaults!
    private var source: MockSource!
    private var subscriptions: Set<AnyCancellable>!
    private var sessionProvider: MockSessionProvider!

    override func setUpWithError() throws {
        notificationCenter = NotificationCenter()
        userDefaults = UserDefaults()
        source = MockSource()
        sessionProvider = MockSessionProvider(session: MockSession())
        subscriptions = []
    }

    override func tearDownWithError() throws {
        userDefaults.removeObject(forKey: HomeRefreshCoordinator.dateLastRefreshKey)
    }

    func subject(
        notificationCenter: NotificationCenter? = nil,
        userDefaults: UserDefaults? = nil,
        source: Source? = nil,
        sessionProvider: SessionProvider? = nil,
        minimumRefreshInterval: TimeInterval = 12 * 60 * 60
    ) -> HomeRefreshCoordinator {
        HomeRefreshCoordinator(
            notificationCenter: notificationCenter ?? self.notificationCenter,
            userDefaults: userDefaults ?? self.userDefaults,
            source: source ?? self.source,
            minimumRefreshInterval: minimumRefreshInterval,
            sessionProvider: sessionProvider ?? self.sessionProvider
        )
    }

    func test_firstRefresh_setsUserDefaults() {
        XCTAssertNil(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey))
        source.stubFetchSlateLineup { _ in }

        let expectRefresh = expectation(description: "Refresh home")

        let coordinator = subject()

        coordinator.refresh {
            expectRefresh.fulfill()
        }
        wait(for: [expectRefresh], timeout: 1)
        XCTAssertNotNil(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey))
    }

    func test_coordinator_whenDataIsNotStale_doesNotRefreshHome() {
        let date = Date()
        userDefaults.setValue(date, forKey: HomeRefreshCoordinator.dateLastRefreshKey)
        XCTAssertNotNil(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey))
        source.stubFetchSlateLineup { _ in }

        let coordinator = subject()
        coordinator.refresh {
            XCTFail("Should not have refreshed")
        }
        XCTAssertEqual(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey) as? Date, date)
    }

    func test_coordinator_whenDataIsStale_refreshesHome() {
        let date = Calendar.current.date(byAdding: .hour, value: -12, to: Date())
        userDefaults.setValue(date, forKey: HomeRefreshCoordinator.dateLastRefreshKey)
        XCTAssertNotNil(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey))
        source.stubFetchSlateLineup { _ in }

        let coordinator = subject()

        let expectRefresh = expectation(description: "Refresh home")
        coordinator.refresh {
            expectRefresh.fulfill()
        }
        wait(for: [expectRefresh], timeout: 1)
        XCTAssertNotEqual(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey) as? Date, date)
    }

    func test_coordinator_whenForceRefresh_refreshesHome() {
        let date = Date()
        userDefaults.setValue(date, forKey: HomeRefreshCoordinator.dateLastRefreshKey)
        XCTAssertNotNil(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey))
        source.stubFetchSlateLineup { _ in }

        let expectRefresh = expectation(description: "Refresh home")

        let coordinator = subject()

        coordinator.refresh(isForced: true) {
            expectRefresh.fulfill()
        }
        wait(for: [expectRefresh], timeout: 1)
    }

    func test_refresh_delegatesToSource() {
        let fetchExpectation = expectation(description: "expected to fetch slate lineup")
        source.stubFetchSlateLineup { _ in fetchExpectation.fulfill() }

        let coordinator = subject()

        coordinator.refresh(isForced: true) { }
        wait(for: [fetchExpectation], timeout: 2)

        XCTAssertEqual(source.fetchSlateLineupCall(at: 0)?.identifier, "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1")
    }

    func test_coordinator_whenEnterForeground_whenDataIsNotStale_doesNotRefreshHome() {
        source.stubFetchSlateLineup { _ in
            XCTFail("Should not fetch slate lineup")
        }
        let date = Date()
        userDefaults.setValue(date, forKey: HomeRefreshCoordinator.dateLastRefreshKey)

        let coordinator = subject()
        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: nil)

        XCTAssertEqual(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey) as? Date, date)
    }

    func test_coordinator_whenEnterForeground_whenDataIsStale_refreshesHome() {
        let fetchExpectation = expectation(description: "expected to fetch slate lineup")
        source.stubFetchSlateLineup { _ in fetchExpectation.fulfill() }
        let date = Calendar.current.date(byAdding: .hour, value: -12, to: Date())
        userDefaults.setValue(date, forKey: HomeRefreshCoordinator.dateLastRefreshKey)

        let coordinator = subject()
        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: nil)

        wait(for: [fetchExpectation], timeout: 2)
        XCTAssertEqual(source.fetchSlateLineupCall(at: 0)?.identifier, "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1")
        XCTAssertNotEqual(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey) as? Date, date)
    }

    func test_coordinator_whenNoSession_doesNotRefreshHome() {
        source.stubFetchSlateLineup { _ in
            XCTFail("Should not fetch slate lineup")
        }
        userDefaults.removeObject(forKey: HomeRefreshCoordinator.dateLastRefreshKey)

        let coordinator = subject(sessionProvider: MockSessionProvider(session: nil))
        notificationCenter.post(name: UIScene.willEnterForegroundNotification, object: nil)

        XCTAssertNil(userDefaults.object(forKey: HomeRefreshCoordinator.dateLastRefreshKey))
    }
}
