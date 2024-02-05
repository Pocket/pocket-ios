// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker
import SharedPocketKit
import Foundation

public class PocketSnowplowTracker: SnowplowTracker {
    private let tracker: TrackerController

    private var persistentEntities: [Entity] = []

    public init() {
        let endpoint = ProcessInfo.processInfo.environment["SNOWPLOW_ENDPOINT"] ?? "getpocket.com"
        let appID = ProcessInfo.processInfo.environment["SNOWPLOW_IDENTIFIER"] ?? "pocket-ios-next"
        let postPath = ProcessInfo.processInfo.environment["SNOWPLOW_POST_PATH"] ?? "t/e"

        let networkConfiguration = NetworkConfiguration(endpoint: endpoint, method: .post)
        networkConfiguration.customPostPath = postPath

        let trackerConfiguration = TrackerConfiguration()
        trackerConfiguration.appId = appID
        trackerConfiguration.devicePlatform = .mobile
        trackerConfiguration.base64Encoding = false
        trackerConfiguration.logLevel = .off
        trackerConfiguration.applicationContext = true
        trackerConfiguration.platformContext = true
        trackerConfiguration.geoLocationContext = false
        trackerConfiguration.sessionContext = true
        trackerConfiguration.screenContext = true
        trackerConfiguration.deepLinkContext = true
        trackerConfiguration.screenViewAutotracking = true
        trackerConfiguration.lifecycleAutotracking = true
        trackerConfiguration.installAutotracking = true
        trackerConfiguration.exceptionAutotracking = false
        trackerConfiguration.diagnosticAutotracking = false
        trackerConfiguration.platformContextProperties = [
            .batteryState,
            .isPortrait,
            .language,
            .lowPowerMode,
            .networkTechnology,
            .networkType,
            .resolution,
            .scale
        ]

        if ProcessInfo.processInfo.isiOSAppOnMac {
            trackerConfiguration.devicePlatform = .desktop
            trackerConfiguration.appId = "pocket-mac-next"
        }

        let optionalTracker = Snowplow.createTracker(
            namespace: appID,
            network: networkConfiguration,
            configurations: [trackerConfiguration]
        )

        tracker = optionalTracker
        _ = Snowplow.setAsDefault(tracker: tracker)

        #if DEBUG || DEBUG_ALPHA_NEUE
        // We are using a debug build, emit analytics instantly for testing instead of batches
        tracker.emitter?.bufferOption = .single
        #endif

        _ = tracker.globalContexts?.add(tag: "persistent-entities", contextGenerator: GlobalContext(generator: {  event in
            return self.persistentEntities.map({ $0.toSelfDescribingJson() })
        }))

        if CommandLine.arguments.contains("disableSnowplow") {
            tracker.pause()
        }
    }

    public func addPersistentEntity(_ entity: Entity) {
        persistentEntities.append(entity)
    }

    public func resetPersistentEntities(_ entities: [Entity]) {
        persistentEntities = entities
    }

    public func track(event: SelfDescribing) {
        tracker.track(event)
    }
}
