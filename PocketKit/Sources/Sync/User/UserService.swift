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
    private let user: User

    init(
        apollo: ApolloClientProtocol,
        user: User
    ) {
        self.apollo = apollo
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
        guard let remoteIsPremium = remote.isPremium else {
            return
        }

        user.setPremiumStatus(remoteIsPremium)
        user.setUserName(remote.username ?? "")
        user.setDisplayName(remote.name ?? "")
    }
}
