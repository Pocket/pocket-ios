// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Analytics
import Combine
import SwiftUI
import BackgroundTasks
import Lottie
import SafariServices
import Localization
import SharedPocketKit

struct HomeViewControllerSwiftUI: UIViewControllerRepresentable {
    var model: HomeViewModel

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> UINavigationController {
        let homeViewController = HomeViewController(model: model)
        homeViewController.updateHeroCardCount()
        let navigationController = UINavigationController(rootViewController: homeViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.barTintColor = UIColor(.ui.white1)
        navigationController.navigationBar.tintColor = UIColor(.ui.grey1)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: UIViewControllerRepresentableContext<Self>) {
    }
}

class HomeViewController: UIViewController {
    private let model: HomeViewModel
    private let sectionProvider: HomeViewControllerSectionProvider
    private var subscriptions: [AnyCancellable] = []
    private var slateDetailSubscriptions: [AnyCancellable] = []
    private var collectionSubscriptions: [AnyCancellable] = []
    private var readerSubscriptions: [AnyCancellable] = []

    private lazy var layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
        guard let self = self,
              let section = self.dataSource.sectionIdentifier(for: sectionIndex) else {
                  return nil
              }

        switch section {
        case .loading:
            return self.sectionProvider.loadingSection()
        case .recentSaves:
            return self.sectionProvider.recentSavesSection(in: self.model, env: env)
        case .slateHero(let slateID):
            return self.sectionProvider.heroSection(for: slateID, in: self.model, env: env)
        case .slateCarousel(let slateID):
            return self.sectionProvider.additionalRecommendationsSection(for: slateID, in: self.model, env: env)
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
            string: Localization.youReAllCaughtUpCheckBackLaterForMore,
            style: .overscroll
        )
        return view
    }()

    private var overscrollTopConstraint: NSLayoutConstraint?
    private var overscrollOffset = 0

    init(model: HomeViewModel) {
        self.model = model

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
        collectionView.register(viewClass: SectionHeaderView.self, forSupplementaryViewOfKind: SectionHeaderView.kind)
        collectionView.delegate = self

        let action = UIAction { [weak self] _ in
            self?.handleRefresh(isForced: true)
        }

        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: action)

