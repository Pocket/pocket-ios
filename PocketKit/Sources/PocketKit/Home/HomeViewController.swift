import UIKit
import Sync
import Kingfisher
import Textile


class HomeViewController: UIViewController {
    static let dividerElementKind: String = "divider"
    static let twoUpDividerElementKind: String = "twoup-divider"

    private let source: Sync.Source
    private let sectionProvider: HomeViewControllerSectionProvider

    private var slates: [Slate]? {
        didSet {
            collectionView.reloadData()
        }
    }

    private lazy var layout = UICollectionViewCompositionalLayout { [self] index, env in
        sectionProvider.section(for: slates?[index], width: env.container.effectiveContentSize.width)
    }

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    init(source: Sync.Source) {
        self.source = source
        self.sectionProvider = HomeViewControllerSectionProvider()

        super.init(nibName: nil, bundle: nil)

        collectionView.register(cellClass: RecommendationCell.self)
        collectionView.register(viewClass: SlateHeaderView.self, forSupplementaryViewOfKind: SlateHeaderView.kind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.dividerElementKind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.twoUpDividerElementKind)
        collectionView.dataSource = self

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
        return slates?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let slate = slates?[section] else {
            return 0
        }

        return min(slate.recommendations.count, 5)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
        guard let recommendation = slates?[indexPath.section].recommendations[indexPath.item] else {
            return cell
        }

        let presenter = RecommendationPresenter(recommendation: recommendation)
        cell.mode = indexPath.item == 0 ? .hero : .mini
        loadImage(from: recommendation, at: indexPath, into: cell.thumbnailImageView)
        cell.titleLabel.attributedText = presenter.attributedTitle
        cell.subtitleLabel.attributedText = presenter.attributedDetail
        cell.excerptLabel.attributedText = presenter.attributedExcerpt

        return cell
    }

    private func loadImage(
        from recommendation: Slate.Recommendation,
        at indexPath: IndexPath,
        into imageView: UIImageView
    ) {
        let imageWidth = (collectionView
            .layoutAttributesForItem(at: indexPath)?
            .size.width ?? 0)
        - RecommendationCell.layoutMargins.left
        - RecommendationCell.layoutMargins.right

        let imageSize = CGSize(
            width: imageWidth,
            height: imageWidth * RecommendationCell.imageAspectRatio
        )

        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: recommendation.topImageURL,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .processor(ResizingImageProcessor(
                    referenceSize: imageSize,
                    mode: .aspectFill
                ).append(
                    another: CroppingImageProcessor(size: imageSize)
                )),
            ]
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case SlateHeaderView.kind:
            let header: SlateHeaderView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            guard let slate = slates?[indexPath.section] else {
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
