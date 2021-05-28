// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import CoreText

#if canImport(UIKit)
import UIKit
#endif

private extension Style {
    static let navigationTitle: Style = .header.sansSerif.h6
    static let largeNavigationTitle: Style = .header.sansSerif.h2
}

public class Textiles {
    static let bundle = Bundle(for: Textiles.self)

    public static func initialize() {
        loadFonts()
        
        if #available(iOS 1.0, *) {
            UINavigationBar.appearance().titleTextAttributes = Style.navigationTitle.textAttributes
            UINavigationBar.appearance().largeTitleTextAttributes = Style.largeNavigationTitle.textAttributes
        }
    }

    public static func loadFonts() {
        guard let fonts = Textiles.bundle.urls(forResourcesWithExtension: "otf", subdirectory: "Fonts") else {
            return
        }

        CTFontManagerRegisterFontURLs(fonts as CFArray, .process, true) { errors, done in
            if (done) {
                let errors = errors as! [NSError]
                errors.forEach { error in
                    var components = [error.localizedDescription]
                    if let urls = error.userInfo["CTFontManagerErrorFontURLs"] as? [String],
                       let url = urls.first,
                       let font = url.components(separatedBy: " -- ").first {
                        components += [font]
                    }
                    let description = components.joined(separator: " -- ")
                    print(description)
                }
            }
            return true
        }
    }
}
