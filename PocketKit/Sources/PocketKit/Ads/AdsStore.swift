// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Textile
import UIKit

enum PocketAdZone: String, Sendable {
    case home
    case saves
    case banner // a banner that we can add to either reader or collection?
    // TODO: ADS - do we want to add a collection type to insert ads in a collection?
}

struct PocketAdsSequence: Identifiable {
    let id: String
    let ads: [PocketAd]
}

struct PocketAd: Decodable {
    let title: String
    let description: String
    let imageUrl: String
    let buttonTitle: String
    /// The destination url when a user taps on an ad
    let targetUrl: String
    // colors are coming in as hex strings but we should convert them.
    // for now let's assume we'll have UIColor
    let textColor: UIColor
    let ctaTextColor: UIColor
    let ctaBackgroundColor: UIColor
    let backgroundColor: UIColor

    enum CodingKeys: String, CodingKey {
        case title = "alt"
        case description = "copy"
        case imageUrl = "image"
        case buttonTitle = "cta"
        case targetUrl = "click"
        case textColor
        case textColorDark
        case ctaTextColor
        case ctaTextColorDark
        case ctaBackgroundColor
        case ctaBackgroundColorDark
        case backgroundColor
        case backgroundColorDark
    }

    init(from decoder: any Decoder) throws {
        // TODO: ADS - the actual json structure is not this flat, this will need to be updated accordingly
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.buttonTitle = try container.decode(String.self, forKey: .buttonTitle)
        self.targetUrl = try container.decode(String.self, forKey: .targetUrl)
        let textColor = try container.decode(String.self, forKey: .textColor)
        let textColorDark = try container.decode(String.self, forKey: .textColorDark)
        self.textColor = UIColor(
            light: UIColor(hexString: textColor),
            dark: UIColor(hexString: textColorDark)
        )
        let ctaTextColor = try container.decode(String.self, forKey: .ctaTextColor)
        let ctaTextColorDark = try container.decode(String.self, forKey: .ctaTextColorDark)
        self.ctaTextColor = UIColor(
            light: UIColor(hexString: ctaTextColor),
            dark: UIColor(hexString: ctaTextColorDark)
        )
        let ctaBackgroundColor = try container.decode(String.self, forKey: .ctaBackgroundColor)
        let ctaBackgroundColorDark = try container.decode(String.self, forKey: .ctaBackgroundColorDark)
        self.ctaBackgroundColor = UIColor(
            light: UIColor(hexString: ctaBackgroundColor),
            dark: UIColor(hexString: ctaBackgroundColorDark)
        )
        let backgroundColor = try container.decode(String.self, forKey: .backgroundColor)
        let backgroundColorDark = try container.decode(String.self, forKey: .backgroundColorDark)
        self.backgroundColor = UIColor(
            light: UIColor(hexString: backgroundColor),
            dark: UIColor(hexString: backgroundColorDark)
        )
    }

    init(
        title: String,
        description: String,
        imageUrl: String,
        buttonTitle: String,
        targetUrl: String,
        textColor: UIColor,
        ctaTextColor: UIColor,
        ctaBackgroundColor: UIColor,
        backgroundColor: UIColor
    ) {
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.buttonTitle = buttonTitle
        self.targetUrl = targetUrl
        self.textColor = textColor
        self.ctaTextColor = ctaTextColor
        self.ctaBackgroundColor = ctaBackgroundColor
        self.backgroundColor = backgroundColor
    }
}

// TODO: ADS - we might want to add a generic protocol here, but for now let's keep it simple
struct PocketAdsStore: Sendable {
    func getAds() async -> [PocketAdsSequence] {
        [
            PocketAdsSequence(id: "ads_sequence_123", ads: [Self.mockAd1, Self.mockAd2, Self.mockAd3]),
            PocketAdsSequence(id: "ads_sequence_132", ads: [Self.mockAd1, Self.mockAd3, Self.mockAd2]),
            PocketAdsSequence(id: "ads_sequence_213", ads: [Self.mockAd2, Self.mockAd1, Self.mockAd3]),
            PocketAdsSequence(id: "ads_sequence_231", ads: [Self.mockAd2, Self.mockAd3, Self.mockAd1]),
            PocketAdsSequence(id: "ads_sequence_321", ads: [Self.mockAd3, Self.mockAd2, Self.mockAd1]),
            PocketAdsSequence(id: "ads_sequence_312", ads: [Self.mockAd3, Self.mockAd1, Self.mockAd2])
        ]
    }
}

// TODO: - ADS - remove this mock when the implementation is complete
private extension PocketAdsStore {
    static let mockAd1 = PocketAd(
        title: "Get Pocket Premium",
        description: "Subscribe to premium to get the most out of Pocket",
        imageUrl: "https://assets-prod.sumo.prod.webservices.mozgcp.net/media/uploads/products/2023-08-22-06-28-55-65dfd5.png",
        buttonTitle: "Get Premium",
        targetUrl: "https://getpocket.com",
        textColor: UIColor(.ui.white1),
        ctaTextColor: UIColor(.ui.white1),
        ctaBackgroundColor: UIColor(.ui.teal1),
        backgroundColor: UIColor(.ui.black1)
    )

    static let mockAd2 = PocketAd(
        title: "Get Pocket Extra",
        description: "Subscribe to extra to get the fanciest Pocket features",
        imageUrl: "https://assets-prod.sumo.prod.webservices.mozgcp.net/media/uploads/products/2023-08-22-06-28-55-65dfd5.png",
        buttonTitle: "Get Premium",
        targetUrl: "https://getpocket.com",
        textColor: UIColor(.ui.white1),
        ctaTextColor: UIColor(.ui.white1),
        ctaBackgroundColor: UIColor(.ui.coral1),
        backgroundColor: UIColor(.ui.black1)
    )

    static let mockAd3 = PocketAd(
        title: "Get Pocket Ultra",
        description: "Subscribe to ultra to get everything you can from Pocket",
        imageUrl: "https://assets-prod.sumo.prod.webservices.mozgcp.net/media/uploads/products/2023-08-22-06-28-55-65dfd5.png",
        buttonTitle: "Get Premium",
        targetUrl: "https://getpocket.com",
        textColor: UIColor(.ui.white1),
        ctaTextColor: UIColor(.ui.white1),
        ctaBackgroundColor: UIColor(.ui.apricot1),
        backgroundColor: UIColor(.ui.black1)
    )
}

// TODO: ADS - move this to SharedPocketKit
extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return dark
            } else {
                return light
            }
        }
    }

    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
