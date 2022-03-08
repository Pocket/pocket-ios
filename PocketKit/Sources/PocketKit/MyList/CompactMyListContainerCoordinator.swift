import UIKit
import Combine
import SafariServices


class CompactMyListContainerCoordinator: NSObject {
    var viewController: UIViewController {
        return navigationController
    }

    private let model: MyListContainerViewModel
    private let navigationController: UINavigationController
    private let containerViewController: MyListContainerViewController
    private var subscriptions: [AnyCancellable]
    private var readableSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    init(model: MyListContainerViewModel) {
        self.model = model
        self.subscriptions = []

        containerViewController = MyListContainerViewController(
            viewControllers: [
                ItemsListViewController(model: model.savedItemsList),
                ItemsListViewController(model: model.archivedItemsList)
            ]
        )
        navigationController = UINavigationController(rootViewController: containerViewController)

        super.init()

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }

    func stopObservingModelChanges() {
        subscriptions = []
        readableSubscriptions = []
    }

    func observeModelChanges() {
        isResetting = true

        navigationController.popToRootViewController(animated: false)

        // My List navigation
        model.savedItemsList.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.savedItemsList.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &subscriptions)

        model.savedItemsList.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.savedItemsList.$selectedReadable.receive(on: DispatchQueue.main).sink { [weak self] readable in
            self?.push(savedItem: readable)
        }.store(in: &subscriptions)

        // Archive navigation
        model.archivedItemsList.$selectedReadable.receive(on: DispatchQueue.main).sink { [weak self] readable in
            self?.push(savedItem: readable)
        }.store(in: &subscriptions)

        model.archivedItemsList.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        model.archivedItemsList.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &subscriptions)

        isResetting = false
        navigationController.delegate = self
    }

    private func push(savedItem: SavedItemViewModel?) {
        guard let readable = savedItem else {
            readableSubscriptions = []
            return
        }

        readable.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readableSubscriptions)

        readable.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &readableSubscriptions)

        readable.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readableSubscriptions)

        readable.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: readable)
        }.store(in: &readableSubscriptions)

        readable.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            self?.navigationController.popToRootViewController(animated: true)
        }.store(in: &readableSubscriptions)

        navigationController.pushViewController(
            ReadableHostViewController(readableViewModel: readable),
            animated: !isResetting
        )
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        viewController.present(UIAlertController(alert), animated: !isResetting)
    }

    private func present(activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)
        // Prevent a crash if you switch from compact to regular while sharing
        activityVC.popoverPresentationController?.sourceView = navigationController.splitViewController?.view

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.archivedItemsList.sharedActivity = nil
            self?.model.archivedItemsList.selectedReadable?.sharedActivity = nil
            self?.model.savedItemsList.sharedActivity = nil
            self?.model.archivedItemsList.sharedActivity = nil
        }

        viewController.present(activityVC, animated: !isResetting)
    }

    private func present(url: URL?) {
        guard !isResetting, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        viewController.present(safariVC, animated: !isResetting)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard !isResetting, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) {
            readable.isPresentingReaderSettings = false
        }

        readerSettingsVC.modalPresentationStyle = .pageSheet
        readerSettingsVC.sheetPresentationController?.detents = [.medium()]

        viewController.present(readerSettingsVC, animated: !isResetting)
    }
}

extension CompactMyListContainerCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard viewController == containerViewController else {
            return
        }

        model.archivedItemsList.selectedReadable = nil
        model.savedItemsList.selectedReadable = nil
    }
}

extension CompactMyListContainerCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.archivedItemsList.selectedReadable?.presentedWebReaderURL = nil
        model.savedItemsList.selectedReadable?.presentedWebReaderURL = nil
    }
}
