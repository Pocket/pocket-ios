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
    let subscriptionInfo: SubscriptionInfo
    let features: [Feature]

    enum CodingKeys: String, CodingKey {
        case error, status
        case subscriptionInfo = "subscription_info"
        case features
    }
}

// MARK: - Feature
struct Feature: Codable {
    let name, status, statusText: String
    let faqLink: String

    enum CodingKeys: String, CodingKey {
        case name, status
        case statusText = "status_text"
        case faqLink = "faq_link"
    }
}

// MARK: - SubscriptionInfo
struct SubscriptionInfo: Codable {
    let source, sourceDisplay, subscriptionSource, subscriptionID: String
    let orderID, purchaseDate, renewDate, activeUntilDate: String
    let subscriptionTypeID, subscriptionType: String
    let isActive: Int
    let status, displayAmount, usdAmount: String

    enum CodingKeys: String, CodingKey {
        case source
        case sourceDisplay = "source_display"
        case subscriptionSource = "subscription_source"
        case subscriptionID = "subscription_id"
        case orderID = "order_id"
        case purchaseDate = "purchase_date"
        case renewDate = "renew_date"
        case activeUntilDate = "active_until_date"
        case subscriptionTypeID = "subscription_type_id"
        case subscriptionType = "subscription_type"
        case isActive = "is_active"
        case status
        case displayAmount = "display_amount"
        case usdAmount = "usd_amount"
    }
}
