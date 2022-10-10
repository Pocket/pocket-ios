import UIKit
import Combine
import Sync
import Analytics
import BackgroundTasks
import SafariServices
import SwiftUI
import Textile

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
    private let tracker: Tracker

    init(tracker: Tracker, model: HomeViewModel) {
        self.tracker = tracker
        self.model = model

        homeViewController = HomeViewController(model: model)
        navigationController = UINavigationController(rootViewController: homeViewController)

        super.init()

        navigationController.delegate = self
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
    }

    func observeModelChanges() {
        navigationController.popToRootViewController(animated: false)
        isResetting = true

        model.$selectedReadableType.sink { [weak self] readableType in
            self?.show(readableType)
        }.store(in: &subscriptions)

        model.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
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

        model.$tappedSeeAll.sink { [weak self] seeAll in
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

    func show(_ readableType: ReadableType?) {
        switch readableType {
        case .savedItem(let viewModel):
            show(viewModel)
        case .recommendation(let viewModel):
            show(viewModel)
        case .none:
            readerSubscriptions = []
        }
    }

    func show(_ viewModel: SlateDetailViewModel?) {
        slateDetailSubscriptions = []

        guard let viewModel = viewModel else {
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
            self?.report(recommendation)
        }.store(in: &slateDetailSubscriptions)

        viewModel.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url)
        }.store(in: &slateDetailSubscriptions)

        viewModel.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &slateDetailSubscriptions)
    }

    func show(_ recommendation: RecommendationViewModel?) {
        readerSubscriptions = []
        guard let recommendation = recommendation else {
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
            self?.report(selected)
        }.store(in: &readerSubscriptions)

        recommendation.events.sink { [weak self] event in
            switch event {
                case .contentUpdated:
                    break
                case .archive, .delete:
                    self?.navigationController.popViewController(animated: true)
            }
        }.store(in: &readerSubscriptions)
    }

    func show(_ savedItem: SavedItemViewModel) {
        readerSubscriptions = []

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

        savedItem.$presentedAddTags.sink { [weak self] addTagsViewModel in
            self?.present(addTagsViewModel)
        }.store(in: &readerSubscriptions)

        savedItem.events.sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.navigationController.popViewController(animated: true)
            }
        }.store(in: &readerSubscriptions)
    }

    func report(_ recommendation: Recommendation?) {
        guard !isResetting, let recommendation = recommendation else {
            return
        }

        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            tracker: tracker.childTracker(hosting: .reportDialog),
            onDismiss: { [weak self] in self?.model.clearRecommendationToReport() }
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
            self?.model.clearSharedActivity()
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

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) { [weak self] in
            self?.model.clearIsPresentingReaderSettings()
        }
        readerSettingsVC.configurePocketDefaultDetents()
        viewController.present(readerSettingsVC, animated: !isResetting)
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        viewController.present(UIAlertController(alert), animated: !isResetting)
    }

    func present(_ viewModel: PocketAddTagsViewModel?) {
        guard !isResetting, let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        viewController.present(hostingController, animated: !isResetting)
    }
}

extension CompactHomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // By default, when pushing the reader, switching to landscape, and popping,
        // the list will remain in landscape despite only supporting portrait.
        // We have to programatically force the device orientation back to portrait,
        // if the view controller we want to show _only_ supports portrait
        // (e.g when popping from the reader).
        if viewController.supportedInterfaceOrientations == .portrait, UIDevice.current.orientation.isLandscape {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === homeViewController {
            slateDetailSubscriptions = []
            model.clearTappedSeeAll()
            model.clearSelectedItem()
        }

        if viewController is SlateDetailViewController {
            model.clearRecommendationToReport()
            model.tappedSeeAll?.clearSelectedItem()
        }
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard navigationController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return navigationController.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }
}

extension CompactHomeCoordinator: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}
