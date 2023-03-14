import UIKit
import Sync
import Kingfisher
import Textile
import Analytics
import Combine
import SwiftUI
import BackgroundTasks
import Lottie
import SafariServices

@MainActor
struct HomeViewControllerSwiftUI: UIViewControllerRepresentable {
    var model: MainViewModel

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> HomeViewController {
        let v = HomeViewController(model: model)

        return v
    }

    func updateUIViewController(_ uiViewController: HomeViewController, context: UIViewControllerRepresentableContext<Self>) {
    }
}

class HomeViewController: UIViewController {
    private let homeModel: HomeViewModel
    private let model: MainViewModel

    private let sectionProvider: HomeViewControllerSectionProvider
    private var subscriptions: [AnyCancellable] = []
    private var readerSubscriptions: [AnyCancellable] = []
    private var slateDetailSubscriptions: [AnyCancellable] = []
    private var isResetting: Bool = false

    private lazy var layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
        guard let self = self,
              let section = self.dataSource.sectionIdentifier(for: sectionIndex) else {
                  return nil
              }

        switch section {
        case .loading:
            return self.sectionProvider.loadingSection()
        case .recentSaves:
            return self.sectionProvider.recentSavesSection(in: self.homeModel, env: env)
        case .slateHero(let slateID):
            return self.sectionProvider.heroSection(for: slateID, in: self.homeModel, env: env)
        case .slateCarousel(let slateID):
            return self.sectionProvider.additionalRecommendationsSection(for: slateID, in: self.homeModel, env: env)
        case .offline:
            let hasRecentSaves = self.dataSource.index(for: .recentSaves) != nil
            return self.sectionProvider.offlineSection(environment: env, withRecentSaves: hasRecentSaves)
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<HomeViewModel.Section, HomeViewModel.Cell>!

    private lazy var collectionView: UICollectionView = {
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()

    private lazy var overscrollView: EndOfFeedAnimationView = {
        let view = EndOfFeedAnimationView(frame: .zero)
        view.accessibilityIdentifier = "slate-detail-overscroll"
        view.alpha = 0
        view.attributedText = NSAttributedString(
            string: L10n.youReAllCaughtUpCheckBackLaterForMore,
            style: .overscroll
        )
        return view
    }()

    private var overscrollTopConstraint: NSLayoutConstraint?
    private var overscrollOffset = 0

    init(model: MainViewModel) {
        self.model = model
        self.homeModel = model.home

        self.sectionProvider = HomeViewControllerSectionProvider()

        super.init(nibName: nil, bundle: nil)

        dataSource = UICollectionViewDiffableDataSource<HomeViewModel.Section, HomeViewModel.Cell>(collectionView: collectionView) { [unowned self] _, indexPath, item in
            return self.cellFor(item, at: indexPath)
        }

        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            return self.viewForSupplementaryElement(ofKind: kind, at: indexPath)
        }

        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.register(cellClass: LoadingCell.self)
        collectionView.register(cellClass: RecommendationCell.self)
        collectionView.register(cellClass: RecentSavesItemCell.self)
        collectionView.register(cellClass: RecommendationCarouselCell.self)
        collectionView.register(cellClass: ItemsListOfflineCell.self)
        collectionView.register(cellClass: RecommendationCellHeroWide.self)
        collectionView.register(viewClass: SectionHeaderView.self, forSupplementaryViewOfKind: SectionHeaderView.kind)
        collectionView.delegate = self

        let action = UIAction { [weak self] _ in
            self?.handleRefresh(isForced: true)
        }

        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: action)

        navigationItem.title = L10n.home
        collectionView.publisher(for: \.contentSize, options: [.new]).sink { [weak self] contentSize in
            self?.setupOverflowView(contentSize: contentSize)
        }.store(in: &subscriptions)

        collectionView.publisher(for: \.contentOffset, options: [.new]).sink { [weak self] contentOffset in
            self?.updateOverflowView(contentOffset: contentOffset)
        }.store(in: &subscriptions)

        homeModel.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            }.store(in: &subscriptions)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.delegate = self
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "home"

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)

        overscrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overscrollView)
        overscrollTopConstraint = overscrollView.topAnchor.constraint(equalTo: collectionView.bottomAnchor)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overscrollTopConstraint!,
            overscrollView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            overscrollView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            overscrollView.heightAnchor.constraint(equalToConstant: 96)
        ])

        homeModel.fetch()
        handleRefresh()
        self.observeModelChanges()
    }

    private func handleRefresh(isForced: Bool = false) {
        homeModel.refresh(isForced: isForced) { [weak self] in
            DispatchQueue.main.async {
                if self?.collectionView.refreshControl?.isRefreshing == true {
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }

    func handleBackgroundRefresh(task: BGTask) {
        homeModel.refresh {
            task.setTaskCompleted(success: true)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }
}

extension HomeViewController {
    func cellFor(_ item: HomeViewModel.Cell, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .loading:
            let cell: LoadingCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case .recentSaves(let objectID):
            let cell: RecentSavesItemCell = collectionView.dequeueCell(for: indexPath)
            guard let viewModel = homeModel.recentSavesViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        case .recommendationHero(let objectID):
            if sectionProvider.shouldUseWideLayout(traitCollection: traitCollection) {
                let cell: RecommendationCellHeroWide = collectionView.dequeueCell(for: indexPath)
                guard let viewModel = homeModel.recommendationHeroWideViewModel(for: objectID, at: indexPath) else {
                    return cell
                }

                cell.configure(model: viewModel)
                return cell
            } else {
                let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
                guard let viewModel = homeModel.recommendationHeroViewModel(for: objectID, at: indexPath) else {
                    return cell
                }

                cell.configure(model: viewModel)
                return cell
            }
        case .recommendationCarousel(let objectID):
            let cell: RecommendationCarouselCell = collectionView.dequeueCell(for: indexPath)
            guard let viewModel = homeModel.recommendationCarouselViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        case .offline:
            let cell: ItemsListOfflineCell = collectionView.dequeueCell(for: indexPath)
            return cell
        }
    }

    func viewForSupplementaryElement(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case SectionHeaderView.kind:
            let header: SectionHeaderView = collectionView.dequeueReusableView(
                forSupplementaryViewOfKind: kind, for: indexPath
            )

            if let section = dataSource.sectionIdentifier(for: indexPath.section),
               let viewModel = homeModel.sectionHeaderViewModel(for: section) {
                header.configure(model: viewModel)
            }

            return header
        default:
            fatalError("Unknown supplementary view kind: \(kind)")
        }
    }

    private func setupOverflowView(contentSize: CGSize) {
        let shouldHide = contentSize.height <= collectionView.frame.height
        overscrollView.isHidden = shouldHide
    }

    private func updateOverflowView(contentOffset: CGPoint) {
        guard collectionView.contentSize.height > collectionView.frame.height else {
            return
        }

        let visibleHeight = round(
            collectionView.frame.height
            - collectionView.adjustedContentInset.top
            - collectionView.adjustedContentInset.bottom
        )
        let yOffset = round(contentOffset.y + collectionView.adjustedContentInset.top)
        let overscroll = max(-round(collectionView.contentSize.height - yOffset - visibleHeight), 0)

        if overscroll > 0 {
            let constant = overscroll + collectionView.adjustedContentInset.bottom
            overscrollTopConstraint?.constant = -constant
            overscrollView.alpha = min(overscroll / 96, 1)

            if !overscrollView.didFinishPreviousAnimation {
                overscrollView.isAnimating = true
            }
        }

        if overscroll == 0 {
            if overscrollView.didFinishPreviousAnimation {
                overscrollView.isAnimating = false
            }
        }
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        homeModel.willDisplay(cell, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        homeModel.select(cell: cell, at: indexPath)
    }
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}

// Coordinator logix

extension HomeViewController {
    func observeModelChanges() {
        navigationController?.popToRootViewController(animated: false)
        isResetting = true

        homeModel.$selectedReadableType.sink { [weak self] readableType in
            self?.show(readableType)
        }.store(in: &subscriptions)

        homeModel.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &subscriptions)

        homeModel.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &subscriptions)

        homeModel.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &subscriptions)

        homeModel.$tappedSeeAll.sink { [weak self] seeAll in
            self?.show(seeAll)
        }.store(in: &subscriptions)
        isResetting = false
        navigationController?.delegate = self
    }
}

