import UIKit
import Combine
import SafariServices
import Analytics
import Sync

// swiftlint:disable:next class_delegate_protocol
protocol RegularHomeCoordinatorDelegate: ModalContentPresenting {
    func homeCoordinatorDidSelectMyList(_ coordinator: RegularHomeCoordinator)
}

class RegularHomeCoordinator: NSObject {
    weak var delegate: RegularHomeCoordinatorDelegate?

    var viewController: UIViewController {
        navigationController
    }

    private let model: HomeViewModel
    private let tracker: Tracker
    private let navigationController: UINavigationController
    private let homeViewController: HomeViewController
    private var isResetting: Bool = false

    private var subscriptions: [AnyCancellable] = []
    private var slateDetailSubscriptions: [AnyCancellable] = []
    private var readerSubscriptions: [AnyCancellable] = []

    init(model: HomeViewModel, tracker: Tracker) {
        self.model = model
        self.tracker = tracker

        homeViewController = HomeViewController(model: model)
        navigationController = UINavigationController(rootViewController: homeViewController)

        super.init()

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
        navigationController.delegate = self
    }

    func stopObservingModelChanges() {
        subscriptions = []
        slateDetailSubscriptions = []
    }

    func observeModelChanges() {
        isResetting = true

        navigationController.popToRootViewController(animated: !isResetting)

        model.$selectedReadableType.sink { [weak self] readableType in
            self?.show(readableType)
        }.store(in: &subscriptions)

        model.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &subscriptions)

        model.$presentedWebReaderURL.sink { [weak self] url in
            self?.push(url)
        }.store(in: &subscriptions)

        model.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &subscriptions)

        model.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &subscriptions)

        model.$tappedSeeAll.sink { [weak self] seeAll in
            self?.show(seeAll)
        }.store(in: &subscriptions)

        isResetting = false
    }
}

// MARK: - Showing slate detail
extension RegularHomeCoordinator {
    private func show(_ seeAll: SeeAll?) {
        switch seeAll {
        case .slate(let slateDetail):
            show(slateDetail)
        case .myList:
            delegate?.homeCoordinatorDidSelectMyList(self)
        case .none:
            break
        }
    }

    private func show(_ slate: SlateDetailViewModel) {
        slate.$selectedReadableViewModel.sink { [weak self] readable in
            self?.show(readable)
        }.store(in: &slateDetailSubscriptions)

        slate.$presentedWebReaderURL.sink { [weak self] url in
            self?.push(url)
        }.store(in: &slateDetailSubscriptions)

        slate.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &slateDetailSubscriptions)

        slate.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &slateDetailSubscriptions)

        let slateDetailVC = SlateDetailViewController(model: slate)
        navigationController.pushViewController(slateDetailVC, animated: !isResetting)
    }
}

// MARK: - Showing reader content
extension RegularHomeCoordinator {
    private func show(_ readable: ReadableType?) {
        switch readable {
        case .recommendation(let recommendation):
            show(recommendation)
        case .savedItem(let savedItem):
            show(savedItem)
        case .none:
            break
        }
    }

    private func show(_ readable: SavedItemViewModel?) {
        guard let readable = readable else {
            return
        }
        readerSubscriptions = []

        readable.$presentedWebReaderURL.sink { [weak self] url in
            self?.push(url)
        }.store(in: &readerSubscriptions)

        readable.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.present(readable.readerSettings, isPresenting: isPresenting)
        }.store(in: &readerSubscriptions)

        readable.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &readerSubscriptions)

        readable.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &readerSubscriptions)

        let readableVC = ReadableHostViewController(readableViewModel: readable)
        navigationController.pushViewController(readableVC, animated: !isResetting)

        readable.events.sink { [weak self] event in
            switch event {
                case .contentUpdated:
                    break
                case .archive, .delete:
                    self?.navigationController.popViewController(animated: true)
            }
        }.store(in: &readerSubscriptions)
    }

    private func show(_ readable: RecommendationViewModel?) {
        guard let readable = readable else {
            return
        }
        readerSubscriptions = []

        readable.$presentedWebReaderURL.sink { [weak self] url in
            self?.push(url)
        }.store(in: &readerSubscriptions)

        readable.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.present(readable.readerSettings, isPresenting: isPresenting)
        }.store(in: &readerSubscriptions)

        readable.$presentedAlert.sink { [weak self] alert in
            self?.present(alert)
        }.store(in: &readerSubscriptions)

        readable.$sharedActivity.sink { [weak self] activity in
            self?.share(activity)
        }.store(in: &readerSubscriptions)

        readable.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &readerSubscriptions)

        let viewController = ReadableHostViewController(readableViewModel: readable)
        navigationController.pushViewController(viewController, animated: !isResetting)

        readable.events.sink { [weak self] event in
            switch event {
                case .contentUpdated:
                    break
                case .archive, .delete:
                    self?.navigationController.popViewController(animated: true)
            }
        }.store(in: &readerSubscriptions)
    }
}

// MARK: - Presenting modals
extension RegularHomeCoordinator {
    private func report(_ recommendation: Recommendation?) {
        delegate?.report(recommendation)
    }

    private func push(_ url: URL?) {
        guard let url = url else { return }
        let safariVC = SFSafariViewController(url: url)

        safariVC.delegate = self
        navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(safariVC, animated: !isResetting)
    }

    private func present(_ alert: PocketAlert?) {
        delegate?.present(alert)
    }

    private func share(_ activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)
        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.clearSharedActivity()
        }

        if let view = activity.sender as? UIView {
            activityVC.popoverPresentationController?.sourceView = view
        } else if let buttonItem = activity.sender as? UIBarButtonItem {
            activityVC.popoverPresentationController?.barButtonItem = buttonItem
        } else {
            activityVC.popoverPresentationController?.barButtonItem = navigationController
                .topViewController?
                .navigationItem
                .rightBarButtonItems?
                .first
        }

        navigationController.present(activityVC, animated: !isResetting)
    }

    func present(_ readerSettings: ReaderSettings?, isPresenting: Bool?) {
        guard !isResetting, let readerSettings = readerSettings, isPresenting == true else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(
            settings: readerSettings,
            onDismiss: { [weak self] in
                self?.model.clearIsPresentingReaderSettings()
            }
        )

        readerSettingsVC.modalPresentationStyle = .popover
        readerSettingsVC.popoverPresentationController?.barButtonItem = navigationController
            .topViewController?
            .navigationItem
            .rightBarButtonItems?
            .first

        navigationController.present(readerSettingsVC, animated: !isResetting)
    }
}

// MARK: - UINavigationControllerDelegate
extension RegularHomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === homeViewController {
            slateDetailSubscriptions = []
            readerSubscriptions = []
            model.clearSelectedItem()
            model.clearTappedSeeAll()
        }

        if viewController is SlateDetailViewController {
            readerSubscriptions = []
            model.tappedSeeAll?.clearSelectedItem()
        }
    }
}

extension RegularHomeCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        navigationController.popViewController(animated: !isResetting)
        navigationController.isNavigationBarHidden = false

        model.clearPresentedWebReaderURL()
    }
}
