import UIKit
import Sync
import Analytics


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
    
        super.init(nibName: nil, bundle: nil)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = self
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
}

extension SlateDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let recommendation = slate?.recommendations[indexPath.item] else {
            return
        }

        let article = ArticleViewController(readerSettings: readerSettings, tracker: tracker)
        article.item = recommendation

        navigationController?.pushViewController(article, animated: true)
    }
}
