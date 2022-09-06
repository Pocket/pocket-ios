import UIKit
import Combine
import SafariServices
import Analytics
import Sync

// swiftlint:disable:next class_delegate_protocol
protocol RegularHomeCoordinatorDelegate: ModalContentPresenting {
    func homeCoordinatorDidSelectMyList(_ coordinator: RegularHomeCoordinator)
    func homeCoordinator(_ coordinator: RegularHomeCoordinator, didSelectReadableType readableType: ReadableType?)
    func homeCoordinator(_ coordinator: RegularHomeCoordinator, didSelectRecommendation recommendation: RecommendationViewModel?)
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
    private var subscriptions: [AnyCancellable] = []
    private var slateDetailSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

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
            self?.present(url)
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
            self?.present(url)
        }.store(in: &slateDetailSubscriptions)

        slate.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &slateDetailSubscriptions)

        let slateDetailVC = SlateDetailViewController(model: slate)
        navigationController.pushViewController(slateDetailVC, animated: !isResetting)
    }
}

// MARK: - Showing reader content
extension RegularHomeCoordinator {
    private func show(_ readable: ReadableType?) {
        delegate?.homeCoordinator(self, didSelectReadableType: readable)
    }

    private func show(_ readable: RecommendationViewModel?) {
        delegate?.homeCoordinator(self, didSelectRecommendation: readable)
    }
}

// MARK: - Presenting modals
extension RegularHomeCoordinator {
    private func report(_ recommendation: Recommendation?) {
        delegate?.report(recommendation)
    }

    private func present(_ url: URL?) {
        delegate?.present(url)
    }

    private func present(_ alert: PocketAlert?) {
        delegate?.present(alert)
    }

    private func share(_ activity: PocketActivity?) {
        delegate?.share(activity)
    }
}

// MARK: - UINavigationControllerDelegate
extension RegularHomeCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController === homeViewController {
            slateDetailSubscriptions = []
            model.clearTappedSeeAll()
        }
    }
}
