// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public enum TextAlignment {
    case left
    case right
    case center
    case justified

    public init(language: String?) {
        let direction = Locale.Language(identifier: language ?? "en").characterDirection

        switch direction {
        case .rightToLeft:
            self = .right
        case .unknown, .leftToRight, .topToBottom, .bottomToTop:
            self = .left
        @unknown default:
            self = .left
        }
    }
}

public enum VerticalTextAlignment {
    case `default`
    case center
}
