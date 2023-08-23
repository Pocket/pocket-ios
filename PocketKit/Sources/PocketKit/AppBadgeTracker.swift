// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Sync
import UIKit
import Combine
import SharedPocketKit

protocol BadgeProvider: AnyObject {
    var applicationIconBadgeNumber: Int { get set }
}

extension UIApplication: BadgeProvider { }

class AppBadgeSetup {
    static let toggleAppBadgeKey = UserDefaults.Key.toggleAppBadge

    private let source: Source
    private let notificationCenter: NotificationCenter
    private var subscriptions: Set<AnyCancellable> = []
    private var userDefaults: UserDefaults
    private let badgeProvider: BadgeProvider
    /// This completion block is called once the badge value is updated. This completion block is not currently used in the app code, but is utilized in tests, since setting the badge needs to occur on the main thread (when using UIApplication as the provider), which is called asynchronously. Thus, this is added as async test support.
    private let completion: (() -> Void)?

    init(
        source: Source,
        userDefaults: UserDefaults,
        notificationCenter: NotificationCenter = .default,
        badgeProvider: BadgeProvider,
        completion: (() -> Void)? = nil
    ) {
        self.source = source
        self.notificationCenter = notificationCenter
        self.userDefaults = userDefaults
        self.badgeProvider = badgeProvider
        self.completion = completion

        setupNotificationSubscription()
    }

    private func setupNotificationSubscription() {
        self.notificationCenter
            .publisher(for: .listUpdated)
            .sink { [weak self] _ in
                self?.manualCheckForSavedCount()
            }
            .store(in: &subscriptions)
    }

    func manualCheckForSavedCount() {
        var numberOfSaves: Int = 0
        let badgeEnabled = userDefaults.bool(forKey: Self.toggleAppBadgeKey)
        if badgeEnabled {
            do {
                numberOfSaves = try source.unreadSaves()
            } catch {
                Log.capture(error: error)
            }
        }

        updateBadgeValue(numberOfSaves: numberOfSaves)
    }

    private func updateBadgeValue(numberOfSaves: Int) {
//        DispatchQueue.main.async { [weak self] in
//            self?.badgeProvider.applicationIconBadgeNumber = numberOfSaves
//            self?.completion?()
//        }
    }
}
