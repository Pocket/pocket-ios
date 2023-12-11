// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import XCTest
import BackgroundTasks

@testable import Sync
@testable import PocketKit
import SharedPocketKit

class SharedWithYouManagerTests: XCTestCase {
    var source: MockSource!
    var appSession: AppSession!
    var highlightCenter: MockSWHighlightCenter!

    override func setUp() {
        source = MockSource()
        source.stubSaveNewSharedWithYouSnapshot { _ in }
        appSession = AppSession(keychain: MockKeychain(), groupID: "groupId")
        appSession.currentSession = SharedPocketKit.Session(guid: "test-guid", accessToken: "test-access-token", userIdentifier: "test-id")
        highlightCenter = MockSWHighlightCenter()
    }

    func subject(
        source: Source? = nil,
        appSession: AppSession? = nil,
        highlightCenter: SWHighlightCenterProtocol? = nil
    ) -> SharedWithYouManager {
        SharedWithYouManager(
            source: source ?? self.source,
            appSession: appSession ?? self.appSession,
            highlightCenter: highlightCenter ?? self.highlightCenter
        )
    }

    func test_sharedWithYouManager_whenNoSession_resetsSnapshotTo0() {
        let sharedWithYouManager = subject(appSession: AppSession(groupID: ""))
        let call = source.saveNewSharedWithYouSnapshotCall(at: 0)
        XCTAssertEqual(call?.sharedWithYouHighlights, [])
    }

    func test_sharedWithYouManager_whenSession_andNoHighlights_resetsSnapshotTo0() {
        let sharedWithYouManager = subject()
        let call = source.saveNewSharedWithYouSnapshotCall(at: 0)
        XCTAssertEqual(call?.sharedWithYouHighlights, [])
    }
}
