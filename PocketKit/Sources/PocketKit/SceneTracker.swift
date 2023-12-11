// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import Analytics
import SwiftUI
import Combine

class SceneTracker {
    static let dateLastOpenedKey = UserDefaults.Key.dateLastOpened
    static let dateLastBackgroundedKey = UserDefaults.Key.dateLastBackgrounded

    private let tracker: Tracker
    private let userDefaults: UserDefaults
    private let notificationCenter: NotificationCenter

    private var previousStatus: Status?

    private var subscriptions: Set<AnyCancellable> = []

    @AppStorage private var dateLastOpened: Date?

    @AppStorage private var dateLastBackgrounded: Date?

    init(tracker: Tracker, userDefaults: UserDefaults, notificationCenter: NotificationCenter = .default) {
        self.tracker = tracker
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter

        _dateLastOpened = AppStorage(Self.dateLastOpenedKey, store: userDefaults)

        _dateLastBackgrounded = AppStorage(Self.dateLastBackgroundedKey, store: userDefaults)

        createSubscriptions()
    }

    private func createSubscriptions() {
        self.notificationCenter
            .publisher(for: UIScene.didActivateNotification)
            .sink { [weak self] _ in self?.trackActivate() }
            .store(in: &subscriptions)

        self.notificationCenter
            .publisher(for: UIScene.didEnterBackgroundNotification)
            .sink { [weak self] _ in self?.trackEnterBackground() }
            .store(in: &subscriptions)
    }

    private func trackActivate() {
        guard previousStatus == nil || previousStatus == .background else {
            return
        }

        let event = AppOpenEvent(
            secondsSinceLastOpen: secondsSince(.active),
            secondsSinceLastBackground: secondsSince(.background)
        )
        tracker.track(event: event, nil)

        dateLastOpened = Date.now
        previousStatus = .active
    }

    private func trackEnterBackground() {
        guard previousStatus == .active || previousStatus == nil else {
            return
        }

        let event = AppBackgroundEvent(
            secondsSinceLastOpen: secondsSince(.active),
            secondsSinceLastBackground: secondsSince(.background)
        )

        tracker.track(event: event, nil)

        dateLastBackgrounded = Date.now
        previousStatus = .background
    }

    private func secondsSince(_ status: Status) -> UInt64? {
        switch status {
        case .active:
            guard let lastOpened = dateLastOpened else {
                return nil
            }

            let now = Date.now
            let seconds = now.timeIntervalSince(lastOpened)
            return UInt64(seconds)
        case .background:
            guard let lastBackgrounded = dateLastBackgrounded else {
                return nil
            }

            let now = Date.now
            let seconds = now.timeIntervalSince(lastBackgrounded)
            return UInt64(seconds)
        }
    }
}

private extension SceneTracker {
    enum Status {
        case active
        case background
    }
}
