// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Combine
import Sync
import SharedPocketKit

class HomeRefreshCoordinator: RefreshCoordinator {
    let taskID: String = "com.mozilla.pocket.refresh.home"

    let refreshInterval: TimeInterval? = 12 * 60 * 60

    let backgroundRequestType: BackgroundRequestType = .refresh

    let notificationCenter: NotificationCenter
    let taskScheduler: BGTaskSchedulerProtocol
    let appSession: SharedPocketKit.AppSession
    var subscriptions: [AnyCancellable] = []
    var sessionSubscriptions: [AnyCancellable] = []
    let lastRefresh: LastRefresh

    private let source: Source
    var isRefreshing: Bool = false

    // In memory date holder to ensure that we don't allow force refreshes to occur one after the other
    var forceRefreshedAt: Date?
    let forceRefreshInterval: TimeInterval = 30

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, appSession: AppSession, source: Source, lastRefresh: LastRefresh) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.appSession = appSession
        self.source = source
        self.lastRefresh = lastRefresh
    }

    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        Log.debug("Refresh home called, isForced: \(String(describing: isForced))")

        if shouldRefresh(isForced: isForced), !isRefreshing {
            Task { [weak self] in
                guard let self else {
                    Log.captureNilWeakSelf()
                    completion()
                    return
                }
                do {
                    if isForced {
                        forceRefreshedAt = Date()
                    }
                    self.isRefreshing = true
                    try await self.source.fetchUnifiedHomeLineup()
                    self.lastRefresh.refreshedHome()
                    Log.breadcrumb(category: "refresh", level: .info, message: "Home Refresh Occur")
                } catch {
                    Log.capture(error: error)
                }
                completion()
                isRefreshing = false
            }
        } else if isRefreshing {
            Log.debug("Already refreshing Home, not going to add to the queue")
            completion()
        } else {
            Log.debug("Not refreshing Home, to early to ask for new data")
            completion()
        }
    }

    /// Determines if Home is allowed to refresh or not
    /// - Parameter isForced: True when a user manually asked for a refresh
    /// - Returns: Whether or not Home should refresh
    private func shouldRefresh(isForced: Bool = false) -> Bool {
        guard let lastRefreshHome = lastRefresh.lastRefreshHome  else {
            return true
        }

        guard isForced, let forceRefreshedAt else {
            let timeSinceLastRefresh = Date().timeIntervalSince(Date(timeIntervalSince1970: lastRefreshHome))
            return timeSinceLastRefresh >= refreshInterval! || isForced
        }

        return forceRefreshedAt.addingTimeInterval(forceRefreshInterval) < Date()
    }
}
