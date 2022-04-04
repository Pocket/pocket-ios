import Foundation


public protocol ExpiringActivityPerformer {
    func performExpiringActivity(withReason reason: String, using block: @escaping (Bool) -> Void)
}

extension ProcessInfo: ExpiringActivityPerformer { }
