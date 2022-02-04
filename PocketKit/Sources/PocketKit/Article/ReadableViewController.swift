import UIKit
import Sync
import Textile
import Combine
import Analytics
import Kingfisher


protocol ReadableViewControllerDelegate: AnyObject {
    func readableViewController(_ controller: ReadableViewController, openURL url: URL)
    func readableViewController(_ controller: ReadableViewController, shareWithAdditionalText text: String?)
}

class ReadableViewController: UIViewController {
    private var metadata: ArticleMetadataPresenter?
    
    var presenters: [ArticleComponentPresenter]?

    var readableViewModel: ReadableViewModel? {
        didSet {
            metadata = readableViewModel.flatMap { readableViewModel -> ArticleMetadataPresenter in
                ArticleMetadataPresenter(
                    readableViewModel: readableViewModel,
                    readerSettings: readerSettings
                )
            }
            
            presenters = readableViewModel?.components?.filter { !$0.isEmpty }.map { presenter(for: $0) }

            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    weak var delegate: ReadableViewControllerDelegate? = nil

    private var contexts: [Context] {
        guard let viewModel = readableViewModel, let url = viewModel.url else {
            return []
        }
        
        let content = ContentContext(url: url)
        return [content]
    }

    private let readerSettings: ReaderSettings

    private var subscriptions: [AnyCancellable] = []
    
    private lazy var collectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )
    
    private lazy var layout = UICollectionViewCompositionalLayout { [self] in
        return self.buildSection(index: $0, environment: $1)
    }

    init(readerSettings: ReaderSettings) {
        self.readerSettings = readerSettings

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
        collectionView.register(cellClass: VimeoComponentCell.self)
        navigationItem.largeTitleDisplayMode = .never

        self.readerSettings.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.reload()
            }
        }.store(in: &subscriptions)
    }
    
    override func loadView() {
        view = collectionView
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        reload()
    }

    private func reload() {
        presenters?.forEach { $0.clearCache() }
        collectionView.reloadData()
    }
}

extension ReadableViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? YouTubeVideoComponentCell {
            cell.pause()
        }
    }
}

extension ReadableViewController: UICollectionViewDataSource {
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
            return readableViewModel == nil ? 0 : 1
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

            metaCell.configure(model: .init(
                byline: metadata?.attributedByline,
                publishedDate: metadata?.attributedPublishedDate,
                title: metadata?.attributedTitle
            ))

            return metaCell
        default:
            guard let cell = presenters?[indexPath.item].cell(for: indexPath, in: collectionView) else {
                let empty: EmptyCell = collectionView.dequeueCell(for: indexPath)
                return empty
            }
            
            if let cell = cell as? ArticleComponentTextCell {
                cell.delegate = self
            }
            
            return cell
        }
    }
}

extension ReadableViewController: ArticleComponentTextCellDelegate {
    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
        didShareText selectedText: String?
    ) {
        delegate?.readableViewController(self, shareWithAdditionalText: selectedText)
    }
    
    func articleComponentTextCell(
        _ cell: ArticleComponentTextCell,
        shouldOpenURL url: URL
    ) -> Bool {
        delegate?.readableViewController(self, openURL: url)
        return false
    }
}

extension ReadableViewController {
    enum Constants {
        static let metaSectionContentInsets = NSDirectionalEdgeInsets(
            top: 16,
            leading: 20,
            bottom: 0,
            trailing: 20
        )

        static let contentSectionContentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 16,
            trailing: 20
        )
    }

    func buildSection(index: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        switch index {
        case 0:
            let availableItemWidth = environment.container.effectiveContentSize.width
            - Constants.metaSectionContentInsets.leading
            - Constants.metaSectionContentInsets.trailing

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
            section.contentInsets = Constants.metaSectionContentInsets
            return section
        default:
            let availableItemWidth = environment.container.effectiveContentSize.width
            - Constants.contentSectionContentInsets.leading
            - Constants.contentSectionContentInsets.trailing

            var height: CGFloat = 0
            let subitems = presenters?.compactMap { presenter -> NSCollectionLayoutItem? in
                let size = presenter.size(for: availableItemWidth)
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
            group.interItemSpacing = .fixed(0)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = Constants.contentSectionContentInsets
            return section
        }
    }
}

extension ReadableViewController {
    func presenter(for component: ArticleComponent) -> ArticleComponentPresenter {
        switch component {
        case .text(let component):
            return MarkdownComponentPresenter(component: component, readerSettings: readerSettings, componentType: .body)
        case .heading(let component):
            return MarkdownComponentPresenter(component: component, readerSettings: readerSettings, componentType: .heading)
        case .image(let component):
            return ImageComponentPresenter(component: component, readerSettings: readerSettings) { [weak self] in
                self?.layout.invalidateLayout()
            }
        case .divider(let component):
            return DividerComponentPresenter(component: component)
        case .codeBlock(let component):
            return CodeBlockPresenter(component: component, readerSettings: readerSettings)
        case .bulletedList(let component):
            return ListComponentPresenter(component: component, readerSettings: readerSettings)
        case .numberedList(let component):
            return ListComponentPresenter(component: component, readerSettings: readerSettings)
        case .table:
            return UnsupportedComponentPresenter(readableViewModel: readableViewModel)
        case .blockquote(let component):
            return BlockquoteComponentPresenter(component: component, readerSettings: readerSettings)
        case .video(let component):
            switch component.type {
            case .youtube:
                return YouTubeVideoComponentPresenter(
                    component: component,
                    readableViewModel: readableViewModel
                )
            case .vimeoLink, .vimeoIframe, .vimeoMoogaloop:
                return VimeoComponentPresenter(
                    oEmbedService: OEmbedService(session: URLSession.shared),
                    readableViewModel: readableViewModel,
                    component: component
                ) { [weak self] in
                    self?.layout.invalidateLayout()
                }
            default:
                return UnsupportedComponentPresenter(readableViewModel: readableViewModel)
            }
        default:
            return UnsupportedComponentPresenter(readableViewModel: readableViewModel)
        }
    }
}
