//
//  File.swift
//  
//
//  Created by Daniel Brooks on 9/23/22.
//

import Foundation
import UserNotifications
@testable import PocketKit

class MockPocketBraze: MockPushNotificationProtocol, BrazeSDKProtocol { }

// MARK: Did Receive User Notification
extension MockPocketBraze {

    static let didRecieveUserNotifcation = "didRecieveUserNotifcation"
    typealias DidRecieveUserNotifcationImpl = (UNUserNotificationCenter, UNNotificationResponse, (() -> Void)) -> Void
    struct DidRecieveUserNotifcationCall {
        let center: UNUserNotificationCenter
        let response: UNNotificationResponse
        let completionHandler: () -> Void
    }

    func stubDidRecieveUserNotifcation(impl: @escaping DidRecieveUserNotifcationImpl) {
        implementations[Self.didRecieveUserNotifcation] = impl
    }

    func didReceiveUserNotification(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
            guard let impl = implementations[Self.didRecieveUserNotifcation] as? DidRecieveUserNotifcationImpl else {
                fatalError("\(Self.self).\(#function) has not been stubbed")
            }

            calls[Self.didRecieveUserNotifcation] = (calls[Self.didRecieveUserNotifcation] ?? []) + [DidRecieveUserNotifcationCall(center: center, response: response, completionHandler: completionHandler)]

            return impl(center, response, completionHandler)
        }

    func didRecieveUserNotifcationCall(at index: Int) -> DidRecieveUserNotifcationImpl? {
        guard let calls = calls[Self.didRecieveUserNotifcation],
              calls.count > index else {
            return nil
        }

        return calls[index] as? DidRecieveUserNotifcationImpl
    }
}
