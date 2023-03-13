// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import SharedPocketKit
import Analytics

/// A collection of concrete types to be used in SwiftUI previews
class PreviewUserManagementService: ObservableObject, UserManagementServiceProtocol {
    func deleteAccount() async throws { }
    func logout() { }
    @Published public private(set) var accountDeleted: Bool = false
    var accountDeletedPublisher: Published<Bool>.Publisher { $accountDeleted }
}

class PreviewTracker: Tracker {
    func childTracker(with contexts: [Analytics.Context]) -> Analytics.Tracker { return self }
    func track<T>(event: T, _ contexts: [Analytics.Context]?) where T: Analytics.OldEvent {}
    func addPersistentEntity(_ entity: Analytics.Entity) {}
    func resetPersistentEntities(_ entities: [Analytics.Entity]) {}
    func track(event: Event, filename: String, line: Int, column: Int, funcName: String) {}
}
