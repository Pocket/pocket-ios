import UIKit
import Sync
import Kingfisher
import Textile
import Analytics
import Combine


enum HomeSection: Hashable {
    case topicCarousel
    case slate(Slate)
}

enum HomeItem: Hashable {
    case topicChip(Slate)
    case recommendation(Slate.Recommendation)
}

class HomeViewController: UIViewController {
    static let dividerElementKind: String = "divider"
    static let twoUpDividerElementKind: String = "twoup-divider"

    private let source: Sync.Source
    private let tracker: Tracker
    private let readerSettings: ReaderSettings
    private let sectionProvider: HomeViewControllerSectionProvider
    private let savedRecommendationsService: SavedRecommendationsService
    private var subscriptions: [AnyCancellable] = []

    private var slates: [Slate]? {
        didSet {
            applySnapshot()
            savedRecommendationsService.slates = slates
        }
    }

    private lazy var layout = UICollectionViewCompositionalLayout { [self] index, env in
        switch index {
        case 0:
            return sectionProvider.topicCarouselSection(slates: slates)
        default:
            return sectionProvider.section(for: slates?[index - 1], width: env.container.effectiveContentSize.width)
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<HomeSection, HomeItem>!

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    init(source: Sync.Source, tracker: Tracker, readerSettings: ReaderSettings) {
        self.source = source
        self.tracker = tracker
        self.readerSettings = readerSettings
        self.savedRecommendationsService = source.savedRecommendationsService()
        self.sectionProvider = HomeViewControllerSectionProvider()

        super.init(nibName: nil, bundle: nil)

        dataSource = UICollectionViewDiffableDataSource<HomeSection, HomeItem>(collectionView: collectionView) { [unowned self] _, indexPath, item in
            return self.cellFor(item, at: indexPath)
        }

        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            return self.viewForSupplementaryElement(ofKind: kind, at: indexPath)
        }

        collectionView.register(cellClass: RecommendationCell.self)
        collectionView.register(cellClass: TopicChipCell.self)
        collectionView.register(viewClass: SlateHeaderView.self, forSupplementaryViewOfKind: SlateHeaderView.kind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.dividerElementKind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.twoUpDividerElementKind)
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = "home"

        navigationItem.title = "Home"

        savedRecommendationsService.$itemIDs.sink { [weak self] savedItemIDs in
            self?.updateRecommendationSaveButtons(savedItemIDs: savedItemIDs)
        }.store(in: &subscriptions)
    }

    override func loadView() {
        view = collectionView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            let slates = try? await source.fetchSlates()
            setSlates(slates: slates)
        }
    }

    @MainActor
    private func setSlates(slates: [Slate]?) {
        self.slates = slates
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeViewController {
    func cellFor(_ item: HomeItem, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .topicChip(let slate):
            let cell: TopicChipCell = collectionView.dequeueCell(for: indexPath)
            cell.accessibilityIdentifier = "topic-chip"
            cell.titleLabel.attributedText = TopicChipPresenter(slate: slate).attributedTitle
            return cell
        case .recommendation(let recommendation):
            let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
            cell.mode = indexPath.item == 0 ? .hero : .mini

            let tapAction: UIAction
            if isRecommendationSaved(recommendation) {
                cell.saveButton.mode = .saved
                tapAction = UIAction(identifier: .saveRecommendation) { [weak self] _ in
                    self?.source.archive(recommendation: recommendation)
                }
            } else {
                cell.saveButton.mode = .save
                tapAction = UIAction(identifier: .saveRecommendation) { [weak self] _ in
                    self?.source.save(recommendation: recommendation)
                }
            }
            cell.saveButton.addAction(tapAction, for: .primaryActionTriggered)

            let presenter = RecommendationPresenter(recommendation: recommendation)
            presenter.loadImage(into: cell.thumbnailImageView, cellWidth: cell.frame.width)
            cell.titleLabel.attributedText = presenter.attributedTitle
            cell.subtitleLabel.attributedText = presenter.attributedDetail
            cell.excerptLabel.attributedText = presenter.attributedExcerpt


            return cell
        }
    }

    func viewForSupplementaryElement(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case SlateHeaderView.kind:
            let header: SlateHeaderView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            guard let slate = slates?[indexPath.section - 1] else {
                return header
            }

            let presenter = SlateHeaderPresenter(slate: slate)
            header.attributedHeaderText = presenter.attributedHeaderText

            return header
        case Self.dividerElementKind, Self.twoUpDividerElementKind:
            let divider: DividerView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            return divider
        default:
            fatalError("Unknown supplementary view kind: \(kind)")
        }
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
        guard let slates = slates else {
            dataSource.apply(snapshot)
            return
        }

        snapshot.appendSections([.topicCarousel] + slates.map { HomeSection.slate($0) })
        snapshot.appendItems(slates.map { HomeItem.topicChip($0) }, toSection: .topicCarousel)

        for slate in slates {
            snapshot.appendItems(
                slate.recommendations.map { .recommendation($0) },
                toSection: .slate(slate)
            )
        }

        dataSource.apply(snapshot)
    }

    private func updateRecommendationSaveButtons(savedItemIDs: [String]) {
        guard let slates = slates else {
            return
        }

        let difference = savedRecommendationsService.itemIDs.difference(from: savedItemIDs)
        let changed = difference.map { change -> String in
            switch change {
            case let .insert(_, element, _), let .remove(_, element, _):
                return element
            }
        }

        let needsReconfigured: [HomeItem] = slates.flatMap { slate in
            slate.recommendations.filter { changed.contains($0.item.id) }
        }.map { .recommendation($0) }

        DispatchQueue.main.async {
            var snapshot = self.dataSource.snapshot()
            snapshot.reconfigureItems(needsReconfigured)
            self.dataSource.apply(snapshot)
        }
    }

    private func isRecommendationSaved(_ recommendation: Slate.Recommendation) -> Bool {
        return savedRecommendationsService.itemIDs.contains(recommendation.item.id)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let slates = slates else {
            return
        }

        switch indexPath.section {
        case 0:
            let slateDetail = SlateDetailViewController(
                source: source,
                readerSettings: readerSettings,
                tracker: tracker,
                slateID: slates[indexPath.item].id
            )

            navigationController?.pushViewController(slateDetail, animated: true)
        default:
            let article = ArticleViewController(
                readerSettings: readerSettings,
                tracker: tracker
            )
            article.item = slates[indexPath.section - 1].recommendations[indexPath.item]
            navigationController?.pushViewController(article, animated: true)
        }
    }
}

extension UIAction.Identifier {
    static let saveRecommendation = UIAction.Identifier(rawValue: "save-recommendation-action")
}
