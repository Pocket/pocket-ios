// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SharedPocketKit

enum URLExtractor {
    static func url(from itemProvider: ItemProvider) async -> String? {
        if itemProvider.hasItemConformingToTypeIdentifier("public.url") { // We're handed a URL
            guard let url = try? await itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) as? URL else {
                Log.capture(message: "Unable to load URL from itemProvider")
                return nil
            }

            return firstURL(in: url)
        } else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-text") { // We're handed a URL String
            guard let string = try? await itemProvider.loadItem(forTypeIdentifier: "public.plain-text", options: nil) as? String else {
                Log.capture(message: "Unable to load String from itemProvider")
                return nil
            }

            if let firstURL = firstURL(in: string), let url = URL(string: firstURL) {
                return self.firstURL(in: url)
            }

            Log.capture(message: "Unable to parse URL from from itemProvider String")
            return nil
        }

        return nil
    }

    private static func isValidScheme(_ scheme: String) -> Bool {
        let validSchemes = ["http", "https", "file", "ftp"]
        return validSchemes.contains(scheme)
    }

    /// Returns the first URL found within a String, if one exists. Otherwise, nil. See Discussion
    /// for example string arguments and their outputs.
    ///
    /// Example: "https://getpocket.com" -> "https://getpocket.com"
    ///
    /// Example: "foo=bar&url=https://getpocket.com" -> "https://getpocket.com"
    ///
    /// Example: "foo=bar" -> nil
    /// - Parameters:
    ///     - string: The string from which to search for a URL
    private static func firstURL(in string: String) -> String? {
        guard let string = string.removingPercentEncoding, let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            Log.capture(message: "FirstURL setup failed")
            return nil
        }

        let matches = detector.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: string) else { continue }
            let string = String(string[range])
            return string
        }

        Log.breadcrumb(category: "urlExtractor", level: .warning, message: "Unable to find URL in \(string)")
        return nil
    }

    /// Returns the first URL found within a URL, if one exists. Otherwise, nil.
    ///
    /// This is an overloaded function complementing firstURL(in:) that accepts a String.
    /// This function will first check if the URL is one of [http, https, file, ftp]
    /// and return the URL if so, otherwise the URL is "invalid". If invalid, the URL
    /// will return the result of calling firstURL(in:) with the absolute string of the remaining URL.
    ///
    /// An example of an "invalid" URL from which a link should attempt to be extracted from
    /// is something akin to "com.mozilla.pocket://save?url=https://getpocket.com", which would
    /// return "https://getpocket.com" as the URL.
    ///
    /// - Parameters:
    ///     - string: The string from which to search for a URL
    private static func firstURL(in url: URL) -> String? {
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            Log.capture(message: "Unable to generate URLComponents")
            return nil
        }

        // If the scheme is one of: http, https, file, ftp, return the original URL,
        // else, validly mangle the original (by removing the original scheme) to attempt to extract a new URL from
        if let scheme = urlComponents.scheme, isValidScheme(scheme) == true {
            return url.absoluteString
        }

        // Hacky way of removing the original scheme so that the first link present in its full path / query items
        // can be used as the URL to save
        urlComponents.scheme = nil

        guard let inputString = urlComponents.string else {
            Log.capture(message: "Unable to read URLComponents as String")
            return nil
        }

        return firstURL(in: inputString)
    }
}
