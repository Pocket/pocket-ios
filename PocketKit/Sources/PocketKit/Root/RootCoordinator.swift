import UIKit
import Sync
import SwiftUI
import Combine
import SafariServices
import Analytics


class RootCoordinator {
    private var window: UIWindow?

    private let services: Services

    private var main: MainCoordinator?
    private var loggedOutCoordinator: LoggedOutCoordinator?
    private var shouldAnimateTransition = false

    private var subscriptions: [AnyCancellable] = []

    init(services: Services) {
        self.services = services
    }

    func setup(scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        services.appSession.$currentSession.receive(on: DispatchQueue.main).sink { [weak self] session in
            self?.handle(session)
        }.store(in: &subscriptions)

        window?.makeKeyAndVisible()
    }

    private func handle(_ session: Session?) {
        if session != nil {
            loggedOutCoordinator = nil
            main = MainCoordinator(
                model: MainViewModel(
                    refreshCoordinator: services.refreshCoordinator,
                    myList: MyListContainerViewModel(
                        savedItemsList: SavedItemsListViewModel(
                            source: services.source,
                            tracker: services.tracker.childTracker(hosting: .myList.myList)
                        ),
                        archivedItemsList: ArchivedItemsListViewModel(
                            source: services.source,
                            tracker: services.tracker.childTracker(hosting: .myList.archive)
                        )
                    ),
                    home: HomeViewModel(),
                    settings: SettingsViewModel(appSession: services.appSession)
                ),
                source: services.source,
                tracker: services.tracker
            )

            transition(to: main?.viewController) { [weak self] in
                self?.services.source.refresh()
                self?.main?.showInitialView()
            }
        } else {
            main = nil
            loggedOutCoordinator = LoggedOutCoordinator(
                viewModel: PocketLoggedOutViewModel(
                    authorizationClient: services.authClient,
                    appSession: services.appSession
                )
            )

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
