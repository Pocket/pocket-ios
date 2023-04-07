// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import UIKit

/// Singleton used to provide Haptics to buttons and elements in UIKit
/// Inspired by https://stackoverflow.com/questions/56748539/how-to-create-haptic-feedback-for-a-button-in-swiftui
public class Haptics {

    public struct Constants {
        /// Saves/Archive selector changed
        static let savesSelector: UIImpactFeedbackGenerator.FeedbackStyle = .rigid
    }

    static let shared = Haptics()

    private init() { }
    
    /// Performs an action feedback
    /// - Parameter feedbackStyle: The style to use when playing the feedback
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    /// Performs a Notification feedback
    /// - Parameter feedbackType: The style to use when playing the feedback
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}

extension Haptics {

    /// Saves/Archive selector changed
    public static func savesSelectorChanged() {
        Haptics.shared.play(Constants.savesSelector)
    }

}
