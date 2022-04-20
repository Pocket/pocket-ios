
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
    static let dividerElementKind: String = "divider"
    static let twoUpDividerElementKind: String = "twoup-divider"

    private let source: Sync.Source
    private let tracker: Tracker
    private let model: HomeViewModel
    private let sectionProvider: HomeViewControllerSectionProvider
    private var subscriptions: [AnyCancellable] = []

    private lazy var layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, env in
        guard let self = self,
              let section = self.dataSource.sectionIdentifier(for: sectionIndex) else {
                  return nil
              }

        switch section {
        case .topics:
            let slates = self.dataSource.snapshot(for: section).items.compactMap { cell -> Slate? in
                guard case .topic(let slate) = cell else {
                    return nil
                }

                return slate
            }

            return self.sectionProvider.topicCarouselSection(slates: slates)
        case .slate(let slate):
            return self.sectionProvider.section(for: slate, width: env.container.effectiveContentSize.width)
        }
    }

    private var dataSource: UICollectionViewDiffableDataSource<HomeViewModel.Section, HomeViewModel.Cell>!

    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )
    
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

    init(source: Sync.Source, tracker: Tracker, model: HomeViewModel) {
        self.source = source
        self.tracker = tracker
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
        collectionView.register(cellClass: RecommendationCell.self)
        collectionView.register(cellClass: TopicChipCell.self)
        collectionView.register(viewClass: SlateHeaderView.self, forSupplementaryViewOfKind: SlateHeaderView.kind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.dividerElementKind)
        collectionView.register(viewClass: DividerView.self, forSupplementaryViewOfKind: Self.twoUpDividerElementKind)
        collectionView.delegate = self

        let action = UIAction { [weak self] _ in
            self?.handleRefresh()
        }

        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: action)

        navigationItem.title = "Home"
        
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

    private func handleRefresh() {
        model.refresh { [weak self] in
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
}

extension HomeViewController {
    func cellFor(_ item: HomeViewModel.Cell, at indexPath: IndexPath) -> UICollectionViewCell {
        switch item {
        case .topic(let slate):
            let cell: TopicChipCell = collectionView.dequeueCell(for: indexPath)
            cell.configure(model: TopicChipPresenter(title: slate.name, image: nil))

            return cell
        case .recommendation(let viewModel):
            let cell: RecommendationCell = collectionView.dequeueCell(for: indexPath)
            cell.mode = indexPath.item == 0 ? .hero : .mini

            let presenter = RecommendationPresenter(recommendation: viewModel.recommendation)
            presenter.loadImage(into: cell.thumbnailImageView, cellWidth: cell.frame.width)
            cell.titleLabel.attributedText = presenter.attributedTitle
            cell.subtitleLabel.attributedText = presenter.attributedDetail
            cell.excerptLabel.attributedText = presenter.attributedExcerpt

            cell.saveButton.mode = viewModel.isSaved ? .saved : .save
            if let action = model.saveAction(for: item, at: indexPath), let uiAction = UIAction(action) {
                cell.saveButton.addAction(uiAction, for: .primaryActionTriggered)
            }

            if let action = model.reportAction(for: item, at: indexPath), let uiAction = UIAction(action) {
                cell.overflowButton.addAction(uiAction, for: .primaryActionTriggered)
            }

            return cell
        }
    }

    func viewForSupplementaryElement(ofKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case SlateHeaderView.kind:
            let header: SlateHeaderView = collectionView.dequeueReusableView(forSupplementaryViewOfKind: kind, for: indexPath)
            guard case .slate(let slate) = dataSource.sectionIdentifier(for: indexPath.section) else {
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
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
