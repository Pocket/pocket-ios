import SwiftUI
import SharedPocketKit

struct PremiumUpsellView : View {
    @ObservedObject
    var viewModel: PremiumUpsellViewModel

    @State var dismissReason: DismissReason = .swipe
    var body: some View {

        HStack {
            Image(uiImage: UIImage(asset: .premiumIconColorful))
            VStack {
                Text(L10n.Tags.Upsell.tagStoriesFasterThanEver)
                Button(action: {
                    viewModel.showPremiumUpgrade()
                }, label: {
                    Text(L10n.Tags.Upsell.getPocketPremium)
                        .style(.header.sansSerif.h7.with(color: .ui.white))
                        .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                        .frame(maxWidth: 320)
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
                        viewModel.trackPremiumUpsellViewed()
                    }
                    .accessibilityIdentifier("get-pocket-premium-button")
            }
        }
    }
}
