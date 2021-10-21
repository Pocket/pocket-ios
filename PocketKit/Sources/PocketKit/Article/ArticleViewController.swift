import UIKit
import Sync
import Textile
import Combine
import Analytics


private extension Style {
    static let bodyText: Style = .body.serif
    static let byline: Style = .body.sansSerif.with(color: .ui.grey2)
    static let copyright: Style = .body.serif.with(size: .p4).with(slant: .italic)
    static let message: Style = .body.serif.with(slant: .italic)
    static let quote: Style = .body.serif.with(slant: .italic)
    static let title: Style = .header.sansSerif.h1
    static let pre: Style = .body.sansSerif
}

protocol Readable {
    var components: [ArticleComponent]? { get }
    var readerURL: URL? { get }
    var textAlignment: TextAlignment { get }

    var title: String? { get }
    var author: String? { get }
    var domain: String? { get }
    var publishDate: Date? { get }

    func shareActivity(additionalText: String?) -> PocketActivity?
}

class ArticleViewController: UICollectionViewController {
    var item: Readable? {
        didSet {
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
    private var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)

        return layout
    }()

    init(readerSettings: ReaderSettings, tracker: Tracker) {
        self.readerSettings = readerSettings
        self.tracker = tracker

        super.init(collectionViewLayout: layout)

        collectionView.backgroundColor = UIColor(.ui.white1)
        collectionView.accessibilityIdentifier = "article-view"
        collectionView.register(cellClass: TextContentCell.self)
        collectionView.register(cellClass: EmptyCell.self)
        collectionView.register(cellClass: ArticleMetadataCell.self)

        readerSettings.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }
}

extension ArticleViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return item?.components.flatMap { $0.count + 1 } ?? 0
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:

            let metaCell: ArticleMetadataCell = collectionView.dequeueCell(for: indexPath)
            metaCell.titleLabel.text = item?.title


            var authorString: String?
            if let author = item?.author, !author.isEmpty {
                authorString = "by \(author)"
            }

            metaCell.metaLabel.text = [
                [authorString, item?.domain].compactMap { $0 }.joined(separator: ", "),
                item?.publishDate?.formatted()
            ]
                .compactMap { $0 }
                .filter { $0.isEmpty == false }
                .joined(separator: "\n")

            return metaCell

        default:
            let empty: EmptyCell = collectionView.dequeueCell(for: indexPath)
            return empty
        }
    }
}

extension ArticleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: 100
        )
    }
}

extension ArticleViewController: TextContentCellDelegate {
    func textContentCell(
        _ cell: TextContentCell,
        didShareSelecedText selectedText: String
    ) {
        guard let item = item, let activity = item.shareActivity(additionalText: selectedText) else {
            return
        }

        let sheet = UIActivityViewController(activity: activity)
        present(sheet, animated: true)
    }
    
    func textContentCell(
        _ cell: TextContentCell,
        shouldOpenURL url: URL
    ) -> Bool {
        let contentOpen = ContentOpenEvent(destination: .external, trigger: .click)
        let link = UIContext.articleView.link
        let contexts = contexts + [link]
        tracker.track(event: contentOpen, contexts)
        return true
    }
}


class ArticleMetadataCell: UICollectionViewCell {
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    let metaLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()

    private var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(labelStack)

        labelStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: labelStack.leadingAnchor),
            contentView.topAnchor.constraint(equalTo: labelStack.topAnchor),
            contentView.trailingAnchor.constraint(equalTo: labelStack.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: labelStack.bottomAnchor),
        ])

        labelStack.addArrangedSubview(titleLabel)
        labelStack.addArrangedSubview(metaLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
