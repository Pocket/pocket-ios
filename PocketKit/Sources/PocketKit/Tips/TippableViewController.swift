// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import TipKit

/// Conform any UIViewController subclass to this protocol to add a poppver tip
protocol TippableViewController: UIViewController {
    /// Displays the given tip as a popover from the given soruce view with the given configuration.
    /// - Parameters:
    ///   - tip: the given tip
    ///   - configuration: tip popover configuration; if nil, defaults are applied
    ///   - sourceView: tip popover source view; if nil, defaults to the main navigation controller's view
    @available(iOS 17.0, *)
    func displayTip<T: Tip>(_ tip: T, configuration: TipUIConfiguration?, sourceView: UIView?)
    /// Reference to the observer task for the current tip, used to display async updates of the tip
    var tipObservationTask: Task<Void, Error>? { get set }
    /// Reference to the constructed tip popover view controller, used to handle prenting and dismissing it
    var tipViewController: UIViewController? { get set }
}

struct TipUIConfiguration {
    let sourceRect: CGRect?
    let permittedArrowDirections: UIPopoverArrowDirection?
    let backgroundColor: UIColor?
    let tintColor: UIColor?
}

// MARK: default implementation
extension TippableViewController {
    @available(iOS 17.0, *)
    func displayTip<T: Tip>(_ tip: T, configuration: TipUIConfiguration?, sourceView: UIView?) {
        tipObservationTask = tipObservationTask ?? Task.delayed(byTimeInterval: 0.5) { @MainActor [weak self] in
            guard let self else {
                return
            }
            for await shouldDisplay in tip.shouldDisplayUpdates {
                if shouldDisplay {
                    // force unwrapping is ok because we check that the list is not empty
                    guard let view = sourceView ?? self.navigationController?.view else {
                        return
                    }
                    let controller = TipUIPopoverViewController(tip, sourceItem: view)
                    controller.popoverPresentationController?.sourceRect = configuration?.sourceRect ?? defaultSourceRect(view)
                    controller.popoverPresentationController?.permittedArrowDirections = configuration?.permittedArrowDirections ?? arrowDirection
                    controller.view.backgroundColor = configuration?.backgroundColor ?? UIColor(.ui.grey6)
                    controller.view.tintColor = configuration?.tintColor ?? UIColor(.ui.black1)
                    tipViewController = controller
                    present(controller, animated: true)
                } else {
                    tipViewController?.dismiss(animated: true)
                    tipViewController = nil
                }
            }
        }
    }

    /// The default source rect for the tip popover, displays at 2/3 of the screen height
    /// - Parameter view: the source view of the popover
    /// - Returns: the source rect
    private func defaultSourceRect(_ view: UIView) -> CGRect {
        let x = traitCollection.layoutDirection == .leftToRight ?
        (view.bounds.width - view.readableContentGuide.layoutFrame.width) / 2 + view.readableContentGuide.layoutFrame.width :
        (view.bounds.width - view.readableContentGuide.layoutFrame.width) / 2

        let y = (view.bounds.height / 3) * 2

        return CGRect(x: x, y: y, width: 0, height: 0)
    }

    /// The default arrow direction of the tip popover, that points to the trailing edge
    private var arrowDirection: UIPopoverArrowDirection {
        traitCollection.layoutDirection == .leftToRight ? .right : .left
    }
}

// MARK: Task with delay
private extension Task where Failure == Error {
    /// defines a task delayed by the specified time interval. Used to display a tip on screen with a slight delay
    static func delayed(
        byTimeInterval delayInterval: TimeInterval,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            let delay = UInt64(delayInterval * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)
            return try await operation()
        }
    }
}
