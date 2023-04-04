// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync

/// Refresh coordinator to handle the refreshing of all unresolved saves
class UnresolvedSavesRefreshCoordinator: AbstractRefreshCoordinator {

    override var taskID: String! {
        get { return  "com.mozilla.pocket.refresh.unresolved" }
        // set nothing, because only the identifier is allowed
        set {  }
    }

    override var refreshInterval: TimeInterval! {
        get { return  60 * 60 }
        // set nothing, because only the identifier is allowed
        set {  }
    }
    private let source: Source

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, sessionProvider: SessionProvider, source: Source) {
        self.source = source
        super.init(notificationCenter: notificationCenter, taskScheduler: taskScheduler, sessionProvider: sessionProvider)
    }

    override func refresh(completion: @escaping () -> Void) {
        super.refresh(completion: completion)
        self.source.resolveUnresolvedSavedItems {
            completion()
        }
    }
}
