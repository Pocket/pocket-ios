@testable import Sync


class MockLastRefresh: LastRefresh {
    // MARK: - lastRefresh
    typealias GetLastRefreshImpl = () -> Int?
    private var getLastRefreshImpl: GetLastRefreshImpl?
    func stubGetLastRefresh(impl: @escaping GetLastRefreshImpl) {
        getLastRefreshImpl = impl
    }

    var lastRefresh: Int? {
        guard let impl = getLastRefreshImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - refreshed
    typealias RefreshedImpl = () -> ()
    private var refreshedImpl: RefreshedImpl?
    func stubRefreshed(impl: @escaping RefreshedImpl) {
        refreshedImpl = impl
    }

    var refreshedCallCount = 0
    func refreshed() {
        refreshedCallCount += 1

        guard let impl = refreshedImpl else {
            return
        }

        impl()
    }

    typealias ResetImpl = () -> Void
    private var resetImpl: ResetImpl?
    private(set) var resetCallCount = 0
    func reset() {
        resetCallCount += 1
        guard let impl = resetImpl else {
            return
        }

        impl()
    }
}
