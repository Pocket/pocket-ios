// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SharedPocketKit
import Combine

/// Refresh coordinator to handle the refreshing of feature flags
class FeatureFlagsRefreshCoordinator: RefreshCoordinator {

    let taskID: String = "com.mozilla.pocket.refresh.featureFlags"

    let refreshInterval: TimeInterval? = 60 * 60 * 48 // once every 48 hours.

    let backgroundRequestType: BackgroundRequestType = .processing

    let notificationCenter: NotificationCenter
    let taskScheduler: BGTaskSchedulerProtocol
    let appSession: SharedPocketKit.AppSession
    var subscriptions: [AnyCancellable] = []
    var sessionSubscriptions: [AnyCancellable] = []
    private let lastRefresh: LastRefresh

    private let source: Source
    var isRefreshing: Bool = false

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, appSession: AppSession, source: Source, lastRefresh: LastRefresh) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.appSession = appSession
        self.source = source
        self.lastRefresh = lastRefresh
    }

    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        Log.debug("Refresh feature flags called, isForced: \(String(describing: isForced))")

        if shouldRefresh(isForced: isForced), !isRefreshing {
            Task { [weak self] in
                guard let self else {
                    Log.captureNilWeakSelf()
                    completion()
                    return
                }
                do {
                    self.isRefreshing = true
                    try await self.source.fetchAllFeatureFlags()
                    self.lastRefresh.refreshedFeatureFlags()
                    Log.breadcrumb(category: "refresh", level: .info, message: "Feature Flags Refresh Occur")
                } catch {
                    Log.capture(error: error)
                }
                completion()
                isRefreshing = false
            }
        } else if isRefreshing {
            Log.debug("Already refreshing feature flags, not going to add to the queue")
            completion()
        } else {
            Log.debug("Not refreshing  feature flags, to early to ask for new data")
            completion()
        }
    }

    /// Determines if Feature Flags is allowed to refresh or not
    /// - Parameter isForced: True when a user manually asked for a refresh
    /// - Returns: Whether or not Home should refresh
    private func shouldRefresh(isForced: Bool = false) -> Bool {
        guard let lastRefreshHome = lastRefresh.lastRefreshFeatureFlags  else {
            return true
        }
        let timeSinceLastRefresh = Date().timeIntervalSince(Date(timeIntervalSince1970: lastRefreshHome))

        return timeSinceLastRefresh >= refreshInterval! || isForced
    }
}
