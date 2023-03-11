import SwiftUI
import Textile

struct PremiumUpgradeSuccessView: View {
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: Constants.verticalPadding) {
            dismissButton
            Image(uiImage: UIImage(asset: .premiumHooray))
                .resizable()
                .scaledToFit()
                .frame(width: Constants.frameSize.width, height: Constants.frameSize.height)
            Text(L10n.hooray)
                .style(.title)
            Text(L10n.Premium.Success.message)
                .style(.paragraph)
            Button(action: {
                dismiss()
            }) {
                VStack {
                    Text(L10n.Back.To.pocket)
                        .style(.button)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: Constants.frameMinHeight)
            .background(
                RoundedRectangle(cornerRadius: Constants.cornerRadius, style: .continuous)
                    .fill(Color(.ui.coral2))
            )
            .padding([.leading, .trailing], Constants.trailingPadding)
            Spacer()
        }
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
            .padding([.leading, .trailing], Constants.verticalPadding)
        }
    }
}

private extension Style {
    static let title = Style.header.serif.title

    static let paragraph = Style.header.serif.p2.with(alignment: .center)

    static let button = Style.header.sansSerif.p3.with(color: .ui.white).with(weight: .medium)
}

private extension PremiumUpgradeSuccessView {
    enum Constants {
        static let frameSize = CGSize(width: 350, height: 350)
        static let frameMinHeight: CGFloat = 53
        static let verticalPadding: CGFloat = 20
        static let cornerRadius: CGFloat = 8
        static let trailingPadding: CGFloat = 15
    }
}
