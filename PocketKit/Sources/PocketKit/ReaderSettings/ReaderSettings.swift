// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Textile
import SwiftUI
import SharedPocketKit

class ReaderSettings: StylerModifier, ObservableObject {
    var lineHeightScaleFactor: Double {
        Constants.lineHeightMultipliers[lineHeightScaleFactorIndex]
    }

    @AppStorage var fontSizeAdjustment: Int
    @AppStorage var fontFamily: FontDescriptor.Family
    @AppStorage var lineHeightScaleFactorIndex: Int
    @AppStorage private var userStatus: Status

    var currentStyling: FontStyling {
        if fontFamily == .graphik {
            return GraphikLCGStyling()
        } else {
            return GenericFontStyling(family: fontFamily)
        }
    }

    var fontSet: [FontDescriptor.Family] {
        if case .premium = userStatus {
            return Constants.freeFontFamilies + Constants.premiumFontFamilies
        }
        return Constants.freeFontFamilies
    }

    var adjustmentRange: ClosedRange<Int> {
        Constants.fontSizeAdjustmentRange
    }

    var adjustmentStep: Int {
        Constants.fontSizeAdjustmentStep
    }

    var lineHeightScaleFactorRange: ClosedRange<Int> {
        Constants.lineHaighMultipliersIndexRange
    }

    var lineHeightScaleFactorStep: Int {
        1
    }

    init(userDefaults: UserDefaults) {
        _fontSizeAdjustment = AppStorage(wrappedValue: 0, UserDefaults.Key.readerFontSizeAdjustment, store: userDefaults)
        _fontFamily = AppStorage(wrappedValue: .blanco, UserDefaults.Key.readerFontFamily, store: userDefaults)
        _lineHeightScaleFactorIndex = AppStorage(wrappedValue: Constants.lineHeightMultipliers.count / 2, UserDefaults.Key.readerScaleFactorIndex, store: userDefaults)
        _userStatus = AppStorage(wrappedValue: .unknown, UserDefaults.Key.userStatus, store: userDefaults)
    }
}

extension ReaderSettings {
    enum Constants {
        static let fontSizeAdjustmentRange = -6...6
        static let lineHeightMultipliers: [Double] = [0.75, 0.8, 0.9, 1.0, 1.2, 1.5, 2.0]
        static let lineHaighMultipliersIndexRange: ClosedRange<Int> = 0...lineHeightMultipliers.count - 1
        static let fontSizeAdjustmentStep = 2
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
    }
}
