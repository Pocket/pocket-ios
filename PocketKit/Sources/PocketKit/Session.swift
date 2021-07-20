// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI


class Session {
    static let guidKey = "Session.guid"
    static let userIDKey = "Session.userID"
    
    @AppStorage
    var guid: String?
    
    @AppStorage
    var userID: String?
    
    init(userDefaults: UserDefaults) {
        _guid = AppStorage(Self.guidKey,store: userDefaults)
        _userID = AppStorage(Self.userIDKey, store: userDefaults)
    }
}
