import UIKit
import Sync
import SwiftUI
import Combine
import SafariServices


class PocketSceneCoordinator {
    private let accessTokenStore: AccessTokenStore
    private let authClient: AuthorizationClient
    private let source: Source

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
        source: Source
    ) {
        self.accessTokenStore = accessTokenStore
        self.authClient = authClient
        self.source = source

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

        if let token = accessTokenStore.accessToken {
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
            context: source.managedObjectContext,
            selection: itemSelection
        )

        let primaryViewController = UIHostingController(rootView: listView)
        let secondaryViewController = ItemViewController(
            selection: itemSelection,
            readerSettings: readerSettings
        )

        split.setViewController(primaryViewController, for: .primary)
        split.setViewController(secondaryViewController, for: .secondary)

        secondaryViewController.delegate = self
        split.delegate = self
    }

    private func bindToStateChanges() {
        itemSelection.$selectedItem.sink { [weak self] item in
            self?.handleItemSelection()
        }.store(in: &subscriptions)

        authState.$authToken.receive(on: DispatchQueue.main).sink { [weak self] response in
            self?.handleAuthResponse(response)
        }.store(in: &subscriptions)
    }

    private func handleItemSelection() {
        split.show(.secondary)
    }

    private func handleAuthResponse(_ response: AuthorizeResponse?) {
        guard let token = response else {
            return
        }

        do {
            try accessTokenStore.save(token: token.accessToken)
            Crashlogger.setUserID(token.account.userID)
        } catch {
            Crashlogger.capture(error: error)
        }

        source.refresh(token: token.accessToken)
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
    }

    private func shouldDisplaySettingsAsSheet(traitCollection: UITraitCollection) -> Bool {
        return traitCollection.userInterfaceIdiom == .pad ||
        traitCollection.horizontalSizeClass == .compact
    }
}
