// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SwiftUI

public enum Status: String {
    case premium
    case free
    case unknown
}

public protocol User {
    var status: Status { get }
    var userName: String { get }
    var displayName: String { get }
    var email: String { get }
    var statusPublisher: Published<Status>.Publisher { get }
    func setPremiumStatus(_ isPremium: Bool)
    func setUserName(_ userName: String)
    func setDisplayName(_ displayName: String)
    func setEmail(_ email: String)
    func clear()
}

public class PocketUser: User, ObservableObject {
    @Published public private(set) var status: Status = .unknown
    @AppStorage public var userName: String
    @AppStorage public var displayName: String
    @AppStorage public private(set) var email: String
    public var statusPublisher: Published<Status>.Publisher { $status }
    @AppStorage private var storedStatus: Status

    private static let userStatusKey = UserDefaults.Key.userStatus
    private static let userNameKey = UserDefaults.Key.userName
    private static let displayNameKey = UserDefaults.Key.displayName
    private static let emailKey = UserDefaults.Key.userEmail

    public init(status: Status = .unknown, userDefaults: UserDefaults, userName: String = "", displayName: String = "", email: String = "") {
        _storedStatus = AppStorage(wrappedValue: status, Self.userStatusKey, store: userDefaults)
        _userName = AppStorage(wrappedValue: userName, Self.userNameKey, store: userDefaults)
        _displayName = AppStorage(wrappedValue: displayName, Self.displayNameKey, store: userDefaults)
        _email = AppStorage(wrappedValue: email, Self.emailKey)
        publishStatus()
    }

    public func setPremiumStatus(_ isPremium: Bool) {
        let targetStatus: Status = isPremium ? .premium : .free
        setStatus(targetStatus)
    }

    public func setUserName(_ userName: String) {
        self.userName = userName
    }

    public func setDisplayName(_ displayName: String) {
        self.displayName = displayName
    }

    public func setEmail(_ email: String) {
        self.email = email
    }

    public func clear() {
        setStatus(.unknown)
        setUserName("")
        setDisplayName("")
        setEmail("")
    }
}

// MARK: Private helpers
extension PocketUser {
    private func setStatus(_ status: Status) {
        storedStatus = status
        publishStatus()
    }

    private func publishStatus() {
        status = storedStatus
    }
}
