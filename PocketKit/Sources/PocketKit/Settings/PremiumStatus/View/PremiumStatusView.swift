import SwiftUI
import Textile
import MessageUI
import StoreKit

struct PremiumStatusView: View {
    @Environment(\.dismiss)
    private var dismiss
    @StateObject
    var viewModel: PremiumStatusViewModel
    @State var result: Result<MFMailComposeResult, Error>?
    @State private var presentManageSubscriptions = false

    init(viewModel: PremiumStatusViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: Constants.verticalPadding) {
            dismissButton
            subscriptionHeader
            subscriptionStatus
            Divider()
            if viewModel.subscriptionProvider.isApple {
                yourSubscription
                Divider()
            }
            questionsOrFeedback
            Spacer()
        }
        .manageSubscriptionsSheet(isPresented: $presentManageSubscriptions)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("premium-status-view")
        .task {
            await viewModel.getInfo()
        }
        .padding([.leading, .trailing], Constants.verticalPadding)
        .alert(
            Text(L10n.General.oops),
            isPresented: $viewModel.isPresentingErrorAlert,
            actions: { Button( role: .cancel, action: { dismiss() }, label: { Text(L10n.ok) }) },
            message: { Text(L10n.Search.errorMessage) }
        )
    }

    private var dismissButton: some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(asset: .close).renderingMode(.template).foregroundColor(Color(.ui.grey5))
            }
            .padding(.top, Constants.verticalPadding)
        }
    }

    private var subscriptionHeader: some View {
        HStack {
            Image(uiImage: UIImage(asset: .premiumIconColorful))
                .resizable()
                .scaledToFit()
                .frame(width: Constants.frameSize.width, height: Constants.frameSize.height)
            Text(L10n.Settings.Premium.Settings.thanksForSubscribing)
                .style(Style.title)
        }
    }

    private var subscriptionStatus: some View {
        VStack(spacing: Constants.spacerPadding) {
            HStack {
                Text(L10n.Settings.Premium.Settings.subscriptionStatus)
                    .style(Style.subtitle)
                Spacer()
            }
            ForEach(viewModel.subscriptionInfoList) {
                SubscriptionIfoRow(item: $0)
            }
        }
    }

    private var yourSubscription: some View {
        VStack(spacing: Constants.spacerPadding) {
            HStack {
                Text(L10n.Settings.Premium.Settings.yourSubscription)
                    .style(Style.subtitle)
                Spacer()
            }
            PremiumStatusRow(title: L10n.Settings.Premium.Settings.manageYourSubscription) {
                presentManageSubscriptions = true
            }
        }
    }

    private var questionsOrFeedback: some View {
        VStack(spacing: Constants.spacerPadding) {
            HStack {
                Text(L10n.Settings.Premium.Settings.questionOrFeedback)
                    .style(Style.subtitle)
                Spacer()
            }
            PremiumStatusRow(title: L10n.Settings.Premium.Settings.pocketPremiumFAQ) {
                viewModel.isPresentingFAQ.toggle()
            }
            .sheet(isPresented: $viewModel.isPresentingFAQ) {
                SFSafariView(url: URL(string: "https://help.getpocket.com/article/969-premium-subscriber-faq")!)
                    .edgesIgnoringSafeArea(.bottom)
            }
            PremiumStatusRow(title: L10n.Settings.Premium.Settings.contactPocketSupport) {
                MFMailComposeViewController.canSendMail() ? viewModel.isContactingSupport.toggle() : viewModel.isNoMailSupport.toggle()
            }
            .sheet(isPresented: $viewModel.isContactingSupport) {
                MailView(result: self.$result, recipients: ["premium+subscription@getpocket.com"])
            }
            .alert(isPresented: self.$viewModel.isNoMailSupport) {
                Alert(title: Text("No mail client available on device."))
            }
        }
    }
}

private extension Style {
    static let title = Style.header.sansSerif.h4
    static let subtitle = Style.header.sansSerif.p4.with(color: .ui.grey3)
}

private extension PremiumStatusView {
    enum Constants {
        static let frameSize = CGSize(width: 70, height: 70)
        static let frameMinHeight: CGFloat = 53
        static let verticalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 8
        static let trailingPadding: CGFloat = 15
        static let spacerPadding: CGFloat = 16
    }
}
