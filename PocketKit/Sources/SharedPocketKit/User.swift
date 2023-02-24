import Foundation
import SwiftUI

public enum Status: String {
    case premium = "premium"
    case free = "free"
    case unknown = "unknown"
}

public protocol User {
    var status: Status { get }
    var statusPublisher: Published<Status>.Publisher { get }
    var publishedStatus: Published<Status> { get }
    func setPremiumStatus(_ isPremium: Bool)
    func clear()
}

public class PocketUser: User, ObservableObject {
    @Published public private(set) var status: Status = .unknown
    public var statusPublisher: Published<Status>.Publisher { $status }
    public var publishedStatus: Published<Status> { _status }
    @AppStorage private var storedStatus: Status

    private static let userStatusKey = "User.statusKey"

    public init(status: Status = .unknown, userDefaults: UserDefaults) {
        _storedStatus = AppStorage(wrappedValue: status, Self.userStatusKey, store: userDefaults)
        publishStatus()
    }

    public func setPremiumStatus(_ isPremium: Bool) {
        let targetStatus: Status = isPremium ? .premium : .free
        setStatus(targetStatus)
    }

    public func clear() {
        setStatus(.unknown)
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
