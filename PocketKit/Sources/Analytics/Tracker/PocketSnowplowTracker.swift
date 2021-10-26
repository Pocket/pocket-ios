// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SnowplowTracker


public class PocketSnowplowTracker: SnowplowTracker {
    private let tracker: TrackerController
    
    public init() {
        let endpoint = ProcessInfo.processInfo.environment["SNOWPLOW_ENDPOINT"] ?? "d.getpocket.com"
        let appID = ProcessInfo.processInfo.environment["SNOWPLOW_IDENTIFIER"] ?? "pocket-ios-next"
       
        let networkConfiguration = NetworkConfiguration(endpoint: endpoint, method: .post)
        
        let trackerConfiguration = TrackerConfiguration()
        trackerConfiguration.appId = appID
        trackerConfiguration.devicePlatform = .mobile
        trackerConfiguration.base64Encoding = false
        trackerConfiguration.logLevel = .off
        trackerConfiguration.applicationContext = false
        trackerConfiguration.platformContext = false
        trackerConfiguration.geoLocationContext = false
        trackerConfiguration.sessionContext = false
        trackerConfiguration.screenContext = false
        trackerConfiguration.screenViewAutotracking = false
        trackerConfiguration.lifecycleAutotracking = false
        trackerConfiguration.installAutotracking = false
        trackerConfiguration.exceptionAutotracking = false
        trackerConfiguration.diagnosticAutotracking = false
        
        tracker = Snowplow.createTracker(
            namespace: appID,
            network: networkConfiguration,
            configurations: [trackerConfiguration]
        )
        
        if CommandLine.arguments.contains("disableSnowplow") {
            tracker.pause()
        }
    }
    
    public func track(event: SelfDescribing) {
        tracker.track(event)
    }
}
