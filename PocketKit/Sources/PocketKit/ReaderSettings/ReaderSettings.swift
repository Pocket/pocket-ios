// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Textile
import SwiftUI

class ReaderSettings: StylerModifier, ObservableObject {
    @AppStorage var fontSizeAdjustment: Int

    @AppStorage var fontFamily: FontDescriptor.Family

    var currentStyling: FontStyling {
        if fontFamily == .graphik {
            return GraphikLCGStyling()
        } else {
            return BlancoOSFStyling()
        }
    }

    init(userDefaults: UserDefaults) {
        _fontSizeAdjustment = AppStorage(wrappedValue: 0, UserDefaults.Key.readerFontSizeAdjustment, store: userDefaults)
        _fontFamily = AppStorage(wrappedValue: .blanco, UserDefaults.Key.readerFontSizeAdjustment, store: userDefaults)
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
