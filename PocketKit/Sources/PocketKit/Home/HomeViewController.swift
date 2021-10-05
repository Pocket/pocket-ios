import UIKit
import Sync
import Kingfisher
import Textile
import Analytics


class HomeViewController: UIViewController {
    static let dividerElementKind: String = "divider"
    static let twoUpDividerElementKind: String = "twoup-divider"

    private let source: Sync.Source
    private let tracker: Tracker
    private let readerSettings: ReaderSettings
    private let sectionProvider: HomeViewControllerSectionProvider

    private var slates: [Slate]? {
        didSet {
            collectionView.reloadData()
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

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    init(source: Sync.Source, tracker: Tracker, readerSettings: ReaderSettings) {
        self.source = source
        self.tracker = tracker
        self.readerSettings = readerSettings
        self.sectionProvider = HomeViewControllerSectionProvider()

        super.init(nibName: nil, bundle: nil)

        collectionView.register(cellClass: RecommendationCell.self)
        collectionView.register(cellClass: TopicChipCell.self)
        collectionView.register(viewClass: SlateHeaderView.self, forSupplementaryViewOfKind: SlateHeaderView.kind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.dividerElementKind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.twoUpDividerElementKind)
        collectionView.dataSource = self
        collectionView.delegate = self

        collectionView.accessibilityIdentifier = "home"

        navigationItem.title = "Home"
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

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let slates = slates else {
            return 0
        }

        return slates.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return slates?.count ?? 0
        default:
            return min(slates?[section - 1].recommendations.count ?? 0, 5)
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell: TopicChipCell = collectionView.dequeueCell(for: indexPath)
            guard let slate = slates?[indexPath.item] else {
                return cell
            }

            cell.accessibilityIdentifier = "topic-chip"
            cell.titleLabel.attributedText = TopicChipPresenter(slate: slate).attributedTitle
            return cell
        default:
            let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
            guard let recommendation = slates?[indexPath.section - 1].recommendations[indexPath.item] else {
                return cell
            }

            cell.mode = indexPath.item == 0 ? .hero : .mini
            
            let presenter = RecommendationPresenter(recommendation: recommendation)
            presenter.loadImage(into: cell.thumbnailImageView, cellWidth: cell.frame.width)
            cell.titleLabel.attributedText = presenter.attributedTitle
            cell.subtitleLabel.attributedText = presenter.attributedDetail
            cell.excerptLabel.attributedText = presenter.attributedExcerpt

            let action = UIAction(identifier: .saveRecommendation) { [weak self] _ in
                self?.source.save(recommendation: recommendation)
            }
            cell.saveButton.addAction(action, for: .primaryActionTriggered)

            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
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
