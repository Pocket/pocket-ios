import UIKit
import Sync
import Kingfisher
import Textile
import Analytics
import Combine
import SwiftUI
import BackgroundTasks
import Lottie


enum HomeSection: Hashable {
    case topicCarousel
    case slate(Slate)
}

enum HomeItem: Hashable {
    case topicChip(Slate)
    case recommendation(Slate.Recommendation)
}

class HomeViewController: UIViewController {
    private static let lineupID = "e39bc22a-6b70-4ed2-8247-4b3f1a516bd1"
    
    static let dividerElementKind: String = "divider"
    static let twoUpDividerElementKind: String = "twoup-divider"

    private let source: Sync.Source
    private let tracker: Tracker
    private let model: MainViewModel
    private let sectionProvider: HomeViewControllerSectionProvider
    private let savedRecommendationsService: SavedRecommendationsService
    private var subscriptions: [AnyCancellable] = []

    private var slateLineup: SlateLineup? {
        didSet {
            applySnapshot()
            savedRecommendationsService.slates = slates
        }
    }
    
    private var slates: [Slate]? {
        return slateLineup?.slates
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
    
    private lazy var overscrollView: HomeOverscrollView = {
        let view = HomeOverscrollView(frame: .zero)
        view.accessibilityIdentifier = "home-overscroll"
        view.alpha = 0
        view.isHidden = true
        view.attributedText = NSAttributedString(
            "You're all caught up!\nCheck back later for more.",
            style: .overscroll
        )
        view.animation = Animation.named("end-of-feed", bundle: .module, subdirectory: "Assets", animationCache: nil)
        return view
    }()
    
    private var overscrollTopConstraint: NSLayoutConstraint? = nil
    private var overscrollOffset = 0

    init(source: Sync.Source, tracker: Tracker, model: MainViewModel) {
        self.source = source
        self.tracker = tracker
        self.model = model
        self.savedRecommendationsService = source.savedRecommendationsService()
        self.sectionProvider = HomeViewControllerSectionProvider()

        super.init(nibName: nil, bundle: nil)
        
        view.accessibilityIdentifier = "home"

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

        let action = UIAction { [weak self] _ in
            self?.handleRefresh()
        }

        collectionView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: action)

        navigationItem.title = "Home"

        savedRecommendationsService.$itemIDs.sink { [weak self] savedItemIDs in
            self?.updateRecommendationSaveButtons(savedItemIDs: savedItemIDs)
        }.store(in: &subscriptions)
        
        collectionView.publisher(for: \.contentSize, options: [.new]).sink { [weak self] contentSize in
            self?.setupOverflowView(contentSize: contentSize)
        }.store(in: &subscriptions)
        
        collectionView.publisher(for: \.contentOffset, options: [.new]).sink { [weak self] contentOffset in
            self?.updateOverflowView(contentOffset: contentOffset)
        }.store(in: &subscriptions)
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

        Task {
            let lineup = try? await source.fetchSlateLineup(Self.lineupID)
            slateLineup = lineup
        }
    }

    private func handleRefresh() {
        Task {
            let lineup = try? await source.fetchSlateLineup(Self.lineupID)
            slateLineup = lineup

            if self.collectionView.refreshControl?.isRefreshing == true {
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
    }

    func handleBackgroundRefresh(task: BGTask) {
        Task {
            let lineup = try? await source.fetchSlateLineup(Self.lineupID)
            slateLineup = lineup

            task.setTaskCompleted(success: true)
        }
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

                    let engagement = SnowplowEngagement(type: .save, value: nil)
                    self?.tracker.track(event: engagement, self?.contexts(for: indexPath))
                }
            }
            cell.saveButton.addAction(tapAction, for: .primaryActionTriggered)
            
            let reportAction = UIAction(identifier: .recommendationOverflow) { [weak self] _ in
                self?.report(recommendation)
            }
            cell.overflowButton.addAction(reportAction, for: .primaryActionTriggered)

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
        guard let slates = slates else {
            return
        }

        var snapshot = NSDiffableDataSourceSnapshot<HomeSection, HomeItem>()
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
    
    private func report(_ recommendation: Slate.Recommendation) {
        model.selectedRecommendationToReport = recommendation
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
        guard indexPath.section != 0 else {
            return
        }
        
        let impression = ImpressionEvent(component: .content, requirement: .instant)
        tracker.track(event: impression, contexts(for: indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        guard let slates = slates else {
            return
        }

        switch indexPath.section {
        case 0:
            model.selectedSlateID = slates[indexPath.item].id
        default:
            let engagement = SnowplowEngagement(type: .general, value: nil)
            tracker.track(event: engagement, contexts(for: indexPath))
            
            model.selectedRecommendation = slates[indexPath.section - 1].recommendations[indexPath.item]

            let open = ContentOpenEvent(destination: .internal, trigger: .click)
            tracker.track(event: open, contexts(for: indexPath))
        }
    }
}

extension HomeViewController {
    private func contexts(for indexPath: IndexPath) -> [Context] {
        switch indexPath.section {
        case 0:
            return []
        default:
            guard let lineup = slateLineup,
                  let visibleSlate = slates?[indexPath.section - 1] else {
                      return []
                  }
            
            let slateLineup = SlateLineupContext(
                id: lineup.id,
                requestID: lineup.requestID,
                experiment: lineup.experimentID
            )
            
            let slate = SlateContext(
                id: visibleSlate.id,
                requestID: visibleSlate.requestID,
                experiment: visibleSlate.experimentID,
                index: UIIndex(indexPath.section - 1)
            )
            
            let visibleRecommendation = visibleSlate.recommendations[indexPath.item]
            guard let recommendationID = visibleRecommendation.id else {
                return []
            }
            
            let recommendation = RecommendationContext(
                id: recommendationID,
                index: UIIndex(indexPath.item)
            )
            
            guard let url = visibleRecommendation.item.resolvedURL ?? visibleRecommendation.item.givenURL else {
                return []
            }
            
            let content = ContentContext(url: url)
            let item = UIContext.home.item(index: UInt(indexPath.item))
            
            return [item, content, slateLineup, slate, recommendation]
        }
    }
}

extension UIAction.Identifier {
    static let saveRecommendation = UIAction.Identifier(rawValue: "save-recommendation-action")
    static let recommendationOverflow = UIAction.Identifier(rawValue: "recommendation-overflow")
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
