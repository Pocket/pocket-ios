// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

@preconcurrency import Apollo
import Foundation
import CoreData
import PocketGraph
@preconcurrency import SharedPocketKit

protocol FeatureFlagLoadingService: Sendable {
    func fetchFeatureFlags() async throws
}

public typealias RemoteFeatureFlagAssignment = FeatureFlagsQuery.Data.Assignments.Assignment

/// Service to grab the latest feature flags from the server
/// Main app usage should be via FeatureFlag service which loads the flags from the local database
struct APIFeatureFlagService: FeatureFlagLoadingService {
    private let apollo: ApolloClientProtocol
    nonisolated(unsafe) private let space: Space
    private let appSession: AppSession

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        appSession: AppSession
    ) {
        self.apollo = apollo
        self.space = space
        self.appSession = appSession
    }

    /// Fetches the latest feature flags from the server
    func fetchFeatureFlags() async {
        let context =  UnleashContext(appName: "pocket-ios", userId: appSession.currentSession?.userIdentifier ?? .none, sessionId: appSession.currentSession?.guid ?? .none)

        let query = FeatureFlagsQuery(context: context)

        do {
            let results = try await apollo.fetch(query: query)
            let remoteAssignments = results.data?.assignments?.assignments
            try handle(remoteAssignments: remoteAssignments?.map({ remoteAssignment in
                // the ! is a bug in our graphql schema we need to update.
                return remoteAssignment!
            }))
        } catch {
            Log.capture(error: error)
        }
    }

    /// Process the feature flags from the server and cache them in CoreData
    /// - Parameter remoteAssignments: The remote assignements from the server
    private func handle(remoteAssignments: [RemoteFeatureFlagAssignment]?) throws {
        let context = space.makeChildBackgroundContext()

        try context.performAndWait {
            // Delete all flags we have currently.

            let oldFlags = try space.fetchFeatureFlags(in: context)
            oldFlags.forEach { flag in
                space.delete(flag, in: context)
            }

            guard let remoteAssignments else {
                // save the child context
                guard context.hasChanges else {
                    return
                }
                try context.save()
                // then save the parent context
                try space.save()
                return
            }

            for remoteAssignment in remoteAssignments {
                let assignment = try space.fetchFeatureFlag(by: remoteAssignment.name, in: context) ?? FeatureFlag(context: context)
                assignment.update(from: remoteAssignment)
            }
            // save the child context
            guard context.hasChanges else {
                return
            }
            try context.save()
            // then save the parent context
            try space.save()
        }
    }
}
