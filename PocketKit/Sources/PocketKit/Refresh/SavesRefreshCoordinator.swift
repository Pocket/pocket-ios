// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import SharedPocketKit

/// Refresh coordinator to handle the refreshing of a Users Save data
class SavesRefreshCoordinator: AbstractRefreshCoordinator {

    override var taskID: String! {
        get { return  "com.mozilla.pocket.refresh.saves" }
        // set nothing, because only the identifier is allowed
        set {  }
    }

    override var refreshInterval: TimeInterval! {
        get { return  60 * 60 }
        set {  }
    }

    private let source: Source

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, appSession: AppSession, source: Source) {
        self.source = source
        super.init(notificationCenter: notificationCenter, taskScheduler: taskScheduler, appSession: appSession)
    }

    override func refresh(completion: @escaping () -> Void) {
        super.refresh(completion: completion)
        self.source.refreshSaves {
            completion()
        }
    }
}
