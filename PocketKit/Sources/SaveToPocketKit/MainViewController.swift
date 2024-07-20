// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Analytics
import Textile
import Apollo
import SharedPocketKit
import Sync
import Adjust

class MainViewController: UIViewController {
    static let services: Services = {
        let services = Services.shared

        services.start {
            services.userDefaults.set(true, forKey: .forceRefreshFromExtension)
        }

        return services
    }()

    private let childViewController: UIViewController

    convenience init() {
        self.init(services: Self.services)
    }

    convenience init(services: Services) {
        Textiles.initialize()

        let appSession = services.appSession
        let userDefaults = services.userDefaults
        let user = services.user
        let notificationCenter = services.notificationCenter
        let child: UIViewController
        let tracker = services.tracker
        let braze = services.braze

        // Reset and attach at least an api user entity on extension launch
        tracker.resetPersistentEntities([
            APIUserEntity(consumerKey: Keys.shared.pocketApiConsumerKey)
        ])

        if let currentSession = appSession.currentSession {
            // Attach a user entity at launch if it exists
            tracker.addPersistentEntity(UserEntity(guid: currentSession.guid, userID: currentSession.userIdentifier, adjustAdId: Adjust.adid()))
        }

        SignOutOnFirstLaunch(
            appSession: appSession,
            user: user,
            userDefaults: userDefaults
        ).execute()

        if appSession.currentSession == nil {
            Log.clearUser()
            child = LoggedOutViewController(
                viewModel: LoggedOutViewModel()
            )
        } else {
            Log.setUserID(services.appSession.currentSession!.userIdentifier)
            child = SavedItemViewController(
                viewModel: SavedItemViewModel(
                    appSession: appSession,
                    saveService: services.saveService,
                    dismissTimer: Timer.TimerPublisher(interval: 3.0, runLoop: .main, mode: .default),
                    tracker: Services.shared.tracker.childTracker(hosting: .saveExtension.screen),
                    consumerKey: Keys.shared.pocketApiConsumerKey,
                    userDefaults: userDefaults,
                    user: Services.shared.user,
                    notificationCenter: notificationCenter,
                    recentSavesWidgetUpdateService: Services.shared.recentSavesWidgetUpdateService
                )
            )
        }

        self.init(childViewController: child)
    }

    init(childViewController: UIViewController) {
        self.childViewController = childViewController
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(childViewController)
        view.addSubview(childViewController.view)
        childViewController.didMove(toParent: self)

        childViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            childViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
