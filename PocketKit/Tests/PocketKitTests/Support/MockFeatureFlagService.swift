// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit
import UIKit
@testable import PocketKit

class MockFeatureFlagService: FeatureFlagServiceProtocol {
    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]

    var shouldDisableReader: Bool = false
}

// MARK: isAssigned
extension MockFeatureFlagService {
    static let isAssigned = "isAssigned"
    typealias IsAssignedImpl = (SharedPocketKit.CurrentFeatureFlags, String?) -> Bool
    struct IsAssignedCall {
        let flag: SharedPocketKit.CurrentFeatureFlags
        let variant: String?
    }

    func stubIsAssigned(impl: @escaping IsAssignedImpl) {
        implementations[Self.isAssigned] = impl
    }

    func isAssigned(flag: SharedPocketKit.CurrentFeatureFlags, variant: String?) -> Bool {
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
    typealias TrackFeatureFlagFeltImpl = (SharedPocketKit.CurrentFeatureFlags, String?) -> Void
    struct TrackFeatureFlagFeltCall {
        let flag: SharedPocketKit.CurrentFeatureFlags
        let variant: String?
    }

    func stubTrackFeatureFlagFelt(impl: @escaping TrackFeatureFlagFeltImpl) {
        implementations[Self.trackFeatureFlagFelt] = impl
    }

    func trackFeatureFlagFelt(flag: SharedPocketKit.CurrentFeatureFlags, variant: String?) {
        guard let impl = implementations[Self.trackFeatureFlagFelt] as? TrackFeatureFlagFeltImpl else {
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

// MARK: getPayload
extension MockFeatureFlagService {
    static let getPayload = "getPayload"
    typealias GetPayloadImpl = (SharedPocketKit.CurrentFeatureFlags) -> String?
    struct GetPayloadCall {
        let flag: SharedPocketKit.CurrentFeatureFlags
    }

    func stubGetPayload(impl: @escaping GetPayloadImpl) {
        implementations[Self.getPayload] = impl
    }

    func getPayload(flag: CurrentFeatureFlags) -> String? {
        guard let impl = implementations[Self.getPayload] as? GetPayloadImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.getPayload] = (calls[Self.getPayload] ?? []) + [GetPayloadCall(flag: flag)]

        return impl(flag)
    }

    func handleGetPayloadCall(at index: Int) -> GetPayloadImpl? {
        guard let calls = calls[Self.getPayload],
              calls.count > index else {
            return nil
        }

        return calls[index] as? GetPayloadImpl
    }
}
