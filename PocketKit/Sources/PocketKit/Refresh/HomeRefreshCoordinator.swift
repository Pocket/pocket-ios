import Foundation
import UIKit
import Combine
import Sync

protocol HomeRefreshCoordinatorProtocol {
    func refresh(isForced: Bool, _ completion: @escaping () -> Void)
}

class HomeRefreshCoordinator: HomeRefreshCoordinatorProtocol {
    static let dateLastRefreshKey = "HomeRefreshCoordinator.dateLastRefreshKey"
    private let notificationCenter: NotificationCenter
    private let userDefaults: UserDefaults
    private let source: Source
    private let minimumRefreshInterval: TimeInterval
    private var subscriptions: [AnyCancellable] = []
    private var isRefreshing: Bool = false
    private var sessionProvider: SessionProvider

    init(notificationCenter: NotificationCenter, userDefaults: UserDefaults, source: Source, minimumRefreshInterval: TimeInterval = 12 * 60 * 60, sessionProvider: SessionProvider) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter
        self.minimumRefreshInterval = minimumRefreshInterval
        self.source = source
        self.sessionProvider = sessionProvider

        self.notificationCenter.publisher(for: UIScene.willEnterForegroundNotification, object: nil).sink { [weak self] _ in
            self?.refresh { }
        }.store(in: &subscriptions)
    }

    func refresh(isForced: Bool = false, _ completion: @escaping () -> Void) {
        guard (sessionProvider.session) != nil else {
            Log.info("Not refreshing home because no active session")
            return
        }

        if shouldRefresh(isForced: isForced), !isRefreshing {
            Task { [weak self] in
                guard let self = self else {
                    Log.capture(message: "Home refresh task - self is nil")
                    return
                }

                do {
                    self.isRefreshing = true
                    try await self.source.fetchSlateLineup(HomeViewModel.lineupIdentifier)
                    self.userDefaults.setValue(Date(), forKey: Self.dateLastRefreshKey)
                    Log.breadcrumb(category: "refresh", level: .info, message: "Home Refresh Occur")
                } catch {
                    Log.capture(error: error)
                }
                completion()
                isRefreshing = false
            }
        } else if isRefreshing {
            Log.debug("Already refreshing Home, not going to add to the queue")
            completion()
            return
        } else {
            Log.debug("Not refreshing Home, to early to ask for new data")
            completion()
        }
    }

    private func shouldRefresh(isForced: Bool = false) -> Bool {
        guard let lastActiveTimestamp = userDefaults.object(forKey: Self.dateLastRefreshKey) as? Date else {
            return true
        }

        let timeSinceLastRefresh = Date().timeIntervalSince(lastActiveTimestamp)

        return timeSinceLastRefresh >= minimumRefreshInterval || isForced
    }
}
