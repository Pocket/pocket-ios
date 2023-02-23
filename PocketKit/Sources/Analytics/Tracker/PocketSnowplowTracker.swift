// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker

public class PocketSnowplowTracker: SnowplowTracker {
    private let tracker: TrackerController

    private var persistentEntities: [Entity] = []

    public init() {
        let endpoint = ProcessInfo.processInfo.environment["SNOWPLOW_ENDPOINT"] ?? "d.getpocket.com"
        let appID = ProcessInfo.processInfo.environment["SNOWPLOW_IDENTIFIER"] ?? "pocket-ios-next"

        let networkConfiguration = NetworkConfiguration(endpoint: endpoint, method: .post)

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

        tracker = Snowplow.createTracker(
            namespace: appID,
            network: networkConfiguration,
            configurations: [trackerConfiguration]
        )

        tracker.globalContexts.add(tag: "persistent-entities", contextGenerator: GlobalContext(generator: {  event in
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
