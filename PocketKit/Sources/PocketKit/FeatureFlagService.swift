//
//  File.swift
//  
//
//  Created by Daniel Brooks on 11/22/22.
//

import Foundation
import Analytics
import Sync

class FeatureFlagService {
    private let source: Source
    private let tracker: Tracker

    init(source: Source, tracker: Tracker) {
        self.source = source
        self.tracker = tracker
    }

    /**
     Determine if a user is assigned to a test and a variant.
     */
    func isAssigned(flag: String, variant: String = "control") -> Bool {
        guard let flag = source.fetchFeatureFlag(byName: flag) else {
            //If we have no flag, the user is not assigned
            return false
        }
        let flagVariant = flag.variant ?? "control"

        return flag.assigned && flagVariant == variant
    }


    /**
     Only call this track feature when the User has felt the change of the feature flag, not before.
     */
    func trackFeatureFlagFelt(flag: String, variant: String = "control")  {
        // TODO: Call analytics with the feature flag enroll event
    }

}
