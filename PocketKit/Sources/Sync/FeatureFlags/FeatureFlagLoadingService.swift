import Apollo
import Foundation
import CoreData
import PocketGraph
import SharedPocketKit

protocol FeatureFlagLoadingService {
    func fetchFeatureFlags() async throws
}

public typealias RemoteFeatureFlagAssignment = UnleashAssignmentsQuery.Data.Assignments.Assignment

class APIFeatureFlagService: FeatureFlagLoadingService {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let user: User
    private let sessionProvider: SessionProvider

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        user: User,
        sessionProvider: SessionProvider
    ) {
        self.apollo = apollo
        self.space = space
        self.user = user
        self.sessionProvider = sessionProvider
    }

    func fetchFeatureFlags() async throws {

        var context =  UnleashContext(appName: "pocket-ios", userId: user.getId() ?? .none, sessionId: sessionProvider.session?.guid ?? .none)

        let query = UnleashAssignmentsQuery(context: context)

        guard let remoteAssignments = try await apollo.fetch(query: query).data?.assignments?.assignments else {
            return
        }

        try await handle(remoteAssignments: remoteAssignments.map({ remoteAssignment in
            // the ! is a bug in our graphql schema we need to update.
            return remoteAssignment!
        }))
    }

    @MainActor
    private func handle(remoteAssignments: [RemoteFeatureFlagAssignment]) throws {
        let oldFlags = try space.fetchFeatureFlags()

        for remoteAssignment in remoteAssignments {
            let assignment = try space.fetchFeatureFlag(byName: remoteAssignment.name) ?? space.new()
            assignment.update(from: remoteAssignment)
        }

        // TODO: delete feature flags no longer present

        try space.save()

    }
}
