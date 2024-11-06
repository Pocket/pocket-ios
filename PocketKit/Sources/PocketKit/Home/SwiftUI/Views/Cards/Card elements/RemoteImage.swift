// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Kingfisher
import SwiftUI
import Textile
import NukeUI
import Nuke

/// A resizable remote image backed by `KingFisher`
/// if `url` is nil and  `usePlaceholder` is true it will return a placeholder view
/// if `url` is nil and `usePlaceholder` is false, it will return an empty view
struct RemoteImage: View {
    let url: URL?
    let imageSize: CGSize
    let usePlaceholder: Bool

    var body: some View {
        // makeNukeImage()
        makeKFImage()
        // makeAsyncImage()
    }
}

private extension RemoteImage {
    @ViewBuilder
    func makeKFImage() -> some View {
        if let url {
            KFImage(url)
                .placeholder { progress in
                    if !progress.isFinished && !progress.isCancelled && !progress.isIndeterminate {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(.ui.grey4)))
                    }
                }
                .setProcessor(
                    ResizingImageProcessor(
                        referenceSize: imageSize,
                        mode: .aspectFill
                    )
                    .append(
                        another: CroppingImageProcessor(
                            size: imageSize
                        )
                    )
                )
                .backgroundDecode()
                .scaleFactor(UIScreen.main.scale)
                .resizable()
        } else if usePlaceholder {
            Color(.ui.grey6)
        }
    }

    @ViewBuilder
    func makeNukeImage() -> some View {
        if let url {
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                        .resizable()
                }
            }
                .processors([ImageProcessors.Resize(size: imageSize, crop: true)])
        } else if usePlaceholder {
            Color(.ui.grey6)
        }
    }

    @ViewBuilder
    func makeAsyncImage() -> some View {
        if let url {
            AsyncImage(url: url) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                }
            }
        } else if usePlaceholder {
            Color(.ui.grey6)
        }
    }
}
