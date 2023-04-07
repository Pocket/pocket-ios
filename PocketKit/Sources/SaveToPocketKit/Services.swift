import Foundation
import Sync
import SharedPocketKit
import Combine
import Analytics

struct Services {
    static let shared = Services()

    let appSession: AppSession
    let saveService: PocketSaveService
    let tracker: Tracker
    let userDefaults: UserDefaults

    private let persistentContainer: PersistentContainer

    private init() {
        Log.start(dsn: Keys.shared.sentryDSN)

        guard let sharedUserDefaults = UserDefaults(suiteName: Keys.shared.groupdId) else {
            fatalError("UserDefaults with suite name \(Keys.shared.groupdId) must exist.")
        }
        userDefaults = sharedUserDefaults

        persistentContainer = .init(storage: .shared, groupID: Keys.shared.groupdId)

        appSession = AppSession(groupID: Keys.shared.groupdId)

        let snowplow = PocketSnowplowTracker()
        tracker = PocketTracker(snowplow: snowplow)

        saveService = PocketSaveService(
            space: persistentContainer.rootSpace,
            sessionProvider: appSession,
            consumerKey: Keys.shared.pocketApiConsumerKey,
            expiringActivityPerformer: ProcessInfo.processInfo
        )
    }
}
