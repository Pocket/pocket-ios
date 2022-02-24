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

    private let appSession: AppSession
    private let source: Source
    private let mainCoordinatorFactory: () -> MainCoordinator
    private let loggedOutCoordinatorFactory: () -> LoggedOutCoordinator

    init(
        appSession: AppSession,
        source: Source,
        mainCoordinatorFactory: @escaping () -> MainCoordinator,
        loggedOutCoordinatorFactory: @escaping () -> LoggedOutCoordinator
    ) {
        self.appSession = appSession
        self.source = source
        self.mainCoordinatorFactory = mainCoordinatorFactory
        self.loggedOutCoordinatorFactory = loggedOutCoordinatorFactory
    }

    func setup(scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        appSession.$currentSession.receive(on: DispatchQueue.main).sink { [weak self] session in
            self?.handle(session)
        }.store(in: &subscriptions)

        window?.makeKeyAndVisible()
    }

    private func handle(_ session: Session?) {
        if session != nil {
            loggedOutCoordinator = nil
            main = mainCoordinatorFactory()

            transition(to: main?.viewController) { [weak self] in
                self?.source.refresh()
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
