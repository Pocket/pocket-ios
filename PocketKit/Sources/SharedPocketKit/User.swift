import Foundation
import SwiftUI

public enum Status: String {
    case premium = "premium"
    case free = "free"
    case unknown = "unknown"
}

public protocol User {
    var status: Status { get }
    func setPremiumStatus(_ isPremium: Bool)
    func clear()
}

public class PocketUser: User {
    static let userStatusKey = "User.statusKey"

    @AppStorage
    public var status: Status

    public init(status: Status = .unknown, userDefaults: UserDefaults) {
        _status = AppStorage(wrappedValue: status, Self.userStatusKey, store: userDefaults)
    }

    public func setPremiumStatus(_ isPremium: Bool) {
        status = isPremium ? .premium : .free
    }

    public func clear() {
        status = .unknown
    }
}
