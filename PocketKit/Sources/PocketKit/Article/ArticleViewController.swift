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
    var particle: Article? { get }
    var url: URL? { get }
    var textAlignment: TextAlignment { get }

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

    private var article: Article? {
        item?.particle
    }
    
    private var contexts: [SnowplowContext] {
        guard let item = item, let url = item.url else {
            return []
        }
        
        let content = Content(url: url)
        return [UIContext.articleView.screen, content]
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

        collectionView.accessibilityIdentifier = "article-view"
        collectionView.register(cellClass: TextContentCell.self)
        collectionView.register(cellClass: EmptyCell.self)

        readerSettings.objectWillChange.sink { _ in
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }.store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("Unable to instantiate \(Self.self) from xib/storyboard")
    }

    private func attributedText(textContent: TextContent, style: Style) -> NSAttributedString {
        let adjustedStyle = style
            .with(settings: readerSettings)
            .with { paragraph in
                paragraph.with(alignment: item?.textAlignment ?? .left)
            }

        return textContent.attributedString(baseStyle: adjustedStyle)
    }
}

extension ArticleViewController {
    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return article?.content.count ?? 0
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        switch article?.content[indexPath.item] {
        case .bodyText(let bodyText):
            return textCell(at: indexPath, textContent: bodyText.text, style: .bodyText)
        case .byline(let byline):
            return textCell(at: indexPath, textContent: byline.text, style: .byline)
        case .copyright(let copyright):
            return textCell(at: indexPath, textContent: copyright.text, style: .copyright)
        case .header(let header):
            return textCell(at: indexPath, textContent: header.text, style: header.style)
        case .message(let message):
            return textCell(at: indexPath, textContent: message.text, style: .message)
        case .pre(let pre):
            return textCell(at: indexPath, textContent: pre.text, style: .pre)
        case .publisherMessage(let publisherMessage):
            return textCell(at: indexPath, textContent: publisherMessage.text, style: .message)
        case .quote(let quote):
            return textCell(at: indexPath, textContent: quote.text, style: .quote)
        case .title(let title):
            return textCell(at: indexPath, textContent: title.text, style: .title)
        case .none, .image, .unsupported:
            return emptyCell(at: indexPath)
        }
    }

    private func textCell(
        at indexPath: IndexPath,
        textContent: TextContent,
        style: Style
    ) -> TextContentCell {
        let cell: TextContentCell = collectionView.dequeueCell(for: indexPath)

        cell.attributedText = attributedText(textContent: textContent, style: style)
        cell.delegate = self

        return cell
    }

    func emptyCell(at indexPath: IndexPath) -> EmptyCell {
        return collectionView.dequeueCell(for: indexPath)
    }
}

extension ArticleViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        switch article?.content[indexPath.item] {
        case .bodyText(let bodyText):
            return textSize(for: bodyText.text, style: .bodyText)
        case .byline(let byline):
            return textSize(for: byline.text, style: .byline)
        case .copyright(let copyright):
            return textSize(for: copyright.text, style: .copyright)
        case .header(let header):
            return textSize(for: header.text, style: header.style)
        case .message(let message):
            return textSize(for: message.text, style: .message)
        case .pre(let pre):
            return textSize(for: pre.text, style: .pre)
        case .publisherMessage(let publisherMessage):
            return textSize(for: publisherMessage.text, style: .message)
        case .quote(let quote):
            return textSize(for: quote.text, style: .quote)
        case .title(let title):
            return textSize(for: title.text, style: .title)
        case .none, .image, .unsupported:
            return .zero
        }
    }

    private func textSize(for textContent: TextContent, style: Style) -> CGSize {
        let text = attributedText(textContent: textContent, style: style)

        let maxWidth = collectionView.frame.width -
            layout.sectionInset.left -
            layout.sectionInset.right

        return CGSize(
            width: maxWidth,
            height: text.boundingRect(
                with: CGSize(width: maxWidth, height: .infinity),
                options: [.usesFontLeading, .usesLineFragmentOrigin],
                context: nil
            ).size.height.rounded(.up)
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
        let contentOpen = ContentOpen(destination: .external, trigger: .click)
        let link = UIContext.articleView.link
        let contexts = contexts + [link]
        tracker.track(event: contentOpen, contexts)
        return true
    }
}
