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
    let firstLaunchDefaults: UserDefaults

    private let persistentContainer: PersistentContainer

    private init() {
        Log.start(dsn: Keys.shared.sentryDSN)

        firstLaunchDefaults = UserDefaults(
            suiteName: "\(Bundle.main.bundleIdentifier!).first-launch"
        )!
        persistentContainer = .init(storage: .shared, userDefaults: firstLaunchDefaults, groupId: Keys.shared.groupdId)

        appSession = AppSession(groupId: Keys.shared.groupdId)

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
