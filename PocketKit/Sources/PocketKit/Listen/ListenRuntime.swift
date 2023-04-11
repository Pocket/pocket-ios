// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import PKTListen
import Sync
import Kingfisher

/// Older Pocket runtime which configures the legacy pocket app hooks used by Listen
/// NOT USED FOR NOW.
class ListenRuntime: PKTAbstractRuntime {
    static let sharedRuntime = ListenRuntime()

    /// A Key-Value store that writes to disk storing using settings for Listen.
    /// Also contains the data needed to access and operate listen.
    lazy var pktJSONDAO: PKTKeyValueStore = {
        let listenDirectory = PKTListenSupportDataDirectoryURL(Keys.shared.groupID)
        let listen = listenDirectory.appendingPathComponent("listen-next")
        return PKTJSONDAO<NSDictionary>(fileURL: listen)
    }()

    override var apiDomain: String {
        "getpocket.com"
    }

    override var apiEndpoint: String {
        "https://getpocket.com/v3/"
    }

    override var textEndpoint: String {
        "https://text.getpocket.com/v3beta/mobile"
    }

    override var sharedUserDefaultsSuiteName: String? {
        Keys.shared.groupID
    }

    override var imageCache: PKTImageCacheManagement? {
        PKTImageCacheManager.sharedManager()
    }

    override func trackAction(withEvent event: String?) {
        Log.debug("Tracking listen action \(String(describing: event))")
    }

    override func store() -> PKTKeyValueStore {
        pktJSONDAO
    }

    override func itemSessionService() -> PKTItemSessionService? {
        ListenItemSession.sharedInstance()
    }

    override func start() {
        super.start()
        PKTBackports.sharedInstance().install()

        // Update settings
        PKTListen.updateSettings()

        // Do warm thumbnail cache
        PKTRemoteMedia.debugModeEnabled = false

        // Show visual layout lines
        PKTListen.visualizeLayout = false

        // Use experimental layout
        PKTListen.experimentalLayoutsEnabled = false

        // Do not skip played itemd
        PKTListen.automaticallySkipPlayedItems = false

        // Pop down player when list item selected
        PKTListenQueueViewController.controlExpansionEnabled = false

        // Disable the audio stream cache
        PKTListenCacheManager.isDisabled = false

        // Disable the image cache
        ListenRuntime.sharedRuntime.imageCache?.isDisabled = false
    }
}

class ListenItemSession: NSObject, PKTItemSessionService {
    static let shared = ListenItemSession()
    static func sharedInstance() -> PKTItemSessionService {
        ListenItemSession.shared
    }

    var sessionId: String = ""

    func start(withEvent event: String, item: NSObjectProtocol?, context: [AnyHashable: Any]?) -> Bool {
        true
    }

    func pause(withEvent event: String, context: [AnyHashable: Any]?) -> Bool {
        true
    }

    func resume(withEvent event: String, context: [AnyHashable: Any]?) -> Bool {
        true
    }

    func end(withEvent event: String, context: [AnyHashable: Any]?) -> Bool {
        true
    }

    func reset() {
    }

    func canResume() -> Bool {
        true
    }
}
