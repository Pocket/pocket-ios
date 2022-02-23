import UIKit
import AuthenticationServices


public class PocketSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator: RootCoordinator

    init(coordinator: RootCoordinator) {
        self.coordinator = coordinator
    }

    override convenience init() {
        self.init(coordinator: RootCoordinator(services: Services.shared))
    }

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        coordinator.setup(scene: scene)
    }
}
