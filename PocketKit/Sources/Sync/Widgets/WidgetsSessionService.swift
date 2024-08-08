// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import WidgetKit

public enum WidgetStatus: String {
    case loggedIn
    case loggedOut
    case anonymous
    case unknown
}

/// Stores session status for any widget
public protocol WidgetsSessionService {
    var status: WidgetStatus { get }
    func setStatus(_ status: WidgetStatus)
}

/// A concrete implementation of `WidgetSessionService` using `UserDefaults`
public struct UserDefaultsWidgetSessionService: WidgetsSessionService {
    private static let statusKey = "com.mozilla.pocket.widgets.status"
    public var status: WidgetStatus {
        guard let value = defaults.value(forKey: Self.statusKey) as? String else {
            return .unknown
        }
        return WidgetStatus(rawValue: value) ?? .unknown
    }

    public func setStatus(_ status: WidgetStatus) {
        defaults.setValue(status.rawValue, forKey: Self.statusKey)
    }

    private let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}
