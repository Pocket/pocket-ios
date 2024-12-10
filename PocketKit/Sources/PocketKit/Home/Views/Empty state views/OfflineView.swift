// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SwiftUI
import Textile

struct OfflineView: View {
    var body: some View {
        VStack(spacing: Constants.stackSpacing) {
            Constants.image
                .aspectRatio(contentMode: .fit)
            Spacer()
            Text(Constants.offlineTitle)
                .style(Constants.offlineTitleStyle)
            Text(Constants.offlineSubTitle)
                .style(Constants.offlineSubTitleStyle)
            Spacer()
        }
        .padding()
    }
}

// MARK: Constants
private extension OfflineView {
    enum Constants {
        static let image = Image(asset: .looking)
        static let offlineTitle = Localization.noInternetConnection
        static let offlineTitleStyle: Style = .header.sansSerif.h2.with(weight: .semibold)
        static let offlineSubTitle = Localization.LooksLikeYouReOffline.tryCheckingYourMobileDataOrWifi
        static let offlineSubTitleStyle: Style = .header.sansSerif.p2.with {
            $0
                .with(alignment: .center)
                .with(lineHeight: .explicit(28))
                .with(lineSpacing: 12)
        }
        static let stackSpacing: CGFloat = 20
    }
}
