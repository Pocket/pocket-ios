import UIKit
import Sync
import Textile
import Combine
import Analytics
import Kingfisher


class ArticleViewController: UIViewController {
    private var metadata: ArticleMetadataPresenter?
    private var components: [ArticleComponentPresenter]?

    var item: Readable? {
        didSet {
            metadata = item.flatMap(ArticleMetadataPresenter.init)
            components = item?.components?.map {
                ArticleComponentPresenter(component: $0)
            }.filter { !$0.isEmpty }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }

    private var contexts: [Context] {
        guard let item = item, let url = item.readerURL else {
            return []
        }
        
        let content = ContentContext(url: url)
        return [content]
    }

    private let readerSettings: ReaderSettings
    private let tracker: Tracker

    private var subscriptions: [AnyCancellable] = []
    
    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )
    
    private lazy var layout = UICollectionViewCompositionalLayout { [self] in
        return self.buildSection(index: $0, environment: $1)
    }

    private var availableItemWidth: CGFloat {
        return collectionView.frame.width
        - collectionView.contentInset.left
        - collectionView.contentInset.right
        - Constants.contentInsets.leading
        - Constants.contentInsets.trailing
    }

    init(readerSettings: ReaderSettings, tracker: Tracker) {
        self.readerSettings = readerSettings
        self.tracker = tracker

        super.init(nibName: nil, bundle: nil)

        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.accessibilityIdentifier = "article-view"
        collectionView.register(cellClass: MarkdownComponentCell.self)
        collectionView.register(cellClass: ImageComponentCell.self)
        collectionView.register(cellClass: EmptyCell.self)
        collectionView.register(cellClass: ArticleMetadataCell.self)
        navigationItem.largeTitleDisplayMode = .never

        readerSettings.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }.store(in: &subscriptions)
    }
    
    override func loadView() {
        view = collectionView
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}

extension ArticleViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return item == nil ? 0 : 1
        default:
            return components?.count ?? 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let metaCell: ArticleMetadataCell = collectionView.dequeueCell(for: indexPath)
            metaCell.attributedTitle = metadata?.attributedTitle
            metaCell.attributedByline = metadata?.attributedByline
            return metaCell
        default:
            guard let presenter = components?[indexPath.item] else {
                let empty: EmptyCell = collectionView.dequeueCell(for: indexPath)
                return empty
            }
            
            switch presenter.component {
            case .text(let textComponent):
                let cell: MarkdownComponentCell = collectionView.dequeueCell(for: indexPath)
                cell.attributedContent = presenter.attributedContent(for: textComponent)
                return cell
            case .heading(let headerComponent):
                let cell: MarkdownComponentCell = collectionView.dequeueCell(for: indexPath)
                cell.attributedContent = presenter.attributedContent(for: headerComponent)
                return cell
            case .image:
                let cell: ImageComponentCell = collectionView.dequeueCell(for: indexPath)
                presenter.loadImage(into: cell.imageView, availableWidth: availableItemWidth) {
                    collectionView.collectionViewLayout.invalidateLayout()
                }

                return cell
            default:
                let empty: EmptyCell = collectionView.dequeueCell(for: indexPath)
                return empty
            }
        }
    }
}

extension ArticleViewController: MarkdownComponentCellDelegate {
    func markdownComponentCell(
        _ cell: MarkdownComponentCell,
        didShareSelecedText selectedText: String
    ) {
        guard let item = item, let activity = item.shareActivity(additionalText: selectedText) else {
            return
        }

        let sheet = UIActivityViewController(activity: activity)
        present(sheet, animated: true)
    }
    
    func markdownComponentCell(
        _ cell: MarkdownComponentCell,
        shouldOpenURL url: URL
    ) -> Bool {
        let contentOpen = ContentOpenEvent(destination: .external, trigger: .click)
        let link = UIContext.articleView.link
        let contexts = contexts + [link]
        tracker.track(event: contentOpen, contexts)
        return true
    }
}

extension ArticleViewController {
    enum Constants {
        static let contentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
    }

    func buildSection(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch index {
        case 0:
            let height = metadata?.size(for: availableItemWidth).height ?? 1
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(height)
                ),
                subitems: [
                    NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalHeight(1)
                        )
                    )
                ]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = Constants.contentInsets
            return section
        default:
            var height: CGFloat = 0
            let subitems = components?.compactMap { component -> NSCollectionLayoutItem? in
                let size = component.size(fittingWidth: availableItemWidth)
                height += size.height
                let layoutSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(size.height)
                )

                return NSCollectionLayoutItem(layoutSize: layoutSize)
            }

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .estimated(height)
                ),
                subitems: subitems ?? []
            )
            group.interItemSpacing = .fixed(8)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = Constants.contentInsets
            return section
        }
    }
}
