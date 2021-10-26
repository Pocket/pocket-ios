import UIKit
import Sync
import SwiftUI
import Combine
import SafariServices
import Analytics


class PocketSceneCoordinator: NSObject {
    private let accessTokenStore: AccessTokenStore
    private let source: Source
    private let tracker: Tracker
    private let session: Session

    private let mainViewModel: MainViewModel
    private let authState = AuthorizationState()
    private var window: UIWindow?

    private let signIn: UIViewController
    private let main: MainCoordinator

    private var subscriptions: [AnyCancellable] = []

    init(
        accessTokenStore: AccessTokenStore,
        authClient: AuthorizationClient,
        source: Source,
        tracker: Tracker,
        session: Session,
        refreshCoordinator: RefreshCoordinator
    ) {
        self.accessTokenStore = accessTokenStore
        self.source = source
        self.tracker = tracker
        self.session = session
        self.mainViewModel = MainViewModel(refreshCoordinator: refreshCoordinator)

        let signInView = SignInView(authClient: authClient, state: authState)
        signIn = UIHostingController(rootView: signInView)
        signIn.view.backgroundColor = UIColor(.ui.white1)
        main = MainCoordinator(model: mainViewModel, source: source, tracker: tracker)

        super.init()

        authState.$authorization.receive(on: DispatchQueue.main).sink { [weak self] authorization in
            self?.handleAuthResponse(authorization)
        }.store(in: &subscriptions)
    }

    func setup(scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)
        setRootViewController()
        window?.makeKeyAndVisible()
    }

    private func handleAuthResponse(_ response: Authorization?) {
        guard let authorization = response else {
            return
        }

        do {
            try accessTokenStore.save(token: authorization.response.accessToken)
        } catch {
            Crashlogger.capture(error: error)
        }

        session.guid = authorization.guid
        session.userID = authorization.response.account.userID

        setRootViewController()
    }

    private func setRootViewController() {
        let rootVC: UIViewController

        if accessTokenStore.accessToken != nil,
           let guid = session.guid,
           let userID = session.userID {

            let user = UserContext(guid: guid, userID: userID)
            tracker.addPersistentContext(user)
            Crashlogger.setUserID(userID)
            source.refresh()

            rootVC = main.viewController
        } else {
            rootVC = signIn
        }

        UIView.transition(
            with: window!,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: {
                self.window?.rootViewController = rootVC
                self.main.showList()
            },
            completion: nil
        )
    }
}
