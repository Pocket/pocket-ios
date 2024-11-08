// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Lottie
import SwiftUI

public struct LoadingView: View {
    let message: String
    let textColor: ColorAsset
    let backgroundColor: ColorAsset
    let foregroundColor: ColorAsset
    public init(_ message: String, textColor: ColorAsset, backgroundColor: ColorAsset, foregroundColor: ColorAsset) {
        self.message = message
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    public var body: some View {
        VStack {
            Spacer()
            Lottie.LottieView(animation: .named("loading.json", bundle: .module, subdirectory: "Assets"))
                .playbackMode(.playing(.fromProgress(0, toProgress: 1, loopMode: .loop)))
                .frame(minWidth: 0, maxWidth: 300, minHeight: 0, maxHeight: 100)
            Text(message).style(.pocketLoadingView.loadingViewText(textColor))
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(backgroundColor))
        .foregroundColor(Color(foregroundColor))
        .opacity(0.9)
        .accessibilityIdentifier("loading-view")
    }
}

// MARK: predefined styles
public extension LoadingView {
    static func overlay(_ message: String) -> LoadingView {
        LoadingView(message, textColor: .ui.white, backgroundColor: .ui.grey3, foregroundColor: .ui.white1)
    }

    static func loadingIndicator(_ message: String) -> LoadingView {
        LoadingView(message, textColor: .ui.black1, backgroundColor: .ui.white1, foregroundColor: .ui.white1)
    }
}
