import UIKit
import Sync
import Analytics
import Combine
import Lottie
import Textile

class SlateDetailViewController: UIViewController {
    private lazy var layoutConfiguration = UICollectionViewCompositionalLayout { [weak self] index, env in
        return self?.section(for: index, environment: env)
    }

    private lazy var dataSource: UICollectionViewDiffableDataSource<SlateDetailViewModel.Section, SlateDetailViewModel.Cell> = {
        UICollectionViewDiffableDataSource<SlateDetailViewModel.Section, SlateDetailViewModel.Cell>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, viewModelCell) -> UICollectionViewCell? in
            return self?.cell(for: viewModelCell, at: indexPath)
        }
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layoutConfiguration)
        return collectionView
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

    private var subscriptions: [AnyCancellable] = []

    private let model: SlateDetailViewModel

    init(
        model: SlateDetailViewModel
    ) {
        self.model = model

        super.init(nibName: nil, bundle: nil)

        view.accessibilityIdentifier = "slate-detail"
        navigationItem.title = model.slateName
        hidesBottomBarWhenPushed = true

        let largeTitleTwoLineMode = "_largeTitleTwoLineMode"
        if class_getProperty(UINavigationItem.self, largeTitleTwoLineMode) != nil {
            navigationItem.setValue(true, forKey: largeTitleTwoLineMode)
        }

        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            let divider: DividerView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            return divider
        }

        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        collectionView.register(cellClass: LoadingCell.self)
        collectionView.register(cellClass: RecommendationCell.self)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: "divider")

        collectionView.publisher(for: \.contentSize, options: [.new]).sink { [weak self] contentSize in
            self?.setupOverflowView(contentSize: contentSize)
        }.store(in: &subscriptions)

        collectionView.publisher(for: \.contentOffset, options: [.new]).sink { [weak self] contentOffset in
            self?.updateOverflowView(contentOffset: contentOffset)
        }.store(in: &subscriptions)

        model.$snapshot.receive(on: DispatchQueue.main).sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot)
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }
}

private extension SlateDetailViewController {
    func setupOverflowView(contentSize: CGSize) {
        let shouldHide = contentSize.height <= collectionView.frame.height
        overscrollView.isHidden = shouldHide
    }

    func updateOverflowView(contentOffset: CGPoint) {
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

    func section(for index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? {
        let section = self.dataSource.sectionIdentifier(for: index)
        switch section {
        case .loading:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.8)
                ),
                subitems: [item]
            )

            return NSCollectionLayoutSection(group: group)
        case .slate(let slate):
            let width = environment.container.effectiveContentSize.width
            let margin: CGFloat = Margins.normal.rawValue
            let recommendations = slate.recommendations?.compactMap { $0 as? Recommendation } ?? []

            let components = recommendations.reduce((CGFloat(0), [NSCollectionLayoutItem]())) { result, recommendation in
                guard let viewModel = self.model.recommendationViewModel(for: recommendation.objectID) else {
                    return result
                }

                let currentHeight = result.0
                let height = RecommendationCell.fullHeight(viewModel: viewModel, availableWidth: width - (margin * 2)) + margin
                var items = result.1
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(height)
                    )
                )
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

                items.append(item)

                return (currentHeight + height, items)
            }

            let heroGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(components.0)
                ),
                subitems: components.1
            )

            let section = NSCollectionLayoutSection(group: heroGroup)

            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: margin,
                bottom: 0,
                trailing: margin
            )

            return section
        default:
            return .empty()
        }
    }

    func cell(
        for viewModelCell: SlateDetailViewModel.Cell,
        at indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch viewModelCell {
        case .loading:
            let cell: LoadingCell = collectionView.dequeueCell(for: indexPath)
            return cell
        case .recommendation(let objectID):
            let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)

            guard let viewModel = self.model.recommendationViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        }
    }
}

extension SlateDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        model.willDisplay(cell, at: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        model.select(cell: cell, at: indexPath)
    }
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
