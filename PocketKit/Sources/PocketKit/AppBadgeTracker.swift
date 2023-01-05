import Foundation
import Sync
import UIKit
import Combine

protocol BadgeProvider: AnyObject {
    var applicationIconBadgeNumber: Int { get set }
}

extension UIApplication: BadgeProvider { }

class AppBadgeSetup {
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
        let numberOfSavesRequest = Requests.fetchSavedItems()
        var numberOfSaves: Int
        let currentValue = userDefaults.bool(forKey: AccountViewModel.ToggleAppBadgeKey)
        if currentValue == false {
            numberOfSaves = 0
        } else {
            do {
                numberOfSaves = try source.mainContext.fetch(numberOfSavesRequest).count
                print(numberOfSaves)
            } catch {
                numberOfSaves = 0
            }
        }

        updateBadgeValue(numberOfSaves: numberOfSaves)
    }

    private func updateBadgeValue(numberOfSaves: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.badgeProvider.applicationIconBadgeNumber = numberOfSaves
            self?.completion?()
        }
    }
}
