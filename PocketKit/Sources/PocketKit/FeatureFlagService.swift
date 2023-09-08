// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Analytics
import Sync
import CoreData

protocol FeatureFlagServiceProtocol {
    /// Determine if a user is assigned to a test and a variant.
    func isAssigned(flag: CurrentFeatureFlags, variant: String?) -> Bool

    /// Only call this track feature when the User has felt the change of the feature flag, not before.
    func trackFeatureFlagFelt(flag: CurrentFeatureFlags, variant: String?)

    func getPayload(flag: CurrentFeatureFlags) -> String?

    var shouldDisableReader: Bool { get }
}

/// Extension for default values https://medium.com/@georgetsifrikas/swift-protocols-with-default-values-b7278d3eef22
extension FeatureFlagServiceProtocol {
    func isAssigned(flag: CurrentFeatureFlags, variant: String? = "control") -> Bool {
        return isAssigned(flag: flag, variant: variant)
    }

    func trackFeatureFlagFelt(flag: CurrentFeatureFlags, variant: String? = "control") {
        return trackFeatureFlagFelt(flag: flag, variant: variant)
    }
}

/// Used to interact with the feature flags stored in our core data store
class FeatureFlagService: NSObject, FeatureFlagServiceProtocol {
    private let source: Source
    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let resultsController: NSFetchedResultsController<FeatureFlag>
    private var featureFlags: [CurrentFeatureFlags: InMemoryFeatureFlag] = [:]

    init(source: Source, tracker: Tracker, userDefaults: UserDefaults) {
        self.source = source
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.resultsController = source.makeFeatureFlagsController()

        super.init()

        resultsController.delegate = self
        try? resultsController.performFetch()
    }

    var shouldDisableReader: Bool {
        isAssigned(flag: .disableReader) || userDefaults.bool(forKey: UserDefaults.Key.toggleOriginalView)
    }

    /// Determine if a user is assigned to a test and a variant.
    func isAssigned(flag: CurrentFeatureFlags, variant: String?) -> Bool {
        guard let cachedFlag = featureFlags[flag] else {
            return false
        }

        let flagVariant = cachedFlag.variant ?? "control"
        return cachedFlag.assigned && flagVariant == variant
    }

    func getPayload(flag: CurrentFeatureFlags) -> String? {
        guard let cachedFlag = featureFlags[flag] else {
            return nil
        }

        return cachedFlag.payloadValue
    }

    /// Only call this track feature when the User has felt the change of the feature flag, not before.
    func trackFeatureFlagFelt(flag: CurrentFeatureFlags, variant: String?) {
        guard let variant else {
            // No variant value so we can't do anything
            return
        }
        tracker.track(event: Events.FeatureFlag.FeatureFlagFelt(name: flag.rawValue, variant: variant))
    }
}

extension FeatureFlagService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let flags = controller.fetchedObjects?.compactMap { $0 as? FeatureFlag } ?? []
        guard flags.isEmpty == false else {
            return
        }

        // Reset and update our feature flags with the latest in Core Data.
        // Here, "latest" should be after the last refresh of feature flags from the server.
        // In-memory representations of the fetched feature flags will be cached for O(1) retrieval
        // as needed. In-memory caching is used since our use of Sentry seems to force-fetching on the main thread
        // when requesting tracing / profiling rates (since we check by feature flag whether to be included
        // in sampling. By moving to in-memory-only, we remove the use of Core Data,
        // where we do not want to be fetching from the main thread, especially while
        // doing something like the initial sync, where large amounts of data are being added / updated.
        featureFlags = [:]
        for f in flags {
            guard let name = f.name, let current = CurrentFeatureFlags(rawValue: name) else {
                continue
            }

            featureFlags[current] = InMemoryFeatureFlag(featureFlag: f)
        }
    }
}

/// Describes the current feature flags that iOS cares about
public enum CurrentFeatureFlags: String, CaseIterable {
    case debugMenu = "perm.ios.debug.menu"
    case traceSampling = "perm.ios.sentry.traces"
    case profileSampling = "perm.ios.sentry.profile"
    case reportIssue = "perm.ios.report_issue"
    case disableReader = "perm.ios.disable_reader"
    case nativeCollections = "perm.ios.native_collections"

    /// Description to use in a debug menu
    var description: String {
        switch self {
        case .debugMenu:
            return "Debug menu for iOS"
        case .traceSampling:
            return "Percentage to use to sample traces in Sentry"
        case .profileSampling:
            return "Percentage to use to sample profiles in Sentry"
        case .reportIssue:
            return "Enable the Report an Issue feature when users encounter an error"
        case .disableReader:
            return "Disable the Reader to force use of a Web view for viewing content"
        case .nativeCollections:
            return "Enable native collections instead of opening collections in web view"
        }
    }
}

/// A variation of FeatureFlag that is to be used in-memory.
/// This struct is private as to remain used only within the context of FeatureFlagService.
private struct InMemoryFeatureFlag {
    let assigned: Bool
    let name: String?
    let payloadValue: String?
    let variant: String?

    init(featureFlag: FeatureFlag) {
        assigned = featureFlag.assigned
        name = featureFlag.name
        payloadValue = featureFlag.payloadValue
        variant = featureFlag.variant
    }
}
