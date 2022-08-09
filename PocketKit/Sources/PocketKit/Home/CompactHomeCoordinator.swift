import UIKit
import Combine
import Sync
import Analytics
import BackgroundTasks
import SafariServices

protocol CompactHomeCoordinatorDelegate: AnyObject {
    func compactHomeCoordinatorDidSelectRecentSaves(_ coordinator: CompactHomeCoordinator)
}

class CompactHomeCoordinator: NSObject {
    var viewController: UIViewController {
        return navigationController
    }

    weak var delegate: CompactHomeCoordinatorDelegate?

    private let navigationController: UINavigationController
    private let homeViewController: HomeViewController
    private let model: HomeViewModel
    private var subscriptions: [AnyCancellable] = []
    private var slateDetailSubscriptions: [AnyCancellable] = []
    private var readerSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    // only necessary for creating nested view controller
    // should use a factory instead
    private let source: Source
    private let tracker: Tracker

    init(source: Source, tracker: Tracker, model: HomeViewModel) {
        self.source = source
        self.tracker = tracker
        self.model = model

        homeViewController = HomeViewController(model: model)
        navigationController = UINavigationController(rootViewController: homeViewController)

        super.init()

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }

    func observeModelChanges() {
        navigationController.popToRootViewController(animated: false)
        isResetting = true

        model.$selectedReadableType.sink { [weak self] readableType in
            switch readableType {
            case .savedItem(let viewModel):
                self?.show(viewModel)
            case .recommendation(let viewModel):
                self?.show(viewModel)
            case .none:
                self?.readerSubscriptions = []
            }
        }.store(in: &subscriptions)

        model.$selectedSlateDetailViewModel.sink { [weak self] viewModel in
            self?.show(viewModel)
        }.store(in: &subscriptions)

        model.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation) {
                self?.model.selectedRecommendationToReport = nil
            }
        }.store(in: &subscriptions)

        model.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &subscriptions)
        
        model.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)
        
        model.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        model.$tappedSeeAll.dropFirst().sink { [weak self] seeAll in
            self?.show(seeAll)
        }.store(in: &subscriptions)

        isResetting = false
        navigationController.delegate = self
    }

    func stopObservingModelChanges() {
        subscriptions = []
        slateDetailSubscriptions = []
        readerSubscriptions = []
    }

    func handleBackgroundRefresh(task: BGTask) {
        homeViewController.handleBackgroundRefresh(task: task)
    }

    func show(_ viewModel: SlateDetailViewModel?) {
        guard let viewModel = viewModel else {
            slateDetailSubscriptions = []
            return
        }

        navigationController.pushViewController(
            SlateDetailViewController(model: viewModel),
            animated: !isResetting
        )

        viewModel.$selectedReadableViewModel.sink { [weak self] readable in
            self?.show(readable)
        }.store(in: &slateDetailSubscriptions)

        viewModel.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation) {
                viewModel.selectedRecommendationToReport = nil
            }
        }.store(in: &slateDetailSubscriptions)

        viewModel.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &subscriptions)
    }

    func show(_ recommendation: RecommendationViewModel?) {
        guard let recommendation = recommendation else {
            readerSubscriptions = []
            return
        }

        navigationController.pushViewController(
            ReadableHostViewController(readableViewModel: recommendation),
            animated: !isResetting
        )

        recommendation.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        recommendation.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readerSubscriptions)

        recommendation.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &readerSubscriptions)

        recommendation.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: recommendation)
        }.store(in: &readerSubscriptions)

        recommendation.$selectedRecommendationToReport.sink { [weak self] selected in
            self?.report(selected) {
                recommendation.selectedRecommendationToReport = nil
            }
        }.store(in: &readerSubscriptions)
    }

    func show(_ savedItem: SavedItemViewModel) {
        navigationController.pushViewController(
            ReadableHostViewController(readableViewModel: savedItem),
            animated: !isResetting
        )

        savedItem.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        savedItem.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readerSubscriptions)

        savedItem.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &readerSubscriptions)

        savedItem.$isPresentingReaderSettings.sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: savedItem)
        }.store(in: &readerSubscriptions)
    }

    func report(_ recommendation: Recommendation?, _ completion: @escaping () -> Void) {
        guard !isResetting, let recommendation = recommendation else {
            return
        }

        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            tracker: tracker.childTracker(hosting: .reportDialog),
            onDismiss: completion
        )

        host.modalPresentationStyle = .formSheet
        viewController.present(host, animated: !isResetting)
    }

    func show(_ seeAll: SeeAll?) {
        switch seeAll {
        case .myList:
            delegate?.compactHomeCoordinatorDidSelectRecentSaves(self)
        case .slate(let slateViewModel):
            show(slateViewModel)
        default:
            return
        }
    }

    private func present(activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)

        // Prevent a crash if you switch from compact to regular while sharing
        activityVC.popoverPresentationController?.sourceView = navigationController.splitViewController?.view

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.selectedSlateDetailViewModel?.selectedReadableViewModel?.sharedActivity = nil
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

        // iPhone (Portrait): defaults to .medium(); iPhone (Landscape): defaults to .large(); iPad (All): Menu
        // By setting `prefersEdgeAttachedInCompactHeight` and `widthFollowsPreferredContentSizeWhenEdgeAttached`,
        // landscape (iPhone) provides a non-fullscreen view that is dismissable by the user.
        let detents: [UISheetPresentationController.Detent] = [.medium(), .large()]
        readerSettingsVC.sheetPresentationController?.detents = detents
        readerSettingsVC.sheetPresentationController?.prefersGrabberVisible = true
        readerSettingsVC.sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
        readerSettingsVC.sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = true

        viewController.present(readerSettingsVC, animated: !isResetting)
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        viewController.present(UIAlertController(alert), animated: !isResetting)
    }
}

extension CompactHomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === homeViewController {
            model.selectedRecommendationToReport = nil
            model.selectedSlateDetailViewModel = nil
        }

        if viewController is SlateDetailViewController {
            model.selectedSlateDetailViewModel?.selectedReadableViewModel = nil
            model.selectedSlateDetailViewModel?.selectedRecommendationToReport = nil
        }
    }
}

extension CompactHomeCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.selectedSlateDetailViewModel?.selectedReadableViewModel?.presentedWebReaderURL = nil
    }
}
