import Apollo
import SharedPocketKit
import Foundation
import CoreData
import PocketGraph

protocol UserService {
    func fetchUser() async throws
}

class APIUserService: UserService {
    private let apollo: ApolloClientProtocol
    private let space: Space
    private let user: User

    init(
        apollo: ApolloClientProtocol,
        space: Space,
        user: User
    ) {
        self.apollo = apollo
        self.space = space
        self.user = user
    }

    func fetchUser() async throws {
        let query = GetUserDataQuery()

        guard let remote = try await apollo.fetch(query: query).data?.user else {
            Log.capture(message: "Error getting user data")
            return
        }

        try fetchRemoteUser(remote: remote)
    }

    private func fetchRemoteUser(remote: GetUserDataQuery.Data.User) throws {
        space.performAndWait {
            guard let remoteIsPremium = remote.isPremium, let remoteUserName = remote.name else {
                return
            }
            user.setPremiumStatus(remoteIsPremium)
            user.setUserName(remoteUserName)

            if let remoteDisplayName = remote.username {
                user.setDisplayName(remoteDisplayName)
            } else {
                Log.capture(message: "No display name data")
            }
        }
        try space.save()
    }
}
