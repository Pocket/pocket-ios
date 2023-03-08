@testable import Sync

class MockLastRefresh: LastRefresh {
    // MARK: - lastRefresh saves
    typealias GetLastRefreshSavesImpl = () -> Int?
    private var getLastRefreshSavesImpl: GetLastRefreshSavesImpl?
    func stubGetLastRefreshSaves(impl: @escaping GetLastRefreshSavesImpl) {
        getLastRefreshSavesImpl = impl
    }

    var lastRefreshSaves: Int? {
        guard let impl = getLastRefreshSavesImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - lastRefresh archive
    typealias GetLastRefreshArchiveImpl = () -> Int?
    private var getLastRefreshArchiveImpl: GetLastRefreshArchiveImpl?
    func stubGetLastRefreshArchive(impl: @escaping GetLastRefreshArchiveImpl) {
        getLastRefreshArchiveImpl = impl
    }

    var lastRefreshArchive: Int? {
        guard let impl = getLastRefreshArchiveImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - refreshed saves
    typealias RefreshedSavesImpl = () -> Void
    private var refreshedSavesImpl: RefreshedSavesImpl?
    func stubRefreshedSaves(impl: @escaping RefreshedSavesImpl) {
        refreshedSavesImpl = impl
    }

    var refreshedSavesCallCount = 0
    func refreshedSaves() {
        refreshedSavesCallCount += 1

        guard let impl = refreshedSavesImpl else {
            return
        }

        impl()
    }

    // MARK: - refreshed archive
    typealias RefreshedArchiveImpl = () -> Void
    private var refreshedArchiveImpl: RefreshedArchiveImpl?
    func stubRefreshedArchive(impl: @escaping RefreshedArchiveImpl) {
        refreshedArchiveImpl = impl
    }

    var refreshedArchiveCallCount = 0
    func refreshedArchive() {
        refreshedArchiveCallCount += 1

        guard let impl = refreshedArchiveImpl else {
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
