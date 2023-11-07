// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Textile
import SwiftUI
import SharedPocketKit

class ReaderSettings: StylerModifier, ObservableObject {
    @AppStorage var fontSizeAdjustment: Int
    @AppStorage var fontFamily: FontDescriptor.Family
    @AppStorage private var userStatus: Status

    var currentStyling: FontStyling {
        if fontFamily == .graphik {
            return GraphikLCGStyling()
        } else {
            return BlancoOSFStyling()
        }
    }

    var fontSet: [FontDescriptor.Family] {
        if case .premium = userStatus {
            return Constants.freeFontFamilies + Constants.premiumFontFamilies
        }
        return Constants.freeFontFamilies
    }

    var adjustmentRange: ClosedRange<Int> {
        Constants.allowedAdjustments
    }

    var adjustmentStep: Int {
        Constants.adjustmentStep
    }

    init(userDefaults: UserDefaults) {
        _fontSizeAdjustment = AppStorage(wrappedValue: 0, UserDefaults.Key.readerFontSizeAdjustment, store: userDefaults)
        _fontFamily = AppStorage(wrappedValue: .blanco, UserDefaults.Key.readerFontSizeAdjustment, store: userDefaults)
        _userStatus = AppStorage(wrappedValue: .unknown, UserDefaults.Key.userStatus, store: userDefaults)
    }
}

private extension ReaderSettings {
    enum Constants {
        static let allowedAdjustments = -6...6
        static let adjustmentStep = 2
        static let freeFontFamilies: [FontDescriptor.Family] = [.graphik, .blanco]
        static let premiumFontFamilies: [FontDescriptor.Family] = [
            .idealSans,
            .inter,
            .plexSans,
            .plexSansSemibold,
            .sentinel,
            .tiempos,
            .vollkorn,
            .whitney,
            .zillaSlab,
            .zillaSlabSemibold
        ]
    }
}

extension FontDescriptor.Family: RawRepresentable {
    public init?(rawValue: String) {
        self = FontDescriptor.Family(name: rawValue)
    }

    public var rawValue: String {
        return self.name
    }
}