        navigationItem.title = Localization.home
        collectionView
            .publisher(for: \.contentSize, options: [.new])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contentSize in
            self?.setupOverflowView(contentSize: contentSize)
        }.store(in: &subscriptions)

        collectionView
            .publisher(for: \.contentOffset, options: [.new])
            .receive(on: DispatchQueue.main)
            .sink { [weak self] contentOffset in
            self?.updateOverflowView(contentOffset: contentOffset)
        }.store(in: &subscriptions)

        model.$snapshot
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                self?.dataSource.apply(snapshot)
            }.store(in: &subscriptions)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "home"
        observeModelChanges()

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

        model.fetch()
        handleRefresh()
    }

    private func handleRefresh(isForced: Bool = false) {
        model.refresh(isForced: isForced) { [weak self] in
            DispatchQueue.main.async {
                if self?.collectionView.refreshControl?.isRefreshing == true {
                    self?.collectionView.refreshControl?.endRefreshing()
                }
            }
        }
    }

    func handleBackgroundRefresh(task: BGTask) {
        model.refresh {
            task.setTaskCompleted(success: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        model.refresh { }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateHeroCardCount()
    }

    func updateHeroCardCount() {
        if traitCollection.shouldUseWideLayout() {
            self.model.numberOfHeroItems = 2
        } else {
            self.model.numberOfHeroItems = 1
        }
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
            guard let viewModel = model.recentSavesViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        case .recommendationHero(let objectID):
            let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
            guard let viewModel = model.recommendationHeroViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        case .recommendationCarousel(let objectID):
            let cell: RecommendationCarouselCell = collectionView.dequeueCell(for: indexPath)
            guard let viewModel = model.recommendationCarouselViewModel(for: objectID, at: indexPath) else {
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
               let viewModel = model.sectionHeaderViewModel(for: section) {
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

        model.willDisplay(cell, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.select(cell: cell, at: indexPath)
    }
}

extension HomeViewController {
    func observeModelChanges() {
        model.$selectedReadableType.sink { [weak self] readableType in
            self?.show(readableType)
        }.store(in: &subscriptions)

        model.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation?.item.givenURL)
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
    }

    func show(_ readableType: ReadableType?) {
        switch readableType {
        case .savedItem(let viewModel):
            show(viewModel)
        case .recommendation(let viewModel):
            show(viewModel)
        case .webViewRecommendation(let viewModel):
            showRecommendation(forWebView: viewModel)
            // Since the view model is not publishing a direct request to present a url (e.g presentedWebReaderURL),
            // we'll utilize its premium url to present a premium Pocket web page as necessary
            present(url: viewModel.premiumURL)
        case .webViewSavedItem(let viewModel):
            showSavedItem(forWebView: viewModel)
            // Since the view model is not publishing a direct request to present a url (e.g presentedWebReaderURL),
            // we'll utilize its premium url to present a premium Pocket web page as necessary
            present(url: viewModel.premiumURL)
        case .none:
            readerSubscriptions = []
        case .collection(let viewModel):
            showCollection(viewModel)
        }
    }

    func show(_ viewModel: SlateDetailViewModel?) {
        slateDetailSubscriptions = []

        guard let viewModel = viewModel else {
            return
        }

        navigationController?.pushViewController(
            SlateDetailViewController(model: viewModel),
            animated: true
        )

        viewModel.$selectedReadableViewModel.sink { [weak self] readable in
            self?.show(readable)
        }.store(in: &slateDetailSubscriptions)

        viewModel.$selectedRecommendationToReport.sink { [weak self] recommendation in
            self?.report(recommendation?.item.givenURL)
        }.store(in: &slateDetailSubscriptions)

        viewModel.$presentedWebReaderURL.sink { [weak self] url in
            self?.present(url: url?.absoluteString)
        }.store(in: &slateDetailSubscriptions)

        viewModel.$sharedActivity.sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &slateDetailSubscriptions)
        viewModel.$selectedCollectionViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModel in
            guard let viewModel else { return }
                self?.showCollection(viewModel)
            }
            .store(in: &slateDetailSubscriptions)
    }

    func show(_ recommendation: RecommendationViewModel?) {
        readerSubscriptions = []
        guard let recommendation = recommendation else {
            return
        }

        navigationController?.pushViewController(
            ReadableHostViewController(readableViewModel: recommendation),
            animated: true
        )

        recommendation.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        recommendation.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readerSubscriptions)

        recommendation.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url?.absoluteString)
        }.store(in: &readerSubscriptions)

        recommendation.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: recommendation)
        }.store(in: &readerSubscriptions)

        recommendation.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] selected in
            self?.report(selected?.item.givenURL)
        }.store(in: &readerSubscriptions)

        recommendation.events.receive(on: DispatchQueue.main).sink { [weak self] event in
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
            animated: true
        )

        savedItem.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        savedItem.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &readerSubscriptions)

        savedItem.$presentedWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url?.absoluteString)
        }.store(in: &readerSubscriptions)

        savedItem.$isPresentingReaderSettings.receive(on: DispatchQueue.main).sink { [weak self] isPresenting in
            self?.presentReaderSettings(isPresenting, on: savedItem)
        }.store(in: &readerSubscriptions)

        savedItem.$presentedAddTags.receive(on: DispatchQueue.main).sink { [weak self] addTagsViewModel in
            self?.present(addTagsViewModel)
        }.store(in: &readerSubscriptions)

        savedItem.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    private func showCollection(_ viewModel: CollectionViewModel) {
        let controller = CollectionViewController(model: viewModel)
        navigationController?.pushViewController(controller, animated: true)

        viewModel.$presentedStoryWebReaderURL.receive(on: DispatchQueue.main).sink { [weak self] url in
            self?.present(url: url?.absoluteString)
        }.store(in: &collectionSubscriptions)

        viewModel.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &collectionSubscriptions)

        viewModel.$presentedAddTags.receive(on: DispatchQueue.main).sink { [weak self] addTagsViewModel in
            self?.present(addTagsViewModel)
        }.store(in: &collectionSubscriptions)

        viewModel.$sharedActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &collectionSubscriptions)

        viewModel.$selectedCollectionItemToReport.receive(on: DispatchQueue.main).sink { [weak self] item in
            self?.report(item?.givenURL)
        }.store(in: &collectionSubscriptions)

        viewModel.$events.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event {
            case .contentUpdated, .none:
                break
            case .archive, .delete:
                self?.popToPreviousScreen()
            }
        }.store(in: &collectionSubscriptions)

        viewModel.$selectedItem.receive(on: DispatchQueue.main).sink { [weak self] readableType in
            switch readableType {
            case .collection(let collection):
                self?.showCollection(collection)
            case .savedItem(let savedItem):
                self?.show(savedItem)
            case .recommendation(let recommendation):
                self?.show(recommendation)
            default:
                break
            }
        }.store(in: &collectionSubscriptions)

        // MARK: Story Presentation
        viewModel.$presentedStoryWebReaderURL.sink { [weak self] url in
            self?.present(url: url?.absoluteString)
        }.store(in: &collectionSubscriptions)

        viewModel.$sharedStoryActivity.receive(on: DispatchQueue.main).sink { [weak self] activity in
            self?.present(activity: activity)
        }.store(in: &collectionSubscriptions)

        viewModel.$selectedStoryToReport.receive(on: DispatchQueue.main).sink { [weak self] item in
            self?.report(item?.givenURL)
        }.store(in: &collectionSubscriptions)
    }

    private func showRecommendation(forWebView viewModel: RecommendationViewModel) {
        viewModel.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        viewModel.$selectedRecommendationToReport.receive(on: DispatchQueue.main).sink { [weak self] recommendation in
            self?.report(recommendation?.item.givenURL)
        }.store(in: &readerSubscriptions)

        viewModel.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    private func showSavedItem(forWebView viewModel: SavedItemViewModel) {
        viewModel.$presentedAlert.receive(on: DispatchQueue.main).sink { [weak self] alert in
            self?.present(alert: alert)
        }.store(in: &readerSubscriptions)

        viewModel.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            switch event {
            case .contentUpdated:
                break
            case .archive, .delete:
                self?.popToPreviousScreen()
            }
        }.store(in: &readerSubscriptions)
    }

    func report(_ givenURL: String?) {
        guard let givenURL else {
            return
        }

        let host = ReportRecommendationHostingController(
            givenURL: givenURL,
            tracker: model.tracker.childTracker(hosting: .reportDialog),
            onDismiss: { [weak self] in self?.model.clearRecommendationToReport() }
        )

        host.modalPresentationStyle = .formSheet
        guard let presentedVC = self.presentedViewController else {
            self.present(host, animated: true)
            return
        }
        presentedVC.present(host, animated: true)
    }

    func show(_ seeAll: SeeAll?) {
        switch seeAll {
        case .saves:
            self.tabBarController?.selectedIndex = 1
        case .slate(let slateViewModel):
            show(slateViewModel)
        default:
            return
        }
    }

    private func present(activity: PocketActivity?) {
        guard true, let activity = activity else { return }

       let activityVC = ShareSheetController(activity: activity, completion: { [weak self] _, _, _, _ in
                             self?.model.clearSharedActivity()
                         })
        activityVC.modalPresentationStyle = .formSheet

        self.present(activityVC, animated: true)
    }

    private func present(url: String?) {
        guard let string = url, let url = URL(percentEncoding: string) else { return }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard true, isPresenting == true, let readable = readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) { [weak self] in
            self?.model.clearIsPresentingReaderSettings()
        }
        readerSettingsVC.configurePocketDefaultDetents()
        self.present(readerSettingsVC, animated: true)
    }

    private func present(alert: PocketAlert?) {
        guard true, let alert = alert else { return }
        guard let presentedVC = self.presentedViewController else {
            self.present(UIAlertController(alert), animated: true)
            return
        }
        presentedVC.present(UIAlertController(alert), animated: true)
    }

    func present(_ viewModel: PocketAddTagsViewModel?) {
        guard true, let viewModel = viewModel else { return }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        self.present(hostingController, animated: true)
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

extension HomeViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return model.activityItemsForSelectedItem(url: URL)
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        model.clearPresentedWebReaderURL()
    }
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
