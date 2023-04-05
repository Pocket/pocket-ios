// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SharedPocketKit
import Combine

/// Refresh coordinator to handle the refreshing of all unresolved saves
class UnresolvedSavesRefreshCoordinator: RefreshCoordinator {

    var taskID: String = "com.mozilla.pocket.refresh.unresolved"

    var refreshInterval: TimeInterval? = 60 * 60

    var backgroundRequestType: BackgroundRequestType = .processing

    var notificationCenter: NotificationCenter
    var taskScheduler: BGTaskSchedulerProtocol
    var appSession: SharedPocketKit.AppSession
    var subscriptions: [AnyCancellable] = []

    private let source: Source

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, appSession: AppSession, source: Source) {
        self.notificationCenter = notificationCenter
        self.taskScheduler = taskScheduler
        self.appSession = appSession
        self.source = source
    }

    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        self.source.resolveUnresolvedSavedItems {
            completion()
        }
    }
}
