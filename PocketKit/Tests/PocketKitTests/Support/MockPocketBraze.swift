// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UserNotifications
@testable import PocketKit

class MockPocketBraze: MockPushNotificationProtocol, BrazeSDKProtocol { }

// MARK: Did Receive User Notification
extension MockPocketBraze {
    static let didReceiveUserNotifcation = "didRecieveUserNotifcation"
    typealias DidRecieveUserNotifcationImpl = (UNUserNotificationCenter, UNNotificationResponse, (() -> Void)) -> Void
    struct DidRecieveUserNotifcationCall {
        let center: UNUserNotificationCenter
        let response: UNNotificationResponse
        let completionHandler: () -> Void
    }

    func stubDidRecieveUserNotifcation(impl: @escaping DidRecieveUserNotifcationImpl) {
        implementations[Self.didReceiveUserNotifcation] = impl
    }

    func didReceiveUserNotification(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
            guard let impl = implementations[Self.didReceiveUserNotifcation] as? DidRecieveUserNotifcationImpl else {
                fatalError("\(Self.self).\(#function) has not been stubbed")
            }

            calls[Self.didReceiveUserNotifcation] = (calls[Self.didReceiveUserNotifcation] ?? []) + [DidRecieveUserNotifcationCall(center: center, response: response, completionHandler: completionHandler)]

            return impl(center, response, completionHandler)
        }

    func didRecieveUserNotificationCall(at index: Int) -> DidRecieveUserNotifcationImpl? {
        guard let calls = calls[Self.didReceiveUserNotifcation],
              calls.count > index else {
            return nil
        }

        return calls[index] as? DidRecieveUserNotifcationImpl
    }

    func signedInUserDidBeginMigration() {
    }
}
