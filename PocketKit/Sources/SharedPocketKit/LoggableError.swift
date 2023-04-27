// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Defines a type that can be logged with `Log`
/// - Note: This protocol provides a default implementation for `errorDescription`,
/// which is used to generate the `localizedDescription` for an error. The default
/// implementation returns the log description as the error description.
public protocol LoggableError: LocalizedError, CustomNSError {
    /// The description of the error that occurred.
    var logDescription: String { get }

    // The user-info of the error that occurred.
    var errorUserInfo: [String: Any] { get }
}

public extension LoggableError {
    /// Default implementation that generates the minimum required
    /// user-info to be captured via `Log`
    var errorUserInfo: [String: Any] {
        return [
            NSDebugDescriptionErrorKey: logDescription
        ]
    }

    /// Default implementation that returns the log description as the error description.
    /// This will then be returned when accessing `localizedDescription`.
    var errorDescription: String? {
        return logDescription
    }
}
