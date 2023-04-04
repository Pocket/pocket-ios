// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit
import Combine
import Sync

protocol HomeRefreshCoordinatorProtocol {
    /// Refresh method that can be called by View Model classes
    /// - Parameters:
    ///   - isForced: True when a user manually asked for a refresh
    ///   - completion: The completion call back to run when the code is done running
    func refresh(isForced: Bool, _ completion: @escaping () -> Void)
}

class HomeRefreshCoordinator: AbstractRefreshCoordinator, HomeRefreshCoordinatorProtocol {

    override var taskID: String! {
        get { return  "com.mozilla.pocket.refresh.home" }
        // set nothing, because only the identifier is allowed
        set {  }
    }

    override var refreshInterval: TimeInterval! {
        get { return  12 * 60 * 60 }
        // set nothing, because only the identifier is allowed
        set {  }
    }

    static let dateLastRefreshKey = "HomeRefreshCoordinator.dateLastRefreshKey"
    private let userDefaults: UserDefaults
    private let source: Source
    private var subscriptions: [AnyCancellable] = []
    private var isRefreshing: Bool = false

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, sessionProvider: SessionProvider, source: Source, userDefaults: UserDefaults) {
        self.source = source
        self.userDefaults = userDefaults
        super.init(notificationCenter: notificationCenter, taskScheduler: taskScheduler, sessionProvider: sessionProvider)
    }

    override func refresh(completion: @escaping () -> Void) {
        super.refresh(completion: completion)
        refresh(isForced: false) {
            completion()
        }
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
                    self.isRefreshing = true
                    try await self.source.fetchSlateLineup(SyncConstants.Home.slateLineupIdentifier)
                    self.userDefaults.setValue(Date(), forKey: Self.dateLastRefreshKey)
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
        guard let lastActiveTimestamp = userDefaults.object(forKey: Self.dateLastRefreshKey) as? Date else {
            return true
        }

        let timeSinceLastRefresh = Date().timeIntervalSince(lastActiveTimestamp)

        return timeSinceLastRefresh >= refreshInterval || isForced
    }
}
