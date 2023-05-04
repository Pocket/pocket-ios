import Foundation
import SharedPocketKit
import UIKit
@testable import PocketKit

class MockFeatureFlagService: FeatureFlagServiceProtocol {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: isAssigned
extension MockFeatureFlagService {
    static let isAssigned = "isAssigned"
    typealias IsAssignedImpl = (PocketKit.CurrentFeatureFlags, String?) -> Bool
    struct IsAssignedCall {
        let flag: PocketKit.CurrentFeatureFlags
        let variant: String?
    }

    func stubIsAssigned(impl: @escaping IsAssignedImpl) {
        implementations[Self.isAssigned] = impl
    }

    func isAssigned(flag: PocketKit.CurrentFeatureFlags, variant: String?) -> Bool {
        guard let impl = implementations[Self.isAssigned] as? IsAssignedImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.isAssigned] = (calls[Self.isAssigned] ?? []) + [IsAssignedCall(flag: flag, variant: variant)]

        return impl(flag, variant)
    }

    func handleIsAssignedCall(at index: Int) -> IsAssignedImpl? {
        guard let calls = calls[Self.isAssigned],
              calls.count > index else {
            return nil
        }

        return calls[index] as? IsAssignedImpl
    }
}

// MARK: trackFeatureFlagFelt
extension MockFeatureFlagService {
    static let trackFeatureFlagFelt = "trackFeatureFlagFelt"
    typealias TrackFeatureFlagFeltImpl = (PocketKit.CurrentFeatureFlags, String?) -> Void
    struct TrackFeatureFlagFeltCall {
        let flag: PocketKit.CurrentFeatureFlags
        let variant: String?
    }

    func stubTrackFeatureFlagFelt(impl: @escaping TrackFeatureFlagFeltImpl) {
        implementations[Self.trackFeatureFlagFelt] = impl
    }

    func trackFeatureFlagFelt(flag: PocketKit.CurrentFeatureFlags, variant: String?) {
        guard let impl = implementations[Self.trackFeatureFlagFelt] as? IsAssignedImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.trackFeatureFlagFelt] = (calls[Self.trackFeatureFlagFelt] ?? []) + [TrackFeatureFlagFeltCall(flag: flag, variant: variant)]

        _ = impl(flag, variant)
    }

    func handleTrackFeatureFlagFeltCall(at index: Int) -> TrackFeatureFlagFeltImpl? {
        guard let calls = calls[Self.trackFeatureFlagFelt],
              calls.count > index else {
            return nil
        }

        return calls[index] as? TrackFeatureFlagFeltImpl
    }
}
