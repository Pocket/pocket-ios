// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Analytics
import Sync
import CoreData
import SharedPocketKit

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
    private let resultsController: NSFetchedResultsController<CDFeatureFlag>
    private let braze: BrazeProtocol
    private var featureFlags: [CurrentFeatureFlags: InMemoryFeatureFlag] = [:]

    init(source: Source, tracker: Tracker, userDefaults: UserDefaults, braze: BrazeProtocol) {
        self.source = source
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.resultsController = source.makeFeatureFlagsController()
        self.braze = braze

        super.init()

        resultsController.delegate = self
        try? resultsController.performFetch()
    }

    var shouldDisableReader: Bool {
        isAssigned(flag: .disableReader) || userDefaults.bool(forKey: UserDefaults.Key.toggleOriginalView)
    }

    /// Determine if a user is assigned to a test and a variant.
    func isAssigned(flag: CurrentFeatureFlags, variant: String?) -> Bool {
        func isAssignedViaUnleash(flag: CurrentFeatureFlags, variant: String?) -> Bool {
            guard let cachedFlag = featureFlags[flag] else {
                return false
            }

            let flagVariant = cachedFlag.variant ?? "control"
            return cachedFlag.assigned && flagVariant == variant
        }

        func isEnabledViaBraze(flag: CurrentFeatureFlags) -> Bool {
            return braze.isFeatureFlagEnabled(id: flag.rawValue)
        }

        return isAssignedViaUnleash(flag: flag, variant: variant) || isEnabledViaBraze(flag: flag)
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

        // First attempt to log the feature flag via Braze; when false, log via tracker
        let brazeLogged = braze.logFeatureFlagImpression(id: flag.rawValue)
        if brazeLogged == false {
            tracker.track(event: Events.FeatureFlag.FeatureFlagFelt(name: flag.rawValue, variant: variant))
        }
    }
}

extension FeatureFlagService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let flags = controller.fetchedObjects?.compactMap { $0 as? CDFeatureFlag } ?? []
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

/// A variation of FeatureFlag that is to be used in-memory.
/// This struct is private as to remain used only within the context of FeatureFlagService.
private struct InMemoryFeatureFlag {
    let assigned: Bool
    let name: String?
    let payloadValue: String?
    let variant: String?

    init(featureFlag: CDFeatureFlag) {
        assigned = featureFlag.assigned
        name = featureFlag.name
        payloadValue = featureFlag.payloadValue
        variant = featureFlag.variant
    }
}
