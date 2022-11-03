import UIKit
import Sync
import Kingfisher
import Textile
import Analytics
import Combine
import SwiftUI
import BackgroundTasks
import Lottie

class HomeViewController: UIViewController {
    private let model: HomeViewModel
    private let sectionProvider: HomeViewControllerSectionProvider
    private var subscriptions: [AnyCancellable] = []

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
            string: "You're all caught up!\nCheck back later for more.",
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
        collectionView.register(cellClass: RecommendationCellHeroWide.self)
        collectionView.register(viewClass: SectionHeaderView.self, forSupplementaryViewOfKind: SectionHeaderView.kind)
        collectionView.delegate = self

        let action = UIAction { [weak self] _ in
            self?.handleRefresh(isForced: true)
        }

        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: action)

        navigationItem.title = "Home"
        collectionView.publisher(for: \.contentSize, options: [.new]).sink { [weak self] contentSize in
            self?.setupOverflowView(contentSize: contentSize)
        }.store(in: &subscriptions)

        collectionView.publisher(for: \.contentOffset, options: [.new]).sink { [weak self] contentOffset in
            self?.updateOverflowView(contentOffset: contentOffset)
        }.store(in: &subscriptions)

        model.$snapshot.sink { [weak self] snapshot in
            self?.dataSource.apply(snapshot)
        }.store(in: &subscriptions)
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
            guard let viewModel = model.recentSavesViewModel(for: objectID, at: indexPath) else {
                return cell
            }

            cell.configure(model: viewModel)
            return cell
        case .recommendationHero(let objectID):
            if sectionProvider.shouldUseWideLayout(traitCollection: traitCollection) {
                let cell: RecommendationCellHeroWide = collectionView.dequeueCell(for: indexPath)
                guard let viewModel = model.recommendationHeroWideViewModel(for: objectID, at: indexPath) else {
                    return cell
                }

                cell.configure(model: viewModel)
                return cell
            } else {
                let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
                guard let viewModel = model.recommendationHeroViewModel(for: objectID, at: indexPath) else {
                    return cell
                }

                cell.configure(model: viewModel)
                return cell
            }
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

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
