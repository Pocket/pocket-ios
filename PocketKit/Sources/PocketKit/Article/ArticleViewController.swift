import UIKit
import Sync
import Textile
import Combine
import Analytics
import Kingfisher



class ArticleViewController: UIViewController {
    private var metadata: ArticleMetadataPresenter?
    
    var presenters: [ArticleComponentPresenter]?

    var item: Readable? {
        didSet {
            metadata = item.flatMap { item -> ArticleMetadataPresenter in
                ArticleMetadataPresenter(
                    readable: item,
                    readerSettings: readerSettings
                )
            }
            
            presenters = item?.components?.map { presenter(for: $0) }

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
    private let viewModel: MainViewModel

    private var subscriptions: [AnyCancellable] = []
    
    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )
    
    private lazy var layout = UICollectionViewCompositionalLayout { [self] in
        presenters = item?.components?.map { presenter(for: $0) }
        return self.buildSection(index: $0, environment: $1)
    }

    private var availableItemWidth: CGFloat {
        return collectionView.frame.width
        - collectionView.contentInset.left
        - collectionView.contentInset.right
        - Constants.contentInsets.leading
        - Constants.contentInsets.trailing
    }

    init(readerSettings: ReaderSettings, tracker: Tracker, viewModel: MainViewModel) {
        self.readerSettings = readerSettings
        self.tracker = tracker
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.accessibilityIdentifier = "article-view"
        collectionView.register(cellClass: MarkdownComponentCell.self)
        collectionView.register(cellClass: ImageComponentCell.self)
        collectionView.register(cellClass: EmptyCell.self)
        collectionView.register(cellClass: ArticleMetadataCell.self)
        collectionView.register(cellClass: DividerComponentCell.self)
        collectionView.register(cellClass: CodeBlockComponentCell.self)
        collectionView.register(cellClass: UnsupportedComponentCell.self)
        collectionView.register(cellClass: BlockquoteComponentCell.self)
        collectionView.register(cellClass: YouTubeVideoComponentCell.self)
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

extension ArticleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? YouTubeVideoComponentCell {
            cell.pause()
        }
    }
}

extension ArticleViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let presenters = presenters else {
            return 0
        }

        return 1 + (presenters.isEmpty ? 0 : 1)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        switch section {
        case 0:
            return item == nil ? 0 : 1
        default:
            return presenters?.count ?? 0
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let metaCell: ArticleMetadataCell = collectionView.dequeueCell(for: indexPath)
            metaCell.delegate = self
            metaCell.attributedTitle = metadata?.attributedTitle
            metaCell.attributedByline = metadata?.attributedByline
            return metaCell
        default:
            guard let cell = presenters?[indexPath.item].cell(for: indexPath) else {
                let empty: EmptyCell = collectionView.dequeueCell(for: indexPath)
                return empty
            }
            
            return cell
        }
    }
}

extension ArticleViewController: ArticleComponentTextCellDelegate {
    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
        didShareText selectedText: String?
    ) {
        guard let item = item, let activity = item.shareActivity(additionalText: selectedText) else {
            return
        }

        viewModel.sharedActivity = activity
    }
    
    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
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
            let subitems = presenters?.compactMap { presenter -> NSCollectionLayoutItem? in
                let size = presenter.size
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

extension ArticleViewController {
    func presenter(for component: ArticleComponent) -> ArticleComponentPresenter {
        switch component {
        case .text(let component):
            return MarkdownComponentPresenter(
                component: component,
                readerSettings: readerSettings,
                availableWidth: availableItemWidth) { indexPath in
                    let cell: MarkdownComponentCell = self.collectionView.dequeueCell(for: indexPath)
                    return cell
                }
        case .heading(let component):
            return MarkdownComponentPresenter(
                component: component,
                readerSettings: readerSettings,
                availableWidth: availableItemWidth) { indexPath in
                    let cell: MarkdownComponentCell = self.collectionView.dequeueCell(for: indexPath)
                    return cell
                }
        case .image(let component):
            return ImageComponentPresenter(
                component: component,
                readerSettings: readerSettings,
                availableWidth: availableItemWidth
            ) {
                self.collectionView.collectionViewLayout.invalidateLayout()
            } dequeue: { indexPath in
                let cell: ImageComponentCell = self.collectionView.dequeueCell(for: indexPath)
                return cell
            }
        case .divider(let component):
            return DividerComponentPresenter(component: component, readerSettings: readerSettings, availableWidth: availableItemWidth) { indexPath in
                let cell: DividerComponentCell = self.collectionView.dequeueCell(for: indexPath)
                return cell
            }
        case .codeBlock(let component):
            return CodeBlockPresenter(component: component, readerSettings: readerSettings, availableWidth: availableItemWidth) { indexPath in
                let cell: CodeBlockComponentCell = self.collectionView.dequeueCell(for: indexPath)
                cell.delegate = self
                return cell
            }
        case .bulletedList(let component):
            return ListComponentPresenter(component: component, readerSettings: readerSettings, availableWidth: availableItemWidth) { indexPath in
                let cell: MarkdownComponentCell = self.collectionView.dequeueCell(for: indexPath)
                return cell
            }
        case .numberedList(let component):
            return ListComponentPresenter(component: component, readerSettings: readerSettings, availableWidth: availableItemWidth) { indexPath in
                let cell: MarkdownComponentCell = self.collectionView.dequeueCell(for: indexPath)
                return cell
            }
        case .table:
            return UnsupportedComponentPresenter(availableWidth: availableItemWidth) { indexPath in
                let cell: UnsupportedComponentCell = self.collectionView.dequeueCell(for: indexPath)
                cell.action = { [weak self] in
                    self?.viewModel.presentedWebReaderURL = self?.item?.readerURL
                }
                return cell
            }
        case .blockquote(let component):
            return BlockquoteComponentPresenter(component: component, readerSettings: readerSettings, availableWidth: availableItemWidth) { indexPath in
                let cell: BlockquoteComponentCell = self.collectionView.dequeueCell(for: indexPath)
                return cell
            }
        case .video(let component):
            switch component.type {
            case .youtube:
                return YouTubeVideoComponentPresenter(component: component, availableWidth: availableItemWidth) { indexPath in
                    let cell: YouTubeVideoComponentCell = self.collectionView.dequeueCell(for: indexPath)
                    cell.onError = { [weak self] in
                        self?.viewModel.presentedWebReaderURL = self?.item?.readerURL
                    }
                    return cell
                }
            default:
                return UnsupportedComponentPresenter(availableWidth: availableItemWidth) { indexPath in
                    let cell: UnsupportedComponentCell = self.collectionView.dequeueCell(for: indexPath)
                    cell.action = { [weak self] in
                        self?.viewModel.presentedWebReaderURL = self?.item?.readerURL
                    }
                    return cell
                }
            }
        default:
            return UnsupportedComponentPresenter(availableWidth: availableItemWidth) { indexPath in
                let cell: UnsupportedComponentCell = self.collectionView.dequeueCell(for: indexPath)
                return cell
            }
        }
    }
}
