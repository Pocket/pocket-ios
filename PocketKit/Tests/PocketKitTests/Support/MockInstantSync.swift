// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import UIKit
@testable import PocketKit

class MockInstantSync: MockPushNotificationProtocol, BaseInstantSyncProtocol { }

// MARK: Handle Instant Sync
extension MockInstantSync {
    static let handleInstantSync = "handleInstantSync"
    typealias HandleInstantSyncImpl = ([AnyHashable: Any], ((UIBackgroundFetchResult) -> Void)) -> Void
    struct HandleInstantSyncCall {
        let userInfo: [AnyHashable: Any]
        let completionHandler: (UIBackgroundFetchResult) -> Void
    }

    func stubHandleInstantSync(impl: @escaping HandleBackgroundNotifcationImpl) {
        implementations[Self.handleBackgroundNotifcation] = impl
    }

    func handleInstantSync(
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let impl = implementations[Self.handleInstantSync] as? HandleInstantSyncImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.handleInstantSync] = (calls[Self.handleInstantSync] ?? []) + [HandleInstantSyncCall(userInfo: userInfo, completionHandler: completionHandler)]

        return impl(userInfo, completionHandler)
    }

    func handleHandleInstantSyncCall(at index: Int) -> HandleInstantSyncImpl? {
        guard let calls = calls[Self.handleInstantSync],
              calls.count > index else {
            return nil
        }

        return calls[index] as? HandleInstantSyncImpl
    }
}
