// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SharedPocketKit
import WidgetKit
import Analytics

/// Handles analytics tracking for users current widgets
public struct WidgetTracker {
    private let defaults: UserDefaults?
    private let tracker: Tracker

    public var widgetsDetails: [String] {
        defaults?.object(forKey: .widgetsDetails) as? [String] ?? []
    }

    public init(defaults: UserDefaults?) {
        self.defaults = defaults
        // TODO: Inject PocketTracker
        let snowplow = PocketSnowplowTracker()
        self.tracker = PocketTracker(snowplow: snowplow)
    }

    // Retrieves current widget configurations for tracking
    public func getWidgetConfigurations() {
        WidgetCenter.shared.getCurrentConfigurations { widgetInfo in
            if let widgets = try? widgetInfo.get() {
                let details = widgets.compactMap { $0.kind + " " + $0.family.description }
                guard details != widgetsDetails else { return }

                // TODO: This only considers the count and not necessarily the type of widgets
                if details.count < widgetsDetails.count {
                    trackWidgetUninstalls(with: details)
                } else {
                    trackWidgetInstalls(with: details)
                }
                defaults?.setValue(details, forKey: .widgetsDetails)
            }
        }
    }

    private func trackWidgetInstalls(with details: [String]) {
        tracker.track(event: Events.Widget.widgetInstallEngagement(details: details))
    }

    private func trackWidgetUninstalls(with details: [String]) {
        tracker.track(event: Events.Widget.widgetsRemoveEngagement(details: details))
    }
}
