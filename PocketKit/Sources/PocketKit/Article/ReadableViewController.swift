// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Combine
import Analytics
import Localization
import Kingfisher
import SafariServices
import TipKit
import SharedPocketKit

@MainActor
protocol ReadableViewControllerDelegate: AnyObject {
    func readableViewController(_ controller: ReadableViewController, openURL url: URL)
    func readableViewController(_ controller: ReadableViewController, shareWithAdditionalText text: String?)
}

class ReadableViewController: UIViewController {
    private var metadata: ArticleMetadataPresenter?

    var presenters: [ArticleComponentPresenter]?

    var readableViewModel: ReadableViewModel {
        didSet {
            updateContent()
        }
    }

    weak var delegate: ReadableViewControllerDelegate?

    private var contexts: [Context] {
        let content = ContentContext(url: readableViewModel.url)
        return [content]
    }

    private let readerSettings: ReaderSettings

    private var subscriptions: [AnyCancellable] = []

    private var isReloading = false

    private var userScrollProgress: IndexPath?
    // Tippable view controller properties
    var tipObservationTask: Task<Void, Error>?
    weak var tipViewController: UIViewController?

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    private lazy var layout = UICollectionViewCompositionalLayout { [unowned self] in
        return self.buildSection(index: $0, environment: $1)
    }

