// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SharedPocketKit
import Combine

/// Refresh coordinator to handle the refreshing of a Users tag data
/// This refresh coordinator will only ever refresh Tags once unless the user manually pulls to refresh on the Tags screen
/// This is because we do not have an updatedSince filter for Tag querying do to how the backend database is setup.
///     However this is ok because tags are always associated with a Saved/Archived Item
///     and we will get any new tags via the updatedSince filter when we load Archive and Save data.
class TagsRefreshCoordinator: RefreshCoordinator {
    // Return nil, which informs the protocol we never want to background refresh tags
    let refreshInterval: TimeInterval? = nil

    let taskID: String = "com.mozilla.pocket.refresh.tags"

    let backgroundRequestType: BackgroundRequestType = .processing

    let notificationCenter: NotificationCenter
    let taskScheduler: BGTaskSchedulerProtocol
    let appSession: SharedPocketKit.AppSession
    var subscriptions: [AnyCancellable] = []
    var sessionSubscriptions: [AnyCancellable] = []

    private var isRefreshing: Bool = false
    private let source: Source
    private let lastRefresh: LastRefresh

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, appSession: AppSession, source: Source, lastRefresh: LastRefresh) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.appSession = appSession
        self.source = source
        self.lastRefresh = lastRefresh
    }

    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        Log.debug("Refresh tags called, isForced: \(String(describing: isForced))")

        if shouldRefresh(isForced: isForced), !isRefreshing {
            self.isRefreshing = true
            Log.breadcrumb(category: "refresh", level: .info, message: "Tags Refresh Occur")
            self.source.refreshTags { [weak self] in
                guard let self else {
                    Log.captureNilWeakSelf()
                    completion()
                    return
                }
                self.lastRefresh.refreshedTags()
                self.isRefreshing = false
                completion()
            }
        } else if isRefreshing {
            Log.debug("Already refreshing Tags")
            completion()
        } else {
            Log.debug("Not refreshing Tags, to early to ask for new data")
            completion()
        }
    }

    /// Determines if Tags is allowed to perform a full refresh or not
    /// - Parameter isForced: True when a user manually asked for a refresh
    /// - Returns: Whether or not Tags should refresh
    func shouldRefresh(isForced: Bool = false) -> Bool {
        guard lastRefresh.lastRefreshTags != nil else {
            // If there is no tag refresh date, load the full tag list.
            return true
        }
        // Grab new tag data if it was forced.
        return isForced
    }
}
