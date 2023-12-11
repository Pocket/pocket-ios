// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@testable import SharedPocketKit

class MockLastRefresh: LastRefresh {
    // MARK: - lastRefresh saves
    typealias GetLastRefreshSavesImpl = () -> Double?
    private var getLastRefreshSavesImpl: GetLastRefreshSavesImpl?
    func stubGetLastRefreshSaves(impl: @escaping GetLastRefreshSavesImpl) {
        getLastRefreshSavesImpl = impl
    }

    var lastRefreshSaves: Double? {
        guard let impl = getLastRefreshSavesImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - lastRefresh archive
    typealias GetLastRefreshArchiveImpl = () -> Double?
    private var getLastRefreshArchiveImpl: GetLastRefreshArchiveImpl?
    func stubGetLastRefreshArchive(impl: @escaping GetLastRefreshArchiveImpl) {
        getLastRefreshArchiveImpl = impl
    }

    var lastRefreshArchive: Double? {
        guard let impl = getLastRefreshArchiveImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - lastRefresh tags
    typealias GetLastRefreshTagsImpl = () -> Double?
    private var getLastRefreshTagsImpl: GetLastRefreshTagsImpl?
    func stubGetLastRefreshTags(impl: @escaping GetLastRefreshTagsImpl) {
        getLastRefreshTagsImpl = impl
    }

    var lastRefreshTags: Double? {
        guard let impl = getLastRefreshTagsImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - lastRefresh home
    typealias GetLastRefreshHomeImpl = () -> Double?
    private var getLastRefreshHomeImpl: GetLastRefreshHomeImpl?
    func stubGetLastRefreshHome(impl: @escaping GetLastRefreshHomeImpl) {
        getLastRefreshHomeImpl = impl
    }

    var lastRefreshHome: Double? {
        guard let impl = getLastRefreshHomeImpl else {
            return nil
        }

        return impl()
    }

    // MARK: - lastRefresh FeatureFlags
    typealias GetLastRefreshFeatureFlagsImpl = () -> Double?
    private var getLastRefreshFeatureFlagsImpl: GetLastRefreshFeatureFlagsImpl?
    func stubGetLastRefreshFeatureFlags(impl: @escaping GetLastRefreshFeatureFlagsImpl) {
        getLastRefreshFeatureFlagsImpl = impl
    }

    var lastRefreshFeatureFlags: Double? {
        guard let impl = getLastRefreshFeatureFlagsImpl else {
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

    // MARK: - refreshed tags
    typealias RefreshedTagsImpl = () -> Void
    private var refreshedTagsImpl: RefreshedTagsImpl?
    func stubRefreshedTags(impl: @escaping RefreshedTagsImpl) {
        refreshedTagsImpl = impl
    }

    var refreshedTagsCallCount = 0
    func refreshedTags() {
        refreshedTagsCallCount += 1

        guard let impl = refreshedTagsImpl else {
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

    // MARK: - refreshed home
    typealias RefreshedHomeImpl = () -> Void
    private var refreshedHomeImpl: RefreshedHomeImpl?
    func stubRefreshedHome(impl: @escaping RefreshedHomeImpl) {
        refreshedHomeImpl = impl
    }

    var refreshedHomeCallCount = 0
    func refreshedHome() {
        refreshedHomeCallCount += 1

        guard let impl = refreshedHomeImpl else {
            return
        }

        impl()
    }

    // MARK: - refreshed feature flags
    typealias RefreshedFeatureFlagsImpl = () -> Void
    private var refreshedFeatureFlagsImpl: RefreshedFeatureFlagsImpl?
    func stubRefreshedFeatureFlags(impl: @escaping RefreshedFeatureFlagsImpl) {
        refreshedFeatureFlagsImpl = impl
    }

    var refreshedFeatureFlagsCallCount = 0
    func refreshedFeatureFlags() {
        refreshedFeatureFlagsCallCount += 1

        guard let impl = refreshedFeatureFlagsImpl else {
            return
        }

        impl()
    }
}
