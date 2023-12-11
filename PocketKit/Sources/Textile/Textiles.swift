// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreText
import Kingfisher

#if canImport(UIKit)
import UIKit
#endif

public class Textiles {
    public static func initialize() {
        loadFonts()
    }

    public static func loadFonts() {
        guard let otfFonts = Bundle.module.urls(forResourcesWithExtension: "otf", subdirectory: "Fonts"),
        let ttfFonts = Bundle.module.urls(forResourcesWithExtension: "ttf", subdirectory: "Fonts") else {
            return
        }

        CTFontManagerRegisterFontURLs(otfFonts + ttfFonts as CFArray, .process, true) { _, _ in
            return true
        }
    }

    public static func clearImageCache() {
        ImageCache.default.clearCache()
    }
}