    init(
        readable: ReadableViewModel,
        readerSettings: ReaderSettings
    ) {
        self.readerSettings = readerSettings
        self.readableViewModel = readable

        super.init(nibName: nil, bundle: nil)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.accessibilityIdentifier = "article-view"
        collectionView.register(cellClass: MarkdownComponentCell.self)
        collectionView.register(cellClass: ImageComponentCell.self)
        collectionView.register(cellClass: EmptyCell.self)
        collectionView.register(cellClass: ArticleMetadataCell.self)
        collectionView.register(cellClass: DividerComponentCell.self)
        collectionView.register(cellClass: CodeBlockComponentCell.self)
        collectionView.register(cellClass: UnsupportedComponentCell.self)
        collectionView.register(cellClass: BlockquoteComponentCell.self)
        collectionView.register(cellClass: YouTubeVideoComponentCell.self)
        collectionView.register(cellClass: VimeoComponentCell.self)
        collectionView.register(cellClass: ReaderSkeletonCell.self)
        navigationItem.largeTitleDisplayMode = .never

        self.readerSettings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.reload()
            }
        }.store(in: &subscriptions)

        readableViewModel.events.receive(on: DispatchQueue.main).sink { [weak self] event in
            guard case .contentUpdated = event else { return }
            self?.updateContent()
        }.store(in: &subscriptions)

        if let viewModel = readableViewModel as? SavedItemViewModel {
            // we only want highlights for saved items
            viewModel
                .$isPresentingHighlights
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    guard let self, isPresenting else {
                        return
                    }
                    let controller =
                    HighlightsViewController(
                        viewModel: viewModel
                    )
                    present(controller, animated: true)
                }
                .store(in: &subscriptions)
            viewModel
                .$highlightIndexPath
                .receive(on: DispatchSerialQueue.main)
                .sink { [weak self] indexPath in
                    guard let self, let indexPath else {
                        return
                    }
                    collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
                .store(in: &subscriptions)

            viewModel
                .$isPresentingPremiumUpsell
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    guard let self, isPresenting else {
                        return
                    }
                    self.present(viewModel.makePremiumUpgradeViewController(), animated: true)
                }
                .store(in: &subscriptions)

            viewModel
                .$isPresentingHooray
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    guard let self, isPresenting else {
                        return
                    }
                    self.present(viewModel.makeHoorayViewController(), animated: true)
                }
                .store(in: &subscriptions)

            viewModel
                .$presentedAlert
                .receive(on: DispatchQueue.main)
                .sink { [weak self] alert in
                    self?.present(alert: alert)
                }
                .store(in: &subscriptions)

            viewModel
                .$presentedWebReaderURL
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    self?.present(url: url)
                }
                .store(in: &subscriptions)

            viewModel
                .$sharedActivity
                .receive(on: DispatchQueue.main)
                .sink { [weak self] activity in
                    self?.present(activity: activity)
                }
                .store(in: &subscriptions)

            viewModel
                .$isPresentingReaderSettings
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    self?.presentReaderSettings(isPresenting, on: readable)
                }
                .store(in: &subscriptions)

            viewModel.$presentedAddTags.sink { [weak self] addTagsViewModel in
                self?.present(viewModel: addTagsViewModel)
            }.store(in: &subscriptions)

            viewModel.events.sink { [weak self] event in
                switch event {
                case .contentUpdated, .save:
                    break
                case .archive, .delete:
                    self?.popToPreviousScreen(navigationController: self?.navigationController)
                }
            }.store(in: &subscriptions)
        } else if let viewModel = readableViewModel as? RecommendableItemViewModel {
            viewModel
                .$presentedAlert
                .receive(on: DispatchQueue.main)
                .sink { [weak self] alert in
                    self?.present(alert: alert)
                }
                .store(in: &subscriptions)

            viewModel
                .$presentedWebReaderURL
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    self?.present(url: url)
                }
                .store(in: &subscriptions)

            viewModel
                .$presentedWebReaderURL
                .receive(on: DispatchQueue.main)
                .sink { [weak self] url in
                    self?.present(url: url)
                }
                .store(in: &subscriptions)

            viewModel
                .$sharedActivity
                .receive(on: DispatchQueue.main)
                .sink { [weak self] activity in
                    self?.present(activity: activity)
                }
                .store(in: &subscriptions)

            viewModel
                .$isPresentingReaderSettings
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    self?.presentReaderSettings(isPresenting, on: readable)
                }
                .store(in: &subscriptions)

            viewModel
                .$selectedItemToReport
                .receive(on: DispatchQueue.main)
                .sink { [weak self] selected in
                self?.report(selected?.givenURL, recommendationId: selected?.recommendation?.analyticsID)
            }
            .store(in: &subscriptions)
        }
    }

    private func report(_ givenURL: String?, recommendationId: String?) {
        guard let givenURL, let recommendationId else {
            return
        }

        let host = ReportRecommendationHostingController(
            givenURL: givenURL,
            recommendationId: recommendationId,
            tracker: readableViewModel.tracker,
            onDismiss: {}
        )

        host.modalPresentationStyle = .formSheet
        guard let presentedVC = self.presentedViewController else {
            self.present(host, animated: true)
            return
        }
        presentedVC.present(host, animated: true)
    }

    private func present(alert: PocketAlert?) {
        guard let alert = alert else { return }
        guard let presentedVC = self.presentedViewController else {
            self.present(UIAlertController(alert), animated: true)
            return
        }
        presentedVC.present(UIAlertController(alert), animated: true)
    }

    private func present(viewModel: PocketAddTagsViewModel?) {
        guard let viewModel else {
            return
        }
        let hostingController = UIHostingController(rootView: AddTagsView(viewModel: viewModel))
        hostingController.modalPresentationStyle = .formSheet
        self.present(hostingController, animated: true)
    }

    private func present(tagsFilterViewModel: TagsFilterViewModel?) {
        guard let tagsFilterViewModel else {
            return
        }
        let hostingController = UIHostingController(rootView: TagsFilterView(viewModel: tagsFilterViewModel).environment(\.managedObjectContext, Services.shared.source.viewContext))
        hostingController.configurePocketDefaultDetents()
        self.present(hostingController, animated: true)
    }

    private func present(activity: PocketActivity?) {
        guard let activity else {
            return
        }

        let activityVC = ShareSheetController(activity: activity, completion: nil)
         activityVC.modalPresentationStyle = .formSheet
        self.present(activityVC, animated: true)
    }

    private func present(url: URL?) {
        guard let url else {
            return
        }

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        self.present(safariVC, animated: true)
    }

    private func presentReaderSettings(_ isPresenting: Bool?, on readable: ReadableViewModel?) {
        guard isPresenting == true, let readable else {
            return
        }

        let readerSettingsVC = ReaderSettingsViewController(settings: readable.readerSettings) {}
        readerSettingsVC.configurePocketDefaultDetents()
        self.present(readerSettingsVC, animated: true)
    }

    func presentSortMenu(presentedSortFilterViewModel: SortMenuViewModel?) {
        guard let sortFilterVM = presentedSortFilterViewModel else {
            if navigationController?.presentedViewController is SortMenuViewController {
                navigationController?.dismiss(animated: true)
            }
            return
        }

        let viewController = SortMenuViewController(viewModel: sortFilterVM)
        viewController.configurePocketDefaultDetents()
        navigationController?.present(viewController, animated: true)
    }

    private func popToPreviousScreen(navigationController: UINavigationController?) {
        guard let navController = navigationController else {
            return
        }

        if let presentedVC = navController.presentedViewController {
            presentedVC.dismiss(animated: true) {
                navController.popToRootViewController(animated: true)
            }
        } else {
            navController.popViewController(animated: true)
        }
    }

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        readableViewModel.fetchDetailsIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollToLastKnownPosition()
        // do not vend the tip on syndicated articles
        if readableViewModel is SavedItemViewModel {
            PocketTipEvents.showSwipeHighlightsTip.sendDonation()
            displayTip(SwipeHighlightsTip(), configuration: nil, sourceView: nil)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // ensure on device rotate and change the view re-draws
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let userScrollProgress {
            readableViewModel.trackReadingProgress(index: userScrollProgress)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reload()
    }

    private func scrollToLastKnownPosition() {
        guard let userProgress = readableViewModel.readingProgress(),
              userProgress.section < collectionView.numberOfSections,
              userProgress.item < collectionView.numberOfItems(inSection: userProgress.section) else {
            return
        }

        collectionView.selectItem(at: userProgress, animated: true, scrollPosition: .centeredVertically)
        collectionView.setNeedsLayout()
    }

    private func reload() {
        guard !isReloading else { return }
        isReloading = true
        presenters?.forEach { $0.clearCache() }
        collectionView.reloadData()
        isReloading = false
    }

    private func updateContent() {
        metadata = ArticleMetadataPresenter(
            readableViewModel: readableViewModel,
            readerSettings: readerSettings
        )
        guard let components = readableViewModel.components else {
            return
        }
        presenters = components
            .enumerated()
            .filter { !$0.element.isEmpty }
            .map { presenter(for: $0.element, at: $0.offset) }

        presenters?.forEach {
            $0.loadContent()
        }
        fetchQuotes()
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

extension ReadableViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? YouTubeVideoComponentCell {
            cell.pause()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        userScrollProgress = collectionView.indexPathsForVisibleItems.sorted().first
    }
}

extension ReadableViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard metadata != nil, let presenters = presenters else {
            return 1 // loading section
        }

        return 1 + (presenters.isEmpty ? 0 : 1)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        guard metadata != nil, let presenters = presenters else {
            return 1 // loading item
        }

        switch section {
        case 0:
            return 1 // metadata section
        default:
            return presenters.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let metadata = metadata, let presenters = presenters else {
            let skeletonCell: ReaderSkeletonCell = collectionView.dequeueCell(for: indexPath)
            return skeletonCell
        }

        switch indexPath.section {
        case 0:
            let metaCell: ArticleMetadataCell = collectionView.dequeueCell(for: indexPath)
            metaCell.delegate = self

            metaCell.configure(model: .init(
                byline: metadata.attributedByline,
                publishedDate: metadata.attributedPublishedDate,
                title: metadata.attributedTitle
            ))

            return metaCell
        default:
            let onHighlight = readableViewModel.shouldAllowHighlights ? { [weak self] index, range, quote, text in
                guard let self, let viewModel = readableViewModel as? SavedItemViewModel else {
                    return
                }
                viewModel.saveHighlight(componentIndex: index, range: range, quote: quote, text: text)
            } : nil
            let cell = presenters[indexPath.item].cell(for: indexPath, in: collectionView, onHighlight: onHighlight)

            if let cell = cell as? ArticleComponentTextCell {
                cell.delegate = self
            }

            return cell
        }
    }
}

