// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreText
import Kingfisher

#if canImport(UIKit)
import UIKit
#endif

private extension Style {
    static let navigationTitle: Style = .header.sansSerif.h6
    static let largeNavigationTitle: Style = .header.sansSerif.h2
}

public class Textiles {
    public static func initialize() {
        loadFonts()
    }

    public static func loadFonts() {
        guard let fonts = Bundle.module.urls(forResourcesWithExtension: "otf", subdirectory: "Fonts") else {
            return
        }

        CTFontManagerRegisterFontURLs(fonts as CFArray, .process, true) { _, _ in
            return true
        }
    }

    public static func clearImageCache() {
        ImageCache.default.clearCache()
    }
}
