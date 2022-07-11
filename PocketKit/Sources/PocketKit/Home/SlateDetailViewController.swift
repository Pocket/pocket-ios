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
        let registration = UICollectionView.CellRegistration<RecommendationCell, SlateDetailViewModel.Cell> { [weak self] cell, indexPath, cellViewModel in
            self?.configure(cell, at: indexPath, viewModel: cellViewModel)
        }

        let dataSource = UICollectionViewDiffableDataSource<SlateDetailViewModel.Section, SlateDetailViewModel.Cell>(
            collectionView: collectionView
        ) { (collectionView, indexPath, recommendation) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: recommendation)
        }

        return dataSource
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
            string: "You're all caught up!\nCheck back later for more.",
            style: .overscroll
        )
        return view
    }()

    private var overscrollTopConstraint: NSLayoutConstraint? = nil
    private var overscrollOffset = 0

    private var subscriptions: [AnyCancellable] = []

    private let model: SlateDetailViewModel

    init(
        model: SlateDetailViewModel
    ) {
        self.model = model

        super.init(nibName: nil, bundle: nil)

        view.accessibilityIdentifier = "slate-detail"

        title = nil
        navigationItem.largeTitleDisplayMode = .never

        dataSource.supplementaryViewProvider = { [unowned self] _, kind, indexPath in
            let divider: DividerView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            return divider
        }

        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

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
        model.refresh { }
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
        case .slate(let slate):
            let width = environment.container.effectiveContentSize.width
            let dividerHeight: CGFloat = 17
            let margin: CGFloat = 8
            let spacing: CGFloat = margin * 2

            let recommendations = slate.recommendations?.compactMap { $0 as? Recommendation } ?? []
            let components = recommendations.reduce((CGFloat(0), [NSCollectionLayoutItem]())) { result, recommendation in
                guard let viewModel = self.model.viewModel(for: recommendation.objectID) else {
                    return result
                }

                let currentHeight = result.0
                let height = RecommendationCell.fullHeight(viewModel: viewModel, availableWidth: width - spacing) + dividerHeight
                var items = result.1
                items.append(
                    NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(height)
                        )
                    )
                )

                return (currentHeight + height, items)
            }

            let heroGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(components.0 + dividerHeight)
                ),
                subitems: components.1
            )

            heroGroup.supplementaryItems = [
                NSCollectionLayoutSupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .absolute(dividerHeight)
                    ),
                    elementKind: "divider",
                    containerAnchor: NSCollectionLayoutAnchor(edges: .bottom)
                )
            ]

            let section = NSCollectionLayoutSection(group: heroGroup)

            section.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: margin,
                bottom: 0,
                trailing: margin
            )

            return section
        default:
            return nil
        }
    }

    func configure(
        _ cell: RecommendationCell,
        at indexPath: IndexPath,
        viewModel cellViewModel: SlateDetailViewModel.Cell
    ) {
        cell.mode = .hero

        guard case .recommendation(let objectID) = cellViewModel,
              let viewModel = model.viewModel(for: objectID) else {
            return
        }

        cell.configure(model: viewModel)

        if let action = model.saveAction(for: cellViewModel, at: indexPath), let uiAction = UIAction(action) {
            cell.saveButton.addAction(uiAction, for: .primaryActionTriggered)
        }

        if let action = model.reportAction(for: cellViewModel, at: indexPath), let uiAction = UIAction(action) {
            cell.overflowButton.addAction(uiAction, for: .primaryActionTriggered)
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
