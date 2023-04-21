// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker
import SharedPocketKit
import Foundation

public class PocketSnowplowTracker: SnowplowTracker {
    private let tracker: TrackerController

    private var persistentEntities: [Entity] = []
    private var persistentFeatureEntities: [FeatureFlagEntity] = []

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
        trackerConfiguration.sessionContext = false
        trackerConfiguration.screenContext = true
        trackerConfiguration.screenViewAutotracking = true
        trackerConfiguration.lifecycleAutotracking = false
        trackerConfiguration.installAutotracking = false
        trackerConfiguration.exceptionAutotracking = false
        trackerConfiguration.diagnosticAutotracking = false

        let optionalTracker = Snowplow.createTracker(
            namespace: appID,
            network: networkConfiguration,
            configurations: [trackerConfiguration]
        )

        guard let optionalTracker else {
            fatalError("snowplow tracker did not inititalize")
        }

        tracker = optionalTracker
        _ = Snowplow.setAsDefault(tracker: tracker)

        #if DEBUG || DEBUG_ALPHA_NEUE
        // We are using a debug build, emit analytics instantly for testing instead of batches
        tracker.emitter?.bufferOption = .single
        #endif

        _ = tracker.globalContexts?.add(tag: "persistent-entities", contextGenerator: GlobalContext(generator: {  event in
            return self.persistentEntities.map({ $0.toSelfDescribingJson() })
        }))

        _ = tracker.globalContexts?.add(tag: "persistent-feature-entities", contextGenerator: GlobalContext(generator: {  event in
            return self.persistentFeatureEntities.map({ $0.toSelfDescribingJson() })
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

    public func resetPersistentFeatureEntities(_ entities: [FeatureFlagEntity]) {
        persistentFeatureEntities = entities
    }

    public func track(event: SelfDescribing) {
        tracker.track(event)
    }
}