extension HomeViewController {
    func show(_ readableType: ReadableType?) {
        switch readableType {
        case .savedItem(let viewModel):
            show(viewModel)
        case .recommendation(let viewModel):
            show(viewModel)
        case .webViewRecommendation(let viewModel):
            showRecommendation(forWebView: viewModel)
            present(url: viewModel.url)
        case .webViewSavedItem(let viewModel):
            showSavedItem(forWebView: viewModel)
            present(url: viewModel.url)
        case .none:
            readerSubscriptions = []
        }
    }

    func show(_ viewModel: SlateDetailViewModel?) {
        slateDetailSubscriptions = []

        guard let viewModel = viewModel else {
            return
        }

        navigationController?.pushViewController(
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

        navigationController?.pushViewController(
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
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    func show(_ savedItem: SavedItemViewModel) {
        readerSubscriptions = []

        navigationController?.pushViewController(
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
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    private func showRecommendation(forWebView viewModel: RecommendationViewModel) {
        viewModel.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        viewModel.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation)
        }.store(in: &readerSubscriptions)

        viewModel.events.sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    private func showSavedItem(forWebView viewModel: SavedItemViewModel) {
        viewModel.$presentedAlert.sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        viewModel.events.sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    func report(_ recommendation: Recommendation?) {
        guard !isResetting, let recommendation = recommendation else {
            return
        }

        let host = ReportRecommendationHostingController(
            recommendation: recommendation,
            tracker: Services.shared.tracker.childTracker(hosting: .reportDialog),
            onDismiss: { [weak self] in self?.homeModel.clearRecommendationToReport() }
        )

        host.modalPresentationStyle = .formSheet
        guard let presentedVC = self.parent?.presentedViewController else {
            self.parent?.present(host, animated: !isResetting)
            return
        }
        presentedVC.present(host, animated: !isResetting)
    }

    func show(_ seeAll: SeeAll?) {
        switch seeAll {
        case .saves:
             showSaves()
        case .slate(let slateViewModel):
            show(slateViewModel)
        default:
            return
        }
    }

    private func showSaves() {
        // Ensure our model updates to the saves tab
        self.model.selectSavesTab()

//        // If we don't have a tab bar, we need to push Saves from this view.
//        guard tabBarController != nil else {
//            navigationController?.pushViewController(SavesContainerViewController(model: self.model.saves)
// , animated: animated)
//            return
//        }
    }

    private func present(activity: PocketActivity?) {
        guard !isResetting, let activity = activity else { return }

        let activityVC = UIActivityViewController(activity: activity)

        activityVC.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.homeModel.clearSharedActivity()
        }

        self.present(activityVC, animated: !isResetting)
    }

    private func present(url: URL?) {
        guard !isResetting, let url = url else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: !isResetting)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard !isResetting, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) { [weak self] in
            self?.homeModel.clearIsPresentingReaderSettings()
        }
        readerSettingsVC.configurePocketDefaultDetents()
                self.present(readerSettingsVC, animated: !isResetting)
    }

    private func present(alert: PocketAlert?) {
        guard !isResetting, let alert = alert else { return }
        guard let presentedVC = self.presentedViewController else {
            self.present(UIAlertController(alert), animated: !isResetting)
            return
        }
        presentedVC.present(UIAlertController(alert), animated: !isResetting)
    }

    func present(_ viewModel: PocketAddTagsViewModel?) {
        guard !isResetting, let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
                self.present(hostingController, animated: !isResetting)
    }
}

extension HomeViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return homeModel.activityItemsForSelectedItem(url: URL)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        homeModel.clearPresentedWebReaderURL()
    }
}

extension HomeViewController: UINavigationControllerDelegate {
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
        if viewController === self {
            slateDetailSubscriptions = []
            homeModel.clearTappedSeeAll()
            homeModel.clearSelectedItem()
        }

        if viewController is SlateDetailViewController {
            homeModel.clearRecommendationToReport()
            homeModel.tappedSeeAll?.clearSelectedItem()
        }
    }

    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard navigationController.traitCollection.userInterfaceIdiom == .phone else { return .all }
        return navigationController.visibleViewController?.supportedInterfaceOrientations ?? .portrait
    }

    private func popToPreviousScreen() {
        if let presentedVC = navigationController?.presentedViewController {
            presentedVC.dismiss(animated: true) { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
}
