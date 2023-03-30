//
//  File.swift
//  
//
//  Created by David Skuza on 3/30/23.
//

import Foundation

/// Defines a type that can be logged with `Log`
public protocol LoggableError: CustomNSError {
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
}
