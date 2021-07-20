import UIKit


public class PocketSceneDelegate: UIResponder, UIWindowSceneDelegate {
    private let coordinator: PocketSceneCoordinator

    init(coordinator: PocketSceneCoordinator) {
        self.coordinator = coordinator
    }

    override convenience init() {
        self.init(
            coordinator: PocketSceneCoordinator(
                accessTokenStore: Services.shared.accessTokenStore,
                authClient: Services.shared.authClient,
                source: Services.shared.source,
                tracker: Services.shared.tracker,
                session: Services.shared.session
            )
        )
    }

    public func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        coordinator.setup(scene: scene)
    }
}