extension ReadableViewController: ArticleComponentTextCellDelegate {
    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
        didShareText selectedText: String?
    ) {
        delegate?.readableViewController(self, shareWithAdditionalText: selectedText)
    }

    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
        shouldOpenURL url: URL
    ) -> Bool {
        delegate?.readableViewController(self, openURL: url)
        return false
    }

    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
        contextMenuConfigurationForURL url: URL
    ) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: {
                SFSafariViewController(url: url)
            }
        ) { [weak self] _ in
            let actions = self?.readableViewModel.externalActions(for: url).compactMap { UIAction($0) }
            ?? []
            return UIMenu(
                title: url.host ?? "",
                children: actions
            )
        }
    }
}

extension ReadableViewController {
    enum Constants {
        static let metaSectionContentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 0,
            trailing: 20
        )

        static let contentSectionContentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
    }

    func buildSection(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        guard presenters != nil, metadata != nil else {
            return NSCollectionLayoutSection(
                group: NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(environment.container.effectiveContentSize.width)
                    ),
                    subitems: [
                        NSCollectionLayoutItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .estimated(environment.container.effectiveContentSize.width)
                            )
                        )
                    ]
                )
            )
        }

        switch index {
        case 0:
            let availableItemWidth = view.readableContentGuide.layoutFrame.width
            let height = metadata?.size(for: availableItemWidth).height ?? 1
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(height)
                ),
                subitems: [
                    NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                ]
            )

            let section = NSCollectionLayoutSection(group: group)
            // Zero out the default leading/trailing contentInsets, but preserve the default top/bottom values.
            // This ensures each section will be inset horizontally exactly to the readable content width.
            var contentInsets = section.contentInsets
            contentInsets.leading = readerSettings.margins
            contentInsets.trailing = readerSettings.margins
            contentInsets.top = Constants.metaSectionContentInsets.top
            contentInsets.bottom = Constants.metaSectionContentInsets.bottom
            section.contentInsets = contentInsets
            section.contentInsetsReference = .readableContent
            return section
        default:
            // for image presenters, calling size will set the image size used by Kingfisher
            if let imagePresenters = presenters?.compactMap({ $0 as? ImageComponentPresenter }) {
                let availableItemWidth = view.readableContentGuide.layoutFrame.width
                imagePresenters.forEach {
                    _ = $0.size(for: availableItemWidth)
                }
            }
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.backgroundColor = UIColor(.ui.white1)
            config.showsSeparators = false
            if readableViewModel.shouldAllowHighlights {
                config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                    guard let actions = buildSwipeActions(at: indexPath) else {
                        return nil
                    }
                    return UISwipeActionsConfiguration(actions: actions)
                }
            }
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)

            // Zero out the default leading/trailing contentInsets, but preserve the default top/bottom values.
            // This ensures each section will be inset horizontally exactly to the readable content width.
            var contentInsets = section.contentInsets
            contentInsets.leading = readerSettings.margins
            contentInsets.trailing = readerSettings.margins
            contentInsets.top = Constants.contentSectionContentInsets.top
            contentInsets.bottom = Constants.metaSectionContentInsets.bottom
            section.contentInsets = contentInsets
            section.contentInsetsReference = .readableContent
            return section
        }
    }

    /// Builds the swipe actions for the given indexPath
    /// - Parameter indexPath: the given indexPath
    private func buildSwipeActions(at indexPath: IndexPath) -> [UIContextualAction]? {
        guard let presenter = presenters?[safe: indexPath.item],
              let currentCell = self.collectionView.cellForItem(at: indexPath) as? ArticleComponentTextCell else {
            return nil
        }

        var actions = [UIContextualAction]()

        if !currentCell.isFullyHighlighted {
            actions.append(highlightAllAction(presenter, currentCell))
        }
        if let highlightIndexes = presenter.highlightIndexes, !highlightIndexes.isEmpty {
            actions.append(deleteAllHighlightsAction(highlightIndexes))
        }
        return actions.isEmpty ? nil : actions
    }

    /// Builds the highlight action, which highlights an entire component (cell)
    /// - Parameters:
    ///   - presenter: the given presenter
    ///   - currentCell: the given cell
    private func highlightAllAction(_ presenter: ArticleComponentPresenter, _ currentCell: ArticleComponentTextCell) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: Localization.Reader.SwipeAction.highlight) {[weak self] _, _, completion in
            if let highlightIndexes = presenter.highlightIndexes {
                self?.removeHighlightsIfNeeded(highlightIndexes)
            }
            currentCell.highlightAll()
            completion(true)
        }
        action.backgroundColor = UIColor(.ui.highlightAction)
        return action
    }

    /// Builds the delete all highlights action, which deletes all highlights indexed in a presenter (and present in the corresponding cell)
    /// - Parameter presenter: the given presenter
    private func deleteAllHighlightsAction(_ highlightIndexes: [Int]) -> UIContextualAction {
        let title = highlightIndexes.count > 1 ? Localization.Reader.SwipeAction.deleteHighlights : Localization.Reader.SwipeAction.deleteHighlight
        let action = UIContextualAction(style: .normal, title: title) {[weak self] _, _, completion in
            self?.removeHighlightsIfNeeded(highlightIndexes)
            completion(true)
        }
        return action
    }

    /// Deletes highlights whose indexes are found in the given presenter
    /// - Parameter presenter: the `ArticleComponentPresenter` concrete instance that's handling the current cell
    private func removeHighlightsIfNeeded(_ highlightIndexes: [Int]) {
        guard let viewModel = readableViewModel as? SavedItemViewModel else {
            return
        }
        highlightIndexes.forEach {
            if let highlight = viewModel.highlights?[safe: $0], let ID = highlight.remoteID {
                viewModel.deleteHighlight(ID)
            }
        }
    }
}

