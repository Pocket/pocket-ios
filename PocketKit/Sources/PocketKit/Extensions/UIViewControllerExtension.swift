// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

extension UIViewController {
    func configurePocketDefaultDetents() {
        // iPhone (Portrait): defaults to .medium(); iPhone (Landscape): defaults to .large()
        // By setting `prefersEdgeAttachedInCompactHeight` and `widthFollowsPreferredContentSizeWhenEdgeAttached`,
        // landscape (iPhone) provides a non-fullscreen view that is dismissable by the user.
        let detents: [UISheetPresentationController.Detent] = [.medium(), .large()]
        sheetPresentationController?.detents = detents
        sheetPresentationController?.prefersGrabberVisible = true
        sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
        sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = true
    }

    /// Locks the orientation for a specific view controller
    /// - Parameter orientation: orientation of the view (i.e. portrait, all)
    func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        PocketAppDelegate.phoneOrientationLock = orientation
    }
}

extension UITraitCollection {
    /// Used to determine if the device should use wide layout due to it being an iPad with regular horizontal size class
    /// - Returns: true or false if the device should use our configurations for a wide layout
    func shouldUseWideLayout() -> Bool {
        userInterfaceIdiom == .pad &&
        horizontalSizeClass == .regular
    }
}
