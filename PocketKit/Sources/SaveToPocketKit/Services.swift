import Foundation
import Sync
import SharedPocketKit

struct Services {
    static let shared = Services()

    let appSession: AppSession
    let saveService: PocketSaveService

    private let persistentContainer: PersistentContainer

    private init() {
        persistentContainer = .init(storage: .shared)

        appSession = AppSession()
        saveService = PocketSaveService(
            space: persistentContainer.rootSpace,
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            expiringActivityPerformer: ProcessInfo.processInfo
        )
    }
}
