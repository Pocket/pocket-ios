// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Analytics
import Combine
import Textile
import SwiftUI
import SharedPocketKit
import Network

class ReaderSettings: StylerModifier, ObservableObject {
    private let tracker: Tracker

    @AppStorage var fontSizeAdjustment: Int
    @AppStorage var fontFamily: FontDescriptor.Family
    @AppStorage var lineHeightScaleFactorIndex: Int
    @AppStorage var marginsIndex: Int
    @AppStorage var alignmentOption: AlignmentOption
    @AppStorage private var userStatus: Status

    @Published var isPresentingPremiumUpgrade = false
    @Published var isPresentingHooray = false

    enum AlignmentOption: String, CaseIterable {
        case natural = "Default"
        case justified = "Justified"
    }

    enum UserInterFaceSetting {
        case iPhonePortrait
        case iPhoneLandscape
        case iPadPortrait
        case iPadLandscape

        init(isLandscape: Bool, isIpad: Bool) {
            if isLandscape {
                self = isIpad ? .iPadLandscape : .iPhoneLandscape
            } else {
                self = isIpad ? .iPadPortrait : .iPhonePortrait
            }
        }
    }

    private var uiSetting: UserInterFaceSetting {
        UserInterFaceSetting(
            isLandscape: UIDevice.current.orientation.isLandscape,
            isIpad: UIDevice.current.userInterfaceIdiom == .pad
        )
    }

    var alignment: Textile.TextAlignment {
        switch alignmentOption {
        case .natural:
            return TextAlignment(language: Locale.current.identifier)
        case .justified:
            return .justified
        }
    }

    var isUsingDefaults: Bool {
        fontSizeAdjustment == 0 &&
        fontFamily == .blanco &&
        lineHeightScaleFactorIndex == 3 &&
        marginsIndex == 3 &&
        alignmentOption == .natural
    }

    var isPremium: Bool {
        userStatus == .premium
    }

    var lineHeightScaleFactor: Double {
        ReaderAppearance.lineHeightMultipliers[lineHeightScaleFactorIndex]
    }

    var margins: Double {
        ReaderAppearance.margins(for: uiSetting)[marginsIndex]
    }

    var currentStyling: FontStyling {
        if fontFamily == .graphik {
            return GraphikLCGStyling()
        } else {
            return GenericFontStyling(family: fontFamily)
        }
    }

    var fontSet: [FontDescriptor.Family] {
        if isPremium {
            return ReaderAppearance.freeFontFamilies + ReaderAppearance.premiumFontFamilies
        }
        return ReaderAppearance.freeFontFamilies
    }

    var fontSizeAdjustmentRange: ClosedRange<Int> {
        -6...6
    }

    var fontSizeAdjustmentStep: Int {
        2
    }
    /// Default range of indexes for settings adjustments
    var settingIndexRange: ClosedRange<Int> {
        0...6
    }

    /// Step for setting indexes
    var settingIndexStep: Int {
        1
    }

    init(tracker: Tracker, userDefaults: UserDefaults) {
        _fontSizeAdjustment = AppStorage(wrappedValue: 0, UserDefaults.Key.readerFontSizeAdjustment, store: userDefaults)
        _fontFamily = AppStorage(wrappedValue: .blanco, UserDefaults.Key.readerFontFamily, store: userDefaults)
        _lineHeightScaleFactorIndex = AppStorage(wrappedValue: 3, UserDefaults.Key.readerScaleFactorIndex, store: userDefaults)
        _marginsIndex = AppStorage(wrappedValue: 3, UserDefaults.Key.readerMarginsIndex, store: userDefaults)
        _userStatus = AppStorage(wrappedValue: .unknown, UserDefaults.Key.userStatus, store: userDefaults)
        _alignmentOption = AppStorage(wrappedValue: .natural, UserDefaults.Key.readerTextAlignment, store: userDefaults)
        self.tracker = tracker
    }

    func reset() {
        fontSizeAdjustment = 0
        fontFamily = .blanco
        lineHeightScaleFactorIndex = 3
        marginsIndex = 3
        alignmentOption = .natural
    }
}

// MARK: Premium upsell
extension ReaderSettings {
    @MainActor
    func makePremiumUpgradeViewModel() -> PremiumUpgradeViewModel {
        PremiumUpgradeViewModel(
            store: Services.shared.subscriptionStore,
            tracker: tracker,
            source: .premiumFonts,
            networkPathMonitor: NWPathMonitor()
        )
    }

    func trackPremiumDismissed(dismissReason: DismissReason) {
        switch dismissReason {
        case .swipe, .button, .closeButton:
            tracker.track(event: Events.Premium.premiumUpgradeViewDismissed(reason: dismissReason))
        case .system:
            break
        }
    }

    func trackPremiumUpsellViewed() {
        tracker.track(event: Events.Settings.premiumUpsellViewed())
    }

    func presentPremiumUpgrade() {
        isPresentingPremiumUpgrade = true
    }
}

// MARK: Reader appearance
private extension ReaderSettings {
    enum ReaderAppearance {
        // Fonts
        static let freeFontFamilies: [FontDescriptor.Family] = [.graphik, .blanco]
        static let premiumFontFamilies: [FontDescriptor.Family] = [
            .idealSans,
            .inter,
            .plexSans,
            .sentinel,
            .tiempos,
            .vollkorn,
            .whitney,
            .zillaSlab
        ]
        // Line height
        static let lineHeightMultipliers: [Double] = [0.8, 0.85, 0.9, 1.0, 1.2, 1.5, 2.0]
        // Margins
        static let iPhonePortraitMargins: [Double] = [-8.0, -4.0, -2.0, 0.0, 2.0, 4.0, 8.0]
        static let iPhoneLandscapeMargins: [Double] = [-12.0, -8.0, -4.0, 0.0, 4.0, 8.0, 12.0]
        static let iPadPortraitMargins: [Double] = [-12.0, -8.0, -4.0, 0.0, 4.0, 8.0, 12.0]
        static let iPadLandscapeMargins: [Double] = [-36.0, -24.0, -12.0, 0.0, 12.0, 24.0, 36.0]
        static func margins(for setting: UserInterFaceSetting) -> [Double] {
            switch setting {
            case .iPhonePortrait:
                return iPadPortraitMargins
            case .iPhoneLandscape:
                return iPhoneLandscapeMargins
            case .iPadPortrait:
                return iPadPortraitMargins
            case .iPadLandscape:
                return iPadLandscapeMargins
            }
        }
    }
}
