// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit

/// Helper type to distinguish between the 2 Apple haptic feedback types
enum HapticFeedbackType {
    case play(UIImpactFeedbackGenerator.FeedbackStyle)
    case notify(UINotificationFeedbackGenerator.FeedbackType)
}

/// Singleton used to provide Haptics to buttons and elements in UIKit
/// Inspired by https://stackoverflow.com/questions/56748539/how-to-create-haptic-feedback-for-a-button-in-swiftui
public class Haptics {
    static let shared = Haptics()

    private init() { }

    func haptic(_ hapticType: HapticFeedbackType) {
        switch hapticType {
        case .play(let style):
            play(style)
        case .notify(let type):
            notify(type)
        }
    }

    /// Performs an action feedback
    /// - Parameter feedbackStyle: The style to use when playing the feedback
    private func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }

    /// Performs a Notification feedback
    /// - Parameter feedbackType: The style to use when playing the feedback
    private func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}

/// Saves/Archive View Haptics
extension Haptics {
    /// Saves/Archive selector changed
    public static func savesSelectorChanged() {
        Haptics.shared.haptic(.play(.rigid))
    }

    /// Item saved
    public static func saveTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Moved from archive to saves
    public static func moveToSavesTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Deleted item
    public static func deleteTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Archived an item
    public static func archiveTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Favorited an item
    public static func favoriteTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Unfavorited an item
    public static func unfavoriteTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped add tags
    public static func addTagsTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped share
    public static func shareTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped overlflow menu on item cells
    public static func overflowTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped display settings in reader mode
    public static func displaySettingsTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped report a rec
    public static func reportTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped copy link
    public static func copyLinkTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Opened an item
    public static func openItemTap() {
        Haptics.shared.haptic(.play(.medium))
    }

    /// Tapped the primary button on a recomendation
    public static func recomendationPrimaryTap() {
        Haptics.shared.haptic(.play(.medium))
    }
}
