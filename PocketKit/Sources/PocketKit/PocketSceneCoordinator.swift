import UIKit
import Sync
import SwiftUI
import Combine
import SafariServices
import Analytics


class PocketSceneCoordinator {
    private let accessTokenStore: AccessTokenStore
    private let authClient: AuthorizationClient
    private let source: Source
    private let tracker: Tracker
    private let session: Session

    private let itemSelection = ItemSelection()
    private let authState = AuthorizationState()
    private let readerSettings = ReaderSettings()

    private var window: UIWindow?
    private let split: UISplitViewController
    private let signIn: UIHostingController<SignInView>

    private var subscriptions: [AnyCancellable] = []

    init(
        accessTokenStore: AccessTokenStore,
        authClient: AuthorizationClient,
        source: Source,
        tracker: Tracker,
        session: Session
    ) {
        self.accessTokenStore = accessTokenStore
        self.authClient = authClient
        self.source = source
        self.tracker = tracker
        self.session = session

        let signInView = SignInView(authClient: authClient, state: authState)
        signIn = UIHostingController(rootView: signInView)

        split = UISplitViewController(style: .doubleColumn)
        configureSplitView()

        bindToStateChanges()
    }

    func setup(scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)

        if let token = accessTokenStore.accessToken,
           let guid = session.guid,
           let userID = session.userID {
            finalizeAuthentication(guid: guid, userID: userID)
            
            source.refresh(token: token)
            window?.rootViewController = split
            split.show(.primary)
        } else {
            window?.rootViewController = signIn
        }

        window?.makeKeyAndVisible()
    }

    private func configureSplitView() {
        let listView = ItemListView(
            selection: itemSelection,
            source: source
        )
        .environment(\.managedObjectContext, source.mainContext)
        .environment(\.tracker, tracker)

        let primaryViewController = UIHostingController(rootView: listView)
        let secondaryViewController = ItemViewController(
            selection: itemSelection,
            readerSettings: readerSettings,
            tracker: tracker
        )

        split.setViewController(primaryViewController, for: .primary)
        split.setViewController(secondaryViewController, for: .secondary)

        secondaryViewController.delegate = self
        split.delegate = self
    }

    private func bindToStateChanges() {
        itemSelection.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] item in
            if item != nil {
                self?.handleItemSelection()
            }
        }.store(in: &subscriptions)

        authState.$authorization.receive(on: DispatchQueue.main).sink { [weak self] authorization in
            self?.handleAuthResponse(authorization)
        }.store(in: &subscriptions)
    }

    private func handleItemSelection() {
        split.show(.secondary)
    }

    private func handleAuthResponse(_ response: Authorization?) {
        guard let authorization = response else {
            return
        }

        do {
            try accessTokenStore.save(token: authorization.response.accessToken)
            session.guid = authorization.guid
            session.userID = authorization.response.account.userID
            finalizeAuthentication(guid: authorization.guid, userID: authorization.response.account.userID)
        } catch {
            Crashlogger.capture(error: error)
        }

        source.refresh(token: authorization.response.accessToken)
        UIView.transition(
            with: window!,
            duration: 0.25,
            options: .transitionCrossDissolve,
            animations: {
                self.window?.rootViewController = self.split
                self.split.show(.primary)
            },
            completion: nil
        )
    }
    
    private func finalizeAuthentication(guid: String, userID: String) {
        let user = SnowplowUser(guid: guid, userID: userID)
        tracker.addPersistentContext(user)
        
        Crashlogger.setUserID(userID)
    }
}

extension PocketSceneCoordinator: UISplitViewControllerDelegate {
    func splitViewController(
        _ splitViewController: UISplitViewController,
        topColumnForCollapsingToProposedTopColumn column: UISplitViewController.Column
    ) -> UISplitViewController.Column{
        return .primary
    }
}

extension PocketSceneCoordinator: ItemViewControllerDelegate {
    func itemViewControllerDidTapOverflowButton(_ itemViewController: ItemViewController) {
        let settings = UIHostingController(rootView: ReaderSettingsView(settings: readerSettings))

        if shouldDisplaySettingsAsSheet(traitCollection: split.traitCollection) {
            settings.sheetPresentationController?.detents = [.medium()]
        } else {
            settings.modalPresentationStyle = .popover

            let anchor = itemViewController.navigationItem.rightBarButtonItems?[0]
            settings.popoverPresentationController?.barButtonItem = anchor
        }

        split.present(settings, animated: true)
    }

    func itemViewControllerDidTapWebViewButton(_ itemViewController: ItemViewController) {
        guard let url = itemSelection.selectedItem?.url else {
            return
        }

        let safariVC = SFSafariViewController(url: url)
        split.present(safariVC, animated: true)
        
        let content = Content(url: url)
        let contexts = [content, itemViewController.uiContext, UIContext.articleView.switchToWebView]
        let engagement = Engagement(type: .general, value: nil)
        tracker.track(event: engagement, contexts)
    }

    private func shouldDisplaySettingsAsSheet(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .phone ||
        traitCollection.horizontalSizeClass == .compact
    }
}
