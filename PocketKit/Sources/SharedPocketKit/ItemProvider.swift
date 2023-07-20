// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation


/// Similar to NSItemProvider, simplified: an item provider for conveying data from a host app to an app extension.
public protocol ItemProvider {

    /// Similar to NSItemProvider: returns a Boolean value indicating whether an item provider contains a data
    ///  representation conforming to a specified universal type identifier file options parameter with a value of zero.
    ///  For our use-case, this should return true for public.plain-text, or public.url.
    /// - Parameter typeIdentifier: Similar to NSItemProvider: a string that represents the desired UTI.
    /// - Returns: For our use-case, implementations of this protocol
    /// should return true for public.plain-text, or public.url.
    func hasItemConformingToTypeIdentifier(_ typeIdentifier: String) -> Bool


    /// Similar to NSItemProvider: loads the item’s data and coerces it to the specified type.
    /// - Parameters:
    ///   - typeIdentifier: Similar to NSItemProvider: a string that represents the desired UTI.
    ///   - options: For our use-case, this is unused.
    /// - Returns: An object represented by `typeIdentifier`; for our use-case, this should be a `String`
    /// for `public.plain-text`, or a `URL` for `public.url`.
    func loadItem(
        forTypeIdentifier typeIdentifier: String,
        options: [AnyHashable: Any]?
    ) async throws -> NSSecureCoding
}

extension NSItemProvider: ItemProvider { }
