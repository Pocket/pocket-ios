// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import WidgetKit

/// Stores session status for any widget
public protocol WidgetsSessionService {
    var isLoggedIn: Bool { get }
    func setLoggedIn(_ isLoggedIn: Bool)
}

/// A concrete implementation of `WidgetSessionService` using `UserDefaults`
public struct UserDefaultsWidgetSessionService: WidgetsSessionService {
    private let defaults: UserDefaults

    /// Current logged in status
    public var isLoggedIn: Bool {
        defaults.bool(forKey: .widgetsLoggedIn)
    }

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    /// Sets the logged in status and reloads all widgets
    /// - Parameter isLoggedIn: the logged in status to set
    public func setLoggedIn(_ isLoggedIn: Bool) {
        defaults.setValue(isLoggedIn, forKey: .widgetsLoggedIn)
        WidgetCenter.shared.reloadAllTimelines()
        WidgetCenter.shared.invalidateConfigurationRecommendations()
    }
}
