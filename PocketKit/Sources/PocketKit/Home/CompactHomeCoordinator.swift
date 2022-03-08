import UIKit
import Combine
import Sync
import Analytics
import BackgroundTasks
import SafariServices


class CompactHomeCoordinator: NSObject {
    var viewController: UIViewController {
        return navigationController
    }

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

        homeViewController = HomeViewController(source: source, tracker: tracker, model: model)
        navigationController = UINavigationController(rootViewController: homeViewController)

        super.init()

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }

    func observeModelChanges() {
        navigationController.popToRootViewController(animated: false)
        isResetting = true

        model.$selectedReadableViewModel.receive(on: DispatchQueue.main).sink { [weak self] readable in
            self?.show(readable)
        }.store(in: &subscriptions)

        model.$selectedSlateDetail.receive(on: DispatchQueue.main).sink { [weak self] slate in
            self?.show(slate)
        }.store(in: &subscriptions)

        model.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &subscriptions)

        model.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url)
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

    func show(_ slate: SlateDetailViewModel?) {
        guard let slate = slate else {
            slateDetailSubscriptions = []
            return
        }

        navigationController.pushViewController(
            SlateDetailViewController(
                source: source,
                model: slate,
                tracker: tracker.childTracker(hosting: .slateDetail.screen)
            ),
            animated: !isResetting
        )

        slate.$selectedReadableViewModel.receive(on: DispatchQueue.main).sink { [weak self] readable in
            self?.show(readable)
        }.store(in: &slateDetailSubscriptions)

        slate.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &slateDetailSubscriptions)

        slate.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
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

        recommendation.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readerSubscriptions)

        recommendation.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &readerSubscriptions)

        recommendation.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: recommendation)
        }.store(in: &readerSubscriptions)
    }

    func report(_ recommendation: Slate.Recommendation?) {
        guard !isResetting, let recommendation = recommendation else {
            return
        }

        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            tracker: tracker.childTracker(hosting: .reportDialog)
        ) { [weak self] in
            self?.model.selectedRecommendationToReport = nil
            self?.model.selectedSlateDetail?.selectedRecommendationToReport = nil
        }

        host.modalPresentationStyle = .formSheet
        viewController.present(host, animated: !isResetting)
    }

    private func present(activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)

        // Prevent a crash if you switch from compact to regular while sharing
        activityVC.popoverPresentationController?.sourceView = navigationController.splitViewController?.view

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.model.selectedReadableViewModel?.sharedActivity = nil
            self?.model.selectedSlateDetail?.selectedReadableViewModel?.sharedActivity = nil
        }

        viewController.present(activityVC, animated: !isResetting)
    }

    private func present(url: URL?) {
        guard !isResetting, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        viewController.present(safariVC, animated: !isResetting)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on recommendation: RecommendationViewModel?) {
        guard !isResetting, isPresenting == true, let recommendation = recommendation else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: recommendation.readerSettings) {
            recommendation.isPresentingReaderSettings = false
        }

        readerSettingsVC.modalPresentationStyle = .pageSheet
        readerSettingsVC.sheetPresentationController?.detents = [.medium()]

        viewController.present(readerSettingsVC, animated: !isResetting)
    }
}

extension CompactHomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === homeViewController {
            model.selectedReadableViewModel = nil
            model.selectedRecommendationToReport = nil
            model.selectedSlateDetail = nil
        }

        if viewController is SlateDetailViewController {
            model.selectedSlateDetail?.selectedReadableViewModel = nil
            model.selectedSlateDetail?.selectedRecommendationToReport = nil
        }
    }
}

extension CompactHomeCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.selectedReadableViewModel?.presentedWebReaderURL = nil
        model.selectedSlateDetail?.selectedReadableViewModel?.presentedWebReaderURL = nil
    }
}
