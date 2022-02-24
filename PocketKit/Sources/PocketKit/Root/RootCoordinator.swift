import UIKit
import Sync
import SwiftUI
import Combine
import SafariServices
import Analytics


class RootCoordinator {
    private var window: UIWindow?

    private var main: MainCoordinator?
    private var loggedOutCoordinator: LoggedOutCoordinator?
    private var shouldAnimateTransition = false

    private var subscriptions: [AnyCancellable] = []

    private let rootViewModel: RootViewModel
    private let mainCoordinatorFactory: () -> MainCoordinator
    private let loggedOutCoordinatorFactory: () -> LoggedOutCoordinator

    init(
        rootViewModel: RootViewModel,
        mainCoordinatorFactory: @escaping () -> MainCoordinator,
        loggedOutCoordinatorFactory: @escaping () -> LoggedOutCoordinator
    ) {
        self.rootViewModel = rootViewModel
        self.mainCoordinatorFactory = mainCoordinatorFactory
        self.loggedOutCoordinatorFactory = loggedOutCoordinatorFactory
    }

    func setup(scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        rootViewModel.$isLoggedIn.receive(on: DispatchQueue.main).sink { isLoggedIn in
            self.updateState(isLoggedIn)
        }.store(in: &subscriptions)

        window?.makeKeyAndVisible()
    }

    private func updateState(_ isLoggedIn: Bool) {
        if isLoggedIn {
            loggedOutCoordinator = nil
            main = mainCoordinatorFactory()

            transition(to: main?.viewController) { [weak self] in
                self?.main?.showInitialView()
            }
        } else {
            main = nil
            loggedOutCoordinator = loggedOutCoordinatorFactory()

            transition(to: loggedOutCoordinator?.viewController)
        }

        if !self.shouldAnimateTransition {
            self.shouldAnimateTransition = true
        }
    }

    private func transition(
        to rootViewController: UIViewController?,
        completion: (() -> Void)? = nil
    ) {

        func transition() {
            UIView.transition(
                with: window!,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: {
                    self.window?.rootViewController = rootViewController
                },
                completion: { _ in
                    completion?()
                }
            )
        }

        if shouldAnimateTransition {
            transition()
        } else {
            UIView.performWithoutAnimation {
                transition()
            }
        }
    }
}
