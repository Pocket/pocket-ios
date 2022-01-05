import Sync
import UIKit


class VimeoComponentPresenter: ArticleComponentPresenter {
    private let oEmbedService: OEmbedService
    private let readable: Readable?
    private let component: VideoComponent
    private let mainViewModel: MainViewModel

    private let onContentLoaded: () -> Void
    private var oEmbed: OEmbed?
    private var lastAvailableWidth: CGFloat?

    init(
        oEmbedService: OEmbedService,
        readable: Readable?,
        component: VideoComponent,
        mainViewModel: MainViewModel,
        onContentLoaded: @escaping () -> Void
    ) {
        self.oEmbedService = oEmbedService
        self.readable = readable
        self.component = component
        self.mainViewModel = mainViewModel
        self.onContentLoaded = onContentLoaded
    }

    @MainActor
    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let vimeoCell: VimeoComponentCell = collectionView.dequeueCell(for: indexPath)
        vimeoCell.delegate = self
        vimeoCell.mode = .loading(content: nil)

        Task {
            let request = OEmbedRequest(
                id: component.vid,
                width: lastAvailableWidth.flatMap { Int($0) }
            )

            do {
                oEmbed = try await oEmbedService.fetch(request: request)
            } catch {
                vimeoCell.mode = .error
                return
            }

            if let html = oEmbed?.html {
                let fullHTML = """
                <!doctype html>
                <html>
                <head>
                  <meta name="viewport" content="width=device-width, user-scalable=no, viewport-fit=cover" />
                </head>
                <body>
                    <style>
                        body {
                            margin: 0;
                            padding: 0;
                        }
                    </style>
                    \(html)
                </body>
                </html>
                """

                vimeoCell.mode = .loading(content: fullHTML)
                onContentLoaded()
            }
        }

        return vimeoCell
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        self.lastAvailableWidth = availableWidth

        return CGSize(
            width: oEmbed?.width.flatMap { CGFloat($0) } ?? availableWidth,
            height: oEmbed?.height.flatMap { CGFloat($0) } ?? availableWidth * 9 / 16
        )
    }

    func clearCache() {
        // no op
    }
}

extension VimeoComponentPresenter: VimeoComponentCellDelegate {
    func vimeoComponentCellDidTapOpenInWebView(_ cell: VimeoComponentCell) {
        mainViewModel.presentedWebReaderURL = readable?.readerURL
    }

    func vimeoComponentCell(_ cell: VimeoComponentCell, didNavigateToURL url: URL) {
        mainViewModel.presentedWebReaderURL = url
    }
}
