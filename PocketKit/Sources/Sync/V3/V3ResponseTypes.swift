// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol BasicV3Response {
    /**
     Usally 1 if error, but can be other values to indicate an error code
     */
    var error: Int { get set }

    /**
     A 0/1 value which could mean true/false
     */
    var status: Int { get set }
}

public struct V3DeviceToken: Decodable {
    /**
     The deviceIdentifier that was registered
     */
    var deviceIdentifier: String

    /**
     Timestamp of when the token from apple expires
     */
    var expiresAt: Int
}

// MARK: Push Notifications
public struct RegisterPushTokenResponse: Decodable, BasicV3Response {
    var error: Int

    var status: Int

    var token: V3DeviceToken
}

public struct DeregisterPushTokenResponse: Decodable, BasicV3Response {
    var error: Int

    var status: Int
}

// MARK: Premium Status
public struct PremiumStatusResponse: Decodable, BasicV3Response {
    var error, status: Int
    public let subscriptionInfo: SubscriptionInfo
    let features: [Feature]

    enum CodingKeys: String, CodingKey {
        case error, status
        case subscriptionInfo = "subscription_info"
        case features
    }
}

// MARK: - Feature
public struct Feature: Decodable {
    let name, status, statusText: String
    let faqLink: String

    enum CodingKeys: String, CodingKey {
        case name, status
        case statusText = "status_text"
        case faqLink = "faq_link"
    }
}

// MARK: - SubscriptionInfo
public struct SubscriptionInfo: Decodable {
    public let source: String
    public let purchaseDate: String
    public let renewDate: String
    public let subscriptionType: String
    public let displayAmount: String

    enum CodingKeys: String, CodingKey {
        case source
        case purchaseDate = "purchase_date"
        case renewDate = "renew_date"
        case subscriptionType = "subscription_type"
        case displayAmount = "display_amount"
    }

    /// convenience property to provide an initial empty value of `SubscriptionInfo`
    public static var emptyInfo: SubscriptionInfo {
        SubscriptionInfo(
            source: "",
            purchaseDate: "",
            renewDate: "",
            subscriptionType: "",
            displayAmount: ""
        )
    }
}
