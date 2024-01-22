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

    /// Default haptic used in most taps
    public static func defaultTap() {
        Haptics.shared.haptic(.play(.medium))
    }
}
