// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync

class MockV3Client: V3ClientProtocol {
    func sendAppstoreReceipt(source: String, transactionInfo: String, amount: String, productId: String, currency: String, transactionType: String) async throws {}

    private var implementations: [String: Any] = [:]
    private var calls: [String: [Any]] = [:]
}

// MARK: registerPushToken
extension MockV3Client {
    static let registerPushToken = "registerPushToken"
    typealias RegisterPushTokenImpl = (String, Sync.PushType, String, Sync.Session) -> Sync.RegisterPushTokenResponse?
    struct RegisterPushTokenCall {
        let deviceIdentifer: String
        let pushType: PushType
        let token: String
        let session: Sync.Session
    }

    func stubRegisterPushToken(impl: @escaping RegisterPushTokenImpl) {
        implementations[Self.registerPushToken] = impl
    }

    func registerPushToken(for deviceIdentifer: String, pushType: Sync.PushType, token: String, session: Sync.Session) async throws -> Sync.RegisterPushTokenResponse? {
        guard let impl = implementations[Self.registerPushToken] as? RegisterPushTokenImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.registerPushToken] = (calls[Self.registerPushToken] ?? []) + [RegisterPushTokenCall(deviceIdentifer: deviceIdentifer, pushType: pushType, token: token, session: session)]

        return impl(deviceIdentifer, pushType, token, session)
    }

    func registerPushTokenCall(at index: Int) -> RegisterPushTokenCall? {
        guard let calls = calls[Self.registerPushToken],
              calls.count > index else {
            return nil
        }

        return calls[index] as? RegisterPushTokenCall
    }
}

// MARK: deregisterPushToken
extension MockV3Client {
    static let deregisterPushToken = "deregisterPushToken"
    typealias DeregisterPushTokenImpl = (String, Sync.PushType, Sync.Session) -> Sync.DeregisterPushTokenResponse?
    struct DeregisterPushTokenCall {
        let deviceIdentifer: String
        let pushType: PushType
        let session: Sync.Session
    }

    func stubDeregisterPushToken(impl: @escaping DeregisterPushTokenImpl) {
        implementations[Self.deregisterPushToken] = impl
    }

    func deregisterPushToken(for deviceIdentifer: String, pushType: Sync.PushType, session: Sync.Session) async throws -> Sync.DeregisterPushTokenResponse? {
        guard let impl = implementations[Self.deregisterPushToken] as? DeregisterPushTokenImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.deregisterPushToken] = (calls[Self.deregisterPushToken] ?? []) + [DeregisterPushTokenCall(deviceIdentifer: deviceIdentifer, pushType: pushType, session: session)]

        return impl(deviceIdentifer, pushType, session)
    }

    func deregisterPushTokenCall(at index: Int) -> DeregisterPushTokenCall? {
        guard let calls = calls[Self.deregisterPushToken],
              calls.count > index else {
            return nil
        }

        return calls[index] as? DeregisterPushTokenCall
    }
}

// MARK: premiumStatus
extension MockV3Client {
    static let premiumStatus = "premiumStatus"
    typealias PremiumStatusImpl = () -> Sync.PremiumStatusResponse
    struct PremiumStatusCall { }

    func stubPremiumStatusImpl(impl: @escaping PremiumStatusImpl) {
        implementations[Self.premiumStatus] = impl
    }

    func premiumStatus() async throws -> Sync.PremiumStatusResponse {
        guard let impl = implementations[Self.premiumStatus] as? PremiumStatusImpl else {
            fatalError("\(Self.self).\(#function) has not been stubbed")
        }

        calls[Self.premiumStatus] = (calls[Self.premiumStatus] ?? []) + [PremiumStatusCall()]

        return impl()
    }

    func premiumStatusCall(at index: Int) -> PremiumStatusCall? {
        guard let calls = calls[Self.premiumStatus],
              calls.count > index else {
            return nil
        }

        return calls[index] as? PremiumStatusCall
    }
}
