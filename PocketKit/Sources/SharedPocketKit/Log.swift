// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
import Foundation
import Sentry

/**
 This file was inspired by https://medium.com/@sauvik_dolui/developing-a-tiny-logger-in-swift-7221751628e6

 Utility struct to assist with singleton style logging in the app.
 This should be the main entry point to log any data in the app.
 */
public class Log {
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS"
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }

    private static var isLoggingEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    public enum Level: String {
        case verbose = "[🔬]" // verbose
        case debug = "[💬]" // debug
        case info = "[ℹ️]" // info
        case warning = "[⚠️]" // warning
        case error = "[‼️]" // error
        case fatal = "[🔥]" // fatal
    }

    // MARK: - Loging methods

    /// Logs error messages on console with prefix [‼️]
    ///
    /// Only used internally by our Capture error method.
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    private class func error( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(Level.error.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Logs info messages on console with prefix [ℹ️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func info( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(Level.info.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Logs debug messages on console with prefix [💬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func debug( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(Level.debug.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Logs messages verbosely on console with prefix [🔬]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    class func verbose( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(Level.verbose.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Logs warnings verbosely on console with prefix [⚠️]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func warning( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(Level.warning.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Logs fatal events on console with prefix [🔥]
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func fatal( _ object: Any, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(Level.fatal.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcName) -> \(object)")
        }
    }

    /// Catch all logging function that takes a level
    ///
    /// - Parameters:
    ///   - object: Object or message to be logged
    ///   - level: The level of the log
    ///   - filename: File name from where loggin to be done
    ///   - line: Line number in file from where the logging is done
    ///   - column: Column number of the log message
    ///   - funcName: Name of the function from where the logging is done
    public class func log( _ object: Any, level: Level = .info, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        switch level {
        case .verbose:
            Log.verbose(object, filename: filename, line: line, column: column, funcName: funcName)
        case .debug:
            Log.debug(object, filename: filename, line: line, column: column, funcName: funcName)
        case .info:
            Log.info(object, filename: filename, line: line, column: column, funcName: funcName)
        case .warning:
            Log.warning(object, filename: filename, line: line, column: column, funcName: funcName)
        case .error:
            Log.error(object, filename: filename, line: line, column: column, funcName: funcName)
        case .fatal:
            Log.fatal(object, filename: filename, line: line, column: column, funcName: funcName)
        }
    }

    /// Extract the file name from the file path
    ///
    /// - Parameter filePath: Full file path in bundle
    /// - Returns: File Name with extension
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }

    /**
     Captures an error and sends it to all relevant logging tools.
     
     - Parameters:
        - error: The error to capture
     */
    public class func capture(error: Error, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        Log.sentryCapture(error: error)
        Log.error("\(error)", filename: filename, line: line, column: column, funcName: funcName)
    }

    /**
     Captures a general message and sends it to all relevant logging tools.
     
     - Parameters:
        - message: The message to send to tooling
     */
    public class func capture(message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        Log.sentryCapture(message: message)
        Log.warning(message, filename: filename, line: line, column: column, funcName: funcName)
    }

    /**
     Captures a general message and sends it to all relevant logging tools.

     - Parameters:
        - message: The message to send to tooling
     */
    public class func captureUserFeedback(message: String, name: String, email: String, comments: String) {
        Log.sentryCaptureUserFeedback(message: message, name: name, email: email, comments: comments)
    }

    /// Helper function to capture an error that a statement tried to execute with a weak self.
    public class func captureNilWeakSelf(filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        Log.capture(message: "Nil weak self, this should not happen", filename: filename, line: line, column: column, funcName: funcName)
    }
}

/// Wrapping Swift.print() within DEBUG flag
///
/// - Note: *print()* might cause [security vulnerabilities](https://codifiedsecurity.com/mobile-app-security-testing-checklist-ios/)
///
/// - Parameter object: The object which is to be logged
///
func print(_ object: Any) {
    // Only allowing in DEBUG mode
    #if DEBUG
    Swift.print(object)
    #endif
}

internal extension Date {
    func toString() -> String {
        return Log.dateFormatter.string(from: self as Date)
    }
}

extension Log.Level {
    func toSentry() -> UInt {
        switch self {
        case .debug:
            return 1
        case .info:
            return 2
        case .warning:
            return 3
        case .error:
            return 4
        case .fatal:
            return 5
        case .verbose:
            return 1 // Sentry does not have a verbose level, so we return same as debug.
        }
    }
}

/**
 Extension for Sentry
 */
extension Log {
    /**
     Start up sentry using the provided DSN Key
     
     - Parameters:
        - dsn: The sentry secret
     */
    public class func start(dsn: String, tracesSampler: Sentry.SentryTracesSamplerCallback? = nil, profilesSampler: Sentry.SentryTracesSamplerCallback? = nil) {
        if isRunningTests() {
            // We are in a test environment, lets not init sentry.
            return
        }

        SentrySDK.start { options in
            options.dsn = dsn
            #if DEBUG
            options.environment = "development"
            #else
            options.environment = "production"
            #endif
            options.enableAutoSessionTracking = true
            options.tracesSampler = tracesSampler
            options.profilesSampler = profilesSampler
        }
    }

    public class func setUserID(_ userID: String) {
        SentrySDK.setUser(Sentry.User(userId: userID))
    }

    /**
     Clears any set user data from our logger
     */
    public class func clearUser() {
        SentrySDK.setUser(nil)
    }

    /**
     Captures an error and sends it to sentry.
     
     - Parameters:
        - error: The error to capture
     */
    internal class func sentryCapture(error: Error) {
        SentrySDK.capture(error: error)
    }

    /**
     Captures a general message and sends it to sentry
     
     - Parameters:
        - message: The message to send to tooling
     */
    internal class func sentryCapture(message: String) {
        SentrySDK.capture(message: message)
    }

    /**
     Captures a user feedback and sends it to sentry.

     - Parameters:
        - message: The message that is used to create an eventId to be able to associate the user feedback to the corresponding event
        - name: The name of the user
        - email: The email of the user
        - comments: The comments provided by the user
     */
    internal class func sentryCaptureUserFeedback(message: String, name: String, email: String, comments: String) {
        let eventId = SentrySDK.capture(message: message)
        let userFeedback = UserFeedback(eventId: eventId)
        userFeedback.name = name
        userFeedback.email = email
        userFeedback.comments = comments
        SentrySDK.capture(userFeedback: userFeedback)
    }

    /**
     Log a breadcrumb that could be used to
     - Parameters:
        - category: The tag to associate the breadcrumb with, this is a searchable filter in Sentry
        - level: The level to log at
        - message: The message to show in the sentry console
     */
    public class func breadcrumb(category: String, level: Level, message: String, filename: String = #file, line: Int = #line, column: Int = #column, funcName: String = #function) {
        let crumb = Breadcrumb()
        crumb.category = category
        crumb.level = SentryLevel(rawValue: level.toSentry()) ?? .none
        crumb.message = message

        SentrySDK.addBreadcrumb(crumb)
        Log.log("Sentry - \(category): \(message)", level: level, filename: filename, line: line, column: column, funcName: funcName)
    }

    /**
     Utility to determine if we are in a test environment.
     */
    public class func isRunningTests() -> Bool {
        let env: [String: String] = ProcessInfo.processInfo.environment
        return env["XCInjectBundleInto"] != nil
    }
}
