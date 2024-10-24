// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Analytics
import BackgroundTasks
import SharedPocketKit
import Adjust
import Localization
import SwiftUI

public class PocketAppDelegate: UIResponder, UIApplicationDelegate {
    static var phoneOrientationLock = UIInterfaceOrientationMask.portrait

    private let services: Services
    private let source: Source
    private let userDefaults: UserDefaults
    private let refreshCoordinators: [RefreshCoordinator]
    private let appSession: AppSession
    private let user: User
    private let brazeService: BrazeProtocol
    private let tracker: Tracker
    private let consumerKey: String
    private let subscriptionStore: SubscriptionStore
    private let notificationRelay: NotificationRelay
    private let featureFlags: FeatureFlagServiceProtocol
    private let notificationCenter: NotificationCenter
    private var appBadgeSetup: AppBadgeSetup?

    let notificationService: PushNotificationService

    convenience override init() {
        self.init(services: .shared)
    }

    init(services: Services) {
        self.services = services
        self.source = services.source
        self.userDefaults = services.userDefaults
        self.refreshCoordinators = services.refreshCoordinators
        self.appSession = services.appSession
        self.user = services.user
        self.brazeService = services.braze
        self.tracker = services.tracker
        self.subscriptionStore = services.subscriptionStore
        self.notificationRelay = NotificationRelay(services.notificationCenter)
        self.featureFlags = services.featureFlagService
        self.notificationService = services.notificationService
        self.consumerKey = Keys.shared.pocketApiConsumerKey
        self.notificationCenter = services.notificationCenter

        super.init()
    }

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        startLogging()
        processCommandLineArguments()
        setupSession()
        setupAdjust()
        setupTracker()
        initializeCoordinators()
        initializeTextile()
        startSubscriptionStore()
        setupBadge(application: application)
        return true
    }

    /// Sets orientations to use for the views
    /// - Parameters:
    ///   - application: singleton app object
    ///   - window: window whose interface orientations you want to retrieve
    /// - Returns: orientations to use for the view
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        guard UIDevice.current.userInterfaceIdiom == .phone else { return .all }
        return PocketAppDelegate.phoneOrientationLock
    }
}

// MARK: didFinishLaunching steps
extension PocketAppDelegate {
    /// Starts the `Log` engine
    private func startLogging() {
        Log.start(
            dsn: Keys.shared.sentryDSN,
            tracesSampler: { context in
                guard self.featureFlags.isAssigned(flag: .traceSampling),
                      // Get the sentry traces sample value from the feature flag
                      let sample = self.featureFlags.getPayload(flag: .traceSampling)?.numberValue else {
                    // Traces sampler is disabled or not set, so returning a 0
                    return 0.0
                }
                return sample
            },
            profilesSampler: { context in
                // NOTE: This is relative to the TracesSampler. IE. if tracesSampler responds with 100%, profilesSampler will be called 100% of the time,
                // if traces responds with 50%, profileSamples will be called 50% of the time.
                guard self.featureFlags.isAssigned(flag: .profileSampling),
                      // Get the sentry profile sample value from the feature flag
                      let sample = self.featureFlags.getPayload(flag: .profileSampling)?.numberValue else {
                    // Profiles sampler is disabled or not set, so returning a 0
                    return 0.0
                }
                return sample
            }
        )
    }

    /// Process any command line arguments (e. g. to setup the testing environment)
    private func processCommandLineArguments() {
        if CommandLine.arguments.contains("clearKeychain") {
            appSession.clearCurrentSession()
        }

        if CommandLine.arguments.contains("clearUserDefaults") {
            userDefaults.resetKeys()
        }

        if CommandLine.arguments.contains("clearCoreData") {
            source.clear()
        }

        if CommandLine.arguments.contains("clearImageCache") {
            Textiles.clearImageCache()
        }
    }

    /// Clears the session if it's the first launch, otherwise sets it up with the available environment info.
    private func setupSession() {
        SignOutOnFirstLaunch(
            appSession: appSession,
            user: user,
            userDefaults: userDefaults
        ).execute()

        if let guid = ProcessInfo.processInfo.environment["sessionGUID"],
           let accessToken = ProcessInfo.processInfo.environment["accessToken"],
           let userIdentifier = ProcessInfo.processInfo.environment["sessionUserID"] {
            let session = Session(
                guid: guid,
                accessToken: accessToken,
                userIdentifier: userIdentifier
            )
            appSession.setCurrentSession(session)
        }
    }

    /// Setup the adjust environment
    /// Note: this needs to be called early on because we attach the ad id to the UserEntity.
    private func setupAdjust() {
        let adjustAppToken = Keys.shared.adjustAppToken
        let environment = ADJEnvironmentProduction
        let adjustConfig = ADJConfig(
            appToken: adjustAppToken,
            environment: environment
        )
        Adjust.appDidLaunch(adjustConfig)
    }

    /// Setup the tracker
    private func setupTracker() {
        // Reset and attach at least an api user entity on app launch
        self.tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: self.consumerKey)
        ])

        if let currentSession = appSession.currentSession {
            // Attach a user entity at launch if it exists
            tracker.addPersistentEntity(UserEntity(guid: currentSession.guid, userID: currentSession.userIdentifier, adjustAdId: Adjust.adid()))
        }
    }

    /// Initialize `Textile`
    private func initializeTextile() {
        Textiles.initialize()
    }

    /// Initialize any `RefreshCoordinator`
    private func initializeCoordinators() {
        refreshCoordinators.forEach({ $0.initialize() })
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.source.restore()
        }
    }

    /// Start pocket premium subscriptions store
    private func startSubscriptionStore() {
        if appSession.currentSession != nil {
            // If the user is not logged in, we can start the subscription
            // in preparation for in-app purchases. Otherwise, the store
            // listens for log in / out events to appropriately start / stop.
            subscriptionStore.start()
        }
    }

    /// Setup the badge
    /// - Parameter application: the current application
    private func setupBadge(application: UIApplication) {
        appBadgeSetup = AppBadgeSetup(
            source: source,
            userDefaults: userDefaults,
            badgeProvider: application
        )
    }
}
