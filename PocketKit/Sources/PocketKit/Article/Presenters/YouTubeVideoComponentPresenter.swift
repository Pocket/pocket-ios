// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Sync
import YouTubePlayerKit
import Combine
import CoreGraphics
import UIKit

class YouTubeVideoComponentPresenter: ArticleComponentPresenter {
    private let component: VideoComponent
    private let readableViewModel: ReadableViewModel?

    private var cancellable: AnyCancellable?

    init(
        component: VideoComponent,
        readableViewModel: ReadableViewModel?
    ) {
        self.component = component
        self.readableViewModel = readableViewModel
    }

    func size(for availableWidth: CGFloat) -> CGSize {
        CGSize(width: availableWidth, height: availableWidth * 9 / 16)
    }

    func cell(for indexPath: IndexPath, in collectionView: UICollectionView) -> UICollectionViewCell {
        let cell: YouTubeVideoComponentCell = collectionView.dequeueCell(for: indexPath)

        cell.onError = { [weak self] in
            self?.handleShowInWebReaderButtonTap()
        }

        cancellable =  cell.player
            .statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak cell] state in
                switch state {
                case .idle:
                    cell?.mode = .loading
                case .ready:
                    guard cell?.player.source != nil else {
                        return
                    }
                    cell?.mode = .loaded
                case .error:
                    cell?.mode = .error
                }
        }

        guard let vid = VIDExtractor(component).vid else {
            cell.mode = .error
            return cell
        }

        cell.mode = .loading
        cell.cue(vid: vid)

        return cell
    }

    func clearCache() {
        // no op
    }

    private func handleShowInWebReaderButtonTap() {
        readableViewModel?.showWebReader()
    }
}
