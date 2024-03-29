// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

private let imageCacheFilters = "/fit-in/\(Int(UIScreen.main.nativeBounds.width))x\(Int(UIScreen.main.nativeBounds.height))/filters:format(jpeg):quality(60):no_upscale():strip_exif()"

private let baseURL = URL(string: "https://pocket-image-cache.com")!

func imageCacheURL(for imageURL: URL?) -> URL? {
    let url = imageURL
        .flatMap { $0.absoluteString }
        // Need to remove percent encoding because we add it in Marticle Images
        .flatMap { $0.removingPercentEncoding }
        .flatMap { imageURLString in
            // Using a special character set that operates the same as https://www.urldecoder.org/
            // All urls should passed to the image cache should encode the same when usign that site.
            // We do not use URLPathComponents because it adds auto encoding on top of our own encoding which will casue % to be rencoded causing errors. 🤦🏻
            var allowedCharacterSet = NSCharacterSet.urlHostAllowed
            allowedCharacterSet.remove(charactersIn: ":?&")

            let path = [
                imageCacheFilters,
                imageURLString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? imageURLString
            ].joined(separator: "/")
            return URL(string: path, relativeTo: baseURL)
        }
    return url
}
