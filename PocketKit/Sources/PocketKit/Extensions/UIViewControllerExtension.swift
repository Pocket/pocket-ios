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
