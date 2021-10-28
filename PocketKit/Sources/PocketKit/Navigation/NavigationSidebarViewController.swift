import UIKit
import Combine
import Textile


private extension Style {
    static let title: Style = .header.sansSerif.h7
}

class NavigationSidebarViewController: UIViewController {
    private static let layout: UICollectionViewLayout = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        configuration.headerMode = .none
        configuration.backgroundColor = UIColor(.ui.white1)
        return UICollectionViewCompositionalLayout.list(using: configuration)
    }()
    
    private static let snapshot: NSDiffableDataSourceSnapshot<String, MainViewModel.AppSection> = {
        var snapshot = NSDiffableDataSourceSnapshot<String, MainViewModel.AppSection>()
        let section = "app-section"
        snapshot.appendSections([section])
        snapshot.appendItems(MainViewModel.AppSection.allCases, toSection: section)
        return snapshot
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<String, MainViewModel.AppSection> = {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, MainViewModel.AppSection> { (cell, indexPath, appSection) in
            var content = cell.defaultContentConfiguration()
            content.attributedText = NSAttributedString(string: appSection.navigationTitle, style: .title)
            cell.contentConfiguration = content
        }
        
        return UICollectionViewDiffableDataSource<String, MainViewModel.AppSection>(
            collectionView: collectionView
        ) { (collectionView, indexPath, appSection) -> UICollectionViewCell? in
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: appSection
            )
            
            let primaryColor = UIColor(.ui.grey6)
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = primaryColor.withAlphaComponent(0.2)
            cell.backgroundView = backgroundView
            
            let selectedBackgroundView = UIView()
            selectedBackgroundView.backgroundColor = primaryColor
            cell.selectedBackgroundView = selectedBackgroundView
            
            return cell
        }
    }()
    
    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: Self.layout
    )
    private let model: MainViewModel
    private var subscriptions: Set<AnyCancellable> = []

    init(model: MainViewModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Pocket"
        
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.dataSource = dataSource
        dataSource.apply(Self.snapshot)
        
        model.$selectedSection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] appSection in
                let indexPath = self?.dataSource.indexPath(for: appSection)
                self?.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
            }
            .store(in: &subscriptions)
    }
    
    override func loadView() {
        view = collectionView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not implemented")
    }
}

extension NavigationSidebarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        model.selectedSection = MainViewModel.AppSection.allCases[indexPath.item]
    }
}
