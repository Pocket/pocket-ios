//
//  File.swift
//  
//
//  Created by Daniel Brooks on 4/3/23.
//

import Foundation
import Sync

class SavesRefreshCoordinator: AbstractRefreshCoordinator {

    var taskID: String = "com.mozilla.pocket.refresh.saves"

    var refreshInterval: TimeInterval = 60 * 60

    private let source: Source

    init(notificationCenter: NotificationCenter, taskScheduler: BGTaskSchedulerProtocol, sessionProvider: SessionProvider, source: Source) {
        self.source = source
        super.init(notificationCenter: notificationCenter, taskScheduler: taskScheduler, sessionProvider: sessionProvider)
    }

    override func refresh(completion: (() -> Void)? = nil) {
        super.refresh(completion: completion)
        self.source.refreshSaves {
            guard let completion else {
                return
            }
            completion()
        }
    }
}
