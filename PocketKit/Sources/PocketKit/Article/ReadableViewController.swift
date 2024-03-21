// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import Sync
import Textile
import Combine
import Analytics
import Kingfisher
import SafariServices

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

        // we only want highlights for saved items
        if let viewModel = readableViewModel as? SavedItemViewModel {
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

            viewModel.$isPresentingPremiumUpsell
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    guard let self, isPresenting else {
                        return
                    }
                    self.present(viewModel.makePremiumUpgradeViewController(), animated: true)
                }
                .store(in: &subscriptions)

            viewModel.$isPresentingHooray
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isPresenting in
                    guard let self, isPresenting else {
                        return
                    }
                    self.present(viewModel.makeHoorayViewController(), animated: true)
                }
                .store(in: &subscriptions)
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

        guard let userProgress = readableViewModel.readingProgress(),
        userProgress.item < collectionView.numberOfItems(inSection: userProgress.section) else {
            return
        }

        collectionView.selectItem(at: userProgress, animated: true, scrollPosition: .centeredVertically)
        collectionView.setNeedsLayout()
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
            let cell = presenters[indexPath.item].cell(for: indexPath, in: collectionView) { [weak self] index, range, quote, text in
                guard let self, let viewModel = readableViewModel as? SavedItemViewModel else {
                    return
                }
                viewModel.saveHighlight(componentIndex: index, range: range, quote: quote, text: text)
            }
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
            config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in
                guard let presenter = presenters?[safe: indexPath.item],
                      presenter.highlightIndexes == nil,
                      let currentCell = self.collectionView.cellForItem(at: indexPath) as? ArticleComponentTextCell else {
                    return nil
                }
                let action = UIContextualAction(style: .normal, title: "Highlight") {_, _, completion in
                    currentCell.highlightAll()
                    completion(true)
                }
                action.backgroundColor = UIColor(.ui.highlightAction)
                return UISwipeActionsConfiguration(actions: [action])
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
