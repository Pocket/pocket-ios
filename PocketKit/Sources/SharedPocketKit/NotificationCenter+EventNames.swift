// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

public extension Notification.Name {
    static let userLoggedIn = Notification.Name("com.mozilla.pocket.userLoggedIn")
    static let userLoggedOut = Notification.Name("com.mozilla.pocket.userLoggedOut")
    static let listUpdated = Notification.Name("com.mozilla.pocket.listUpdated")
    static let bannerRequested = Notification.Name("com.mozilla.pocket.bannerRequested")
    static let serverError = Notification.Name("com.mozilla.pocket.serverError")
    static let unauthorizedResponse = Notification.Name("com.mozilla.pocket.unauthorizedResponse")
    static let migrationError = Notification.Name("com.mozilla.pocket.migrationError")
}
