// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import SharedPocketKit
import Localization

struct PremiumUpsellView: View {
    @ObservedObject
    var viewModel: PremiumUpsellViewModel
    let itemURL: String

    @State var dismissReason: DismissReason = .swipe
    var body: some View {
        HStack {
            Image(uiImage: UIImage(asset: .premiumIconColorful))
            VStack(alignment: .leading) {
                Text(Localization.Tags.Upsell.tagStoriesFasterThanEver)
                Button(action: {
                    viewModel.showPremiumUpgrade()
                }, label: {
                    Text(Localization.Tags.Upsell.getPocketPremium)
                        .style(.header.sansSerif.h7.with(color: .ui.white))
                        .padding(EdgeInsets(top: 12, leading: 18, bottom: 12, trailing: 18))
                }).buttonStyle(GetPocketPremiumButtonStyle())
                    .sheet(
                        isPresented: $viewModel.isPresentingPremiumUpgrade,
                        onDismiss: {
                            viewModel.trackPremiumDismissed(dismissReason: dismissReason)
                            if dismissReason == .system {
                                viewModel.isPresentingHooray = true
                            }
                        }
                    ) {
                        PremiumUpgradeView(dismissReason: self.$dismissReason, viewModel: viewModel.makePremiumUpgradeViewModel())
                    }
                    .task {
                        viewModel.trackPremiumUpsellViewed(with: itemURL)
                    }
                    .accessibilityIdentifier("get-pocket-premium-button")
            }
            .padding(.leading, 8)
        }
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        Divider()
    }
}
