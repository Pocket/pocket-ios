import UIKit
import Sync
import Analytics
import Combine


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

                    let engagement = Engagement(type: .save, value: nil)
                    self?.tracker.track(event: engagement, self?.contexts(for: indexPath))
                }
            }
            cell.saveButton.addAction(tapAction, for: .primaryActionTriggered)
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
        collectionView.accessibilityIdentifier = "slate-detail"
        return collectionView
    }()
    
    private let source: Source
    private let savedRecommendationsService: SavedRecommendationsService
    private var subscriptions: [AnyCancellable] = []
    private let tracker: Tracker
    private let readerSettings: ReaderSettings
    
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
        readerSettings: ReaderSettings,
        tracker: Tracker,
        slateID: String
    ) {
        self.source = source
        self.readerSettings = readerSettings
        self.tracker = tracker
        self.slateID = slateID
        self.savedRecommendationsService = source.savedRecommendationsService()
    
        super.init(nibName: nil, bundle: nil)
        
        title = nil
        navigationItem.largeTitleDisplayMode = .never
        
        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.dataSource = dataSource
        collectionView.delegate = self

        savedRecommendationsService.$itemIDs.sink { [weak self] savedItemIDs in
            self?.updateRecommendationSaveButtons(savedItemIDs: savedItemIDs)
        }.store(in: &subscriptions)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }

    override func loadView() {
        view = collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
}

extension SlateDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let impression = Impression(component: .content, requirement: .instant)
        tracker.track(event: impression, contexts(for: indexPath))
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let recommendation = slate?.recommendations[indexPath.item] else {
            return
        }
        
        let engagement = Engagement(type: .general, value: nil)
        tracker.track(event: engagement, contexts(for: indexPath))

        let article = ArticleViewController(
            readerSettings: readerSettings,
            tracker: tracker.childTracker(hosting: UIContext.articleView.screen)
        )
        article.item = recommendation

        navigationController?.pushViewController(article, animated: true)
        
        let contentOpen = ContentOpen(destination: .internal, trigger: .click)
        tracker.track(event: contentOpen, contexts(for: indexPath))
    }
}

extension SlateDetailViewController {
    private func contexts(for indexPath: IndexPath) -> [SnowplowContext] {
        guard let slate = slate else {
            return []
        }
        
        let snowplowSlate = SnowplowSlate(
            id: slate.id,
            requestID: slate.requestID,
            experiment: slate.experimentID,
            index: UIIndex(indexPath.item)
        )
        
        let recommendation = slate.recommendations[indexPath.item]
        guard let recommendationID = recommendation.id else {
            return []
        }
        let snowplowRecommendation = SnowplowRecommendation(id: recommendationID, index: UIIndex(indexPath.item))
        
        guard let url = recommendation.readerURL else {
            return []
        }
        let content = Content(url: url)
        
        let context = UIContext.slateDetail.recommendation(index: UIIndex(indexPath.row))
     
        return [context, content, snowplowSlate, snowplowRecommendation]
    }
}
