// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

protocol V3Request: Encodable {
    var accessToken: String { get }

    var consumerKey: String { get }

    var guid: String { get }
}

public struct AnonymousGuidRequest: Codable, Equatable, V3Request {
    let accessToken: String
    let consumerKey: String
    let guid: String

    init(consumerKey: String) {
        self.accessToken = ""
        self.guid = ""
        self.consumerKey = consumerKey
    }
}

public struct RegisterPushTokenRequest: Codable, Equatable, V3Request {
    let accessToken: String

    let consumerKey: String

    let guid: String

    let deviceIdentifier: String
    let pushType: String
    let token: String
}

public struct DeregisterPushTokenRequest: Codable, Equatable, V3Request {
    let accessToken: String

    let consumerKey: String

    let guid: String

    let deviceIdentifier: String
    let pushType: String
}

public struct PremiumStatusRequest: Codable, Equatable, V3Request {
    let accessToken: String

    let consumerKey: String

    let guid: String
}

public struct AppstoreReceiptRequest: Codable, Equatable, V3Request {
    let accessToken: String
    let consumerKey: String
    let guid: String
    let source: String
    let transactionInfo: String
    let amount: String
    let productId: String
    let currency: String
    let transactionType: String
}
