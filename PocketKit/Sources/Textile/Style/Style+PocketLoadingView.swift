// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public extension Style {
    struct PocketLoadingView {
        public func loadingViewText(_ textColor: ColorAsset) -> Style {
            Style.header.sansSerif.p2.with(color: textColor).with(weight: .bold)
        }
    }
    static let pocketLoadingView = PocketLoadingView()
}