extension ReadableViewController {
    func presenter(for component: ArticleComponent, at index: Int) -> ArticleComponentPresenter {
        switch component {
        case .text(let component):
            return MarkdownComponentPresenter(component: component, readerSettings: readerSettings, componentType: .body, componentIndex: index)
        case .heading(let component):
            return MarkdownComponentPresenter(component: component, readerSettings: readerSettings, componentType: .heading, componentIndex: index)
        case .image(let component):
            return ImageComponentPresenter(component: component, readerSettings: readerSettings, componentIndex: index) { [weak self] in
                self?.collectionView.layoutIfNeeded()
            }
        case .divider(let component):
            return DividerComponentPresenter(component: component, componentIndex: index)
        case .codeBlock(let component):
            return CodeBlockPresenter(component: component, readerSettings: readerSettings, componentIndex: index)
        case .bulletedList(let component):
            return ListComponentPresenter(component: component, readerSettings: readerSettings, componentIndex: index)
        case .numberedList(let component):
            return ListComponentPresenter(component: component, readerSettings: readerSettings, componentIndex: index)
        case .table:
            return UnsupportedComponentPresenter(readableViewModel: readableViewModel, componentIndex: index)
        case .blockquote(let component):
            return BlockquoteComponentPresenter(component: component, readerSettings: readerSettings, componentIndex: index)
        case .video(let component):
            switch component.type {
            case .youtube:
                return YouTubeVideoComponentPresenter(
                    component: component,
                    readableViewModel: readableViewModel,
                    componentIndex: index
                )
            case .vimeoLink, .vimeoIframe, .vimeoMoogaloop:
                return VimeoComponentPresenter(
                    oEmbedService: OEmbedService(session: URLSession.shared),
                    readableViewModel: readableViewModel,
                    component: component,
                    componentIndex: index
                ) { [weak self] in
                    self?.collectionView.layoutIfNeeded()
                }
            default:
                return UnsupportedComponentPresenter(readableViewModel: readableViewModel, componentIndex: index)
            }
        default:
            return UnsupportedComponentPresenter(readableViewModel: readableViewModel, componentIndex: index)
        }
    }
}

