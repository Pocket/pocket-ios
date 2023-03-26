//
//  File.swift
//  
//
//  Created by Daniel Brooks on 3/25/23.
//

import Foundation
import PKTListen
import Sync
import Kingfisher

class ListenRuntime: PKTAbstractRuntime {
    static let sharedRuntime = ListenRuntime()

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
        PKTSharedKeyStore()
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
        PKTCoreLogging.localRuntime.imageCache?.isDisabled = false
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
