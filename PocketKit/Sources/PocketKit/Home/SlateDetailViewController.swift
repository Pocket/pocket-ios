import UIKit
import Sync
import Analytics
import Combine
import Lottie
import Textile


class SlateDetailViewController: UIViewController {
    private lazy var layoutConfiguration: UICollectionLayoutListConfiguration = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = UIColor(.ui.white1)

        var separatorConfig = UIListSeparatorConfiguration(listAppearance: .plain)
        separatorConfig.topSeparatorVisibility = .hidden
        separatorConfig.bottomSeparatorVisibility = .visible
        separatorConfig.color = UIColor(.ui.grey6)
        separatorConfig.bottomSeparatorInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
        config.separatorConfiguration = separatorConfig
        config.showsSeparators = true
        
        return config
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { _, environment in
            let section = NSCollectionLayoutSection.list(using: self.layoutConfiguration, layoutEnvironment: environment)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            return section
        }
        
        return layout
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Slate, Slate.Recommendation> = {
        let registration = UICollectionView.CellRegistration<RecommendationCell, Slate.Recommendation> { cell, indexPath, recommendation in
            cell.mode = .hero
            
            let presenter = RecommendationPresenter(recommendation: recommendation)
            presenter.loadImage(into: cell.thumbnailImageView, cellWidth: cell.frame.width)
            cell.titleLabel.attributedText = presenter.attributedTitle
            cell.subtitleLabel.attributedText = presenter.attributedDetail
            cell.excerptLabel.attributedText = presenter.attributedExcerpt

            let tapAction: UIAction
            if self.isRecommendationSaved(recommendation) {
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
        }
        
        let dataSource = UICollectionViewDiffableDataSource<Slate, Slate.Recommendation>(
            collectionView: collectionView
        ) { (collectionView, indexPath, recommendation) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: recommendation)
        }
        
        return dataSource
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        return collectionView
    }()
    
    private lazy var overscrollView: HomeOverscrollView = {
        let view = HomeOverscrollView(frame: .zero)
        view.accessibilityIdentifier = "slate-detail-overscroll"
        view.alpha = 0
        view.attributedText = NSAttributedString(
            string: "You're all caught up!\nCheck back later for more.",
            style: .overscroll
        )
        view.animation = Animation.named("end-of-feed", bundle: .module, subdirectory: "Assets", animationCache: nil)
        return view
    }()
    
    private var overscrollTopConstraint: NSLayoutConstraint? = nil
    private var overscrollOffset = 0
    
    private let source: Source
    private let savedRecommendationsService: SavedRecommendationsService
    private var subscriptions: [AnyCancellable] = []
    private let tracker: Tracker
    private let model: MainViewModel
    
    private let slateID: String
    private var slate: Slate? {
        didSet {
            guard let slate = slate else {
                dataSource.apply(NSDiffableDataSourceSnapshot())
                return
            }
            
            var snapshot = NSDiffableDataSourceSnapshot<Slate, Slate.Recommendation>()
            snapshot.appendSections([slate])
            snapshot.appendItems(slate.recommendations, toSection: slate)
            
            dataSource.apply(snapshot)
            savedRecommendationsService.slates = [slate]
        }
    }
    
    init(
        source: Source,
        model: MainViewModel,
        tracker: Tracker,
        slateID: String
    ) {
        self.source = source
        self.model = model
        self.tracker = tracker
        self.slateID = slateID
        self.savedRecommendationsService = source.savedRecommendationsService()
    
        super.init(nibName: nil, bundle: nil)
        
        view.accessibilityIdentifier = "slate-detail"
        
        title = nil
        navigationItem.largeTitleDisplayMode = .never
        
        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

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
        
        Task {
            self.slate = try await source.fetchSlate(slateID)
        }
    }

    private func updateRecommendationSaveButtons(savedItemIDs: [String]) {
        guard let slate = slate else {
            return
        }

        let difference = savedRecommendationsService.itemIDs.difference(from: savedItemIDs)
        let changed = difference.map { change -> String in
            switch change {
            case let .insert(_, element, _), let .remove(_, element, _):
                return element
            }
        }

        let needsReconfigured = slate.recommendations.filter {
            changed.contains($0.item.id)
        }

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

extension SlateDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let impression = ImpressionEvent(component: .content, requirement: .instant)
        tracker.track(event: impression, contexts(for: indexPath))
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let recommendation = slate?.recommendations[indexPath.item] else {
            return
        }
        
        let engagement = SnowplowEngagement(type: .general, value: nil)
        tracker.track(event: engagement, contexts(for: indexPath))

        let viewModel = RecommendationViewModel(
            recommendation: recommendation,
            mainViewModel: model,
            tracker: tracker.childTracker(hosting: .articleView.screen)
        )
        model.selectedHomeReadableViewModel = viewModel

        let contentOpen = ContentOpenEvent(destination: .internal, trigger: .click)
        tracker.track(event: contentOpen, contexts(for: indexPath))
    }
}

extension SlateDetailViewController {
    private func contexts(for indexPath: IndexPath) -> [Context] {
        guard let slate = slate else {
            return []
        }
        
        let snowplowSlate = SlateContext(
            id: slate.id,
            requestID: slate.requestID,
            experiment: slate.experimentID,
            index: UIIndex(indexPath.item)
        )
        
        let recommendation = slate.recommendations[indexPath.item]
        guard let recommendationID = recommendation.id else {
            return []
        }
        let snowplowRecommendation = RecommendationContext(id: recommendationID, index: UIIndex(indexPath.item))
        
        guard let url = url(for: recommendation) else {
            return []
        }
        let content = ContentContext(url: url)
        
        let context = UIContext.slateDetail.recommendation(index: UIIndex(indexPath.row))
     
        return [context, content, snowplowSlate, snowplowRecommendation]
    }
    
    private func url(for recommendation: Slate.Recommendation) -> URL? {
        recommendation.item.resolvedURL ?? recommendation.item.givenURL
    }
}

private extension Style {
    static let overscroll = Style.header.sansSerif.p3.with { $0.with(alignment: .center) }
}
