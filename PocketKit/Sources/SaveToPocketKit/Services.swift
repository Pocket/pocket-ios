import Foundation
import Sync
import SharedPocketKit
import Combine

struct Services {
    static let shared = Services()

    let appSession: AppSession
    let saveService: PocketSaveService

    private let persistentContainer: PersistentContainer
    
    private var subscriptions: Set<AnyCancellable> = []

    private init() {
        Crashlogger.start(dsn: Keys.shared.sentryDSN)
        persistentContainer = .init(storage: .shared)

        appSession = AppSession()
        
        appSession.$currentSession.sink { session in
            if let session = session {
                Crashlogger.setUserID(session.userIdentifier)
            } else {
                Crashlogger.clearUser()
            }
        }.store(in: &subscriptions)
        
        
        saveService = PocketSaveService(
            space: persistentContainer.rootSpace,
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            expiringActivityPerformer: ProcessInfo.processInfo
        )
    }
}
