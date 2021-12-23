// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import Textile
import SwiftUI

class ReaderSettings: StylerModifier, ObservableObject {
    @AppStorage("readerFontSizeAdjustment")
    var fontSizeAdjustment: Int = 0
    
    @AppStorage("readerFontFamily")
    var fontFamily: FontDescriptor.Family = .blanco
}

extension FontDescriptor.Family: RawRepresentable {
    public init?(rawValue: String) {
        self = FontDescriptor.Family(name: rawValue)
    }
    
    public var rawValue: String {
        return self.name
    }
}