// MARK: Highlights
extension ReadableViewController {
    /// Builds the highlighted quotes list from the presenters
    private func fetchQuotes() {
        var quotes = [HighlightedQuote]()
        guard let viewModel = readableViewModel as? SavedItemViewModel else {
            return
        }
        presenters?.forEach { presenter in
            if let indexes = presenter.highlightIndexes,
               let highlights = viewModel.highlights {
                indexes.forEach {
                    if let highlight = highlights[safe: $0] {
                        quotes.append(
                            HighlightedQuote(
                                remoteID: highlight.remoteID,
                                index: $0,
                                indexPath: IndexPath(item: presenter.componentIndex, section: 1),
                                quote: highlight.quote
                            )
                        )
                    }
                }
            }
        }
        viewModel.highlightedQuotes = quotes
    }
}

// MARK: TippableViewController conformance
extension ReadableViewController: TippableViewController {}

extension ReadableViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return webViewActivityItems(url: URL)
    }

//    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
//        model.clearPresentedWebReaderURL()
//    }
    func webViewActivityItems(url: URL) -> [UIActivity] {
        guard let item = Services.shared.source.fetchItem(url.absoluteString), let savedItem = item.savedItem else {
            return []
        }

        return webViewActivityItems(for: savedItem)
    }

    func webViewActivityItems(for item: CDSavedItem) -> [UIActivity] {
        let archiveActivityTitle: WebActivityTitle = (item.isArchived
                                                      ? .moveToSaves
                                                       : .archive)
        let archiveActivity = ReaderActionsWebActivity(title: archiveActivityTitle) { [weak self] in
            if item.isArchived == true {
                self?.readableViewModel.moveFromArchiveToSaves { _ in }
            } else {
                self?.readableViewModel.archive()
            }
        }

        let deleteActivity = ReaderActionsWebActivity(title: .delete) { [weak self] in
            self?.readableViewModel.confirmDelete()
        }

        let favoriteActivityTitle: WebActivityTitle = (item.isFavorite
                                                        ? .unfavorite
                                                        : .favorite
        )

        let favoriteActivity = ReaderActionsWebActivity(title: favoriteActivityTitle) { [weak self] in
            if item.isFavorite == true {
                self?.readableViewModel.unfavorite()
            } else {
                self?.readableViewModel.favorite()
            }
        }

        return [archiveActivity, deleteActivity, favoriteActivity]
    }
}
