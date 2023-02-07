import UIKit
import Textile
import SwiftUI

class LoggedOutViewController: UIHostingController<LoggedOutView> {
    convenience init(viewModel: LoggedOutViewModel) {
        self.init(rootView: LoggedOutView(viewModel: viewModel))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard traitCollection.userInterfaceIdiom == .phone else { return .all }
        return .portrait
    }
}

struct LoggedOutView: View {
    @ObservedObject
    private var viewModel: LoggedOutViewModel

    init(viewModel: LoggedOutViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        Group {
            Image(asset: .labeledIcon)

            Spacer()

            LoggedOutCarouselView()

            Spacer()

            LoggedOutActionsView(viewModel: viewModel)
        }
        .preferredColorScheme(.light)
        .padding(16)
        .sheet(isPresented: $viewModel.isPresentingOfflineView) {
            LoggedOutOfflineView(isPresented: $viewModel.isPresentingOfflineView)
                .onDisappear { viewModel.offlineViewDidDisappear() }
        }
        .accessibilityIdentifier("logged-out")
    }
}

private struct LoggedOutCarouselView: View {
    var body: some View {
        TabView {
            LoggedOutCarouselPageView(
                imageAsset: .loggedOutCarousel1,
                text: "Save what really interests you".localized(),
                detailText: "Collect articles, videos or any online content you like.".localized()
            )

            LoggedOutCarouselPageView(
                imageAsset: .loggedOutCarousel2,
                text: "Make the most of any moment".localized(),
                detailText: "Save from Safari, Twitter, YouTube or your favorite news app (for starters). Your articles and videos will be ready for you in Pocket".localized()
            )

            LoggedOutCarouselPageView(
                imageAsset: .loggedOutCarousel3,
                text: "Your quiet corner of the Internet".localized(),
                detailText: "Pocket saves articles in a clean layout designed for reading—no interruptions, no popups—so you can sidestep the Internet's noise.".localized()
            )
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

private struct LoggedOutCarouselPageView: View {
    static let maxWidth: CGFloat = 320

    private let imageAsset: ImageAsset
    private let text: String
    private let detailText: String

    init(imageAsset: ImageAsset, text: String, detailText: String) {
        self.imageAsset = imageAsset
        self.text = text
        self.detailText = detailText
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(asset: imageAsset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: Self.maxWidth)

            Text(text)
                .style(.header.sansSerif.h8)

            Text(detailText)
                .style(.header.sansSerif.p4.with(color: .ui.grey5).with { $0.with(lineSpacing: 6).with(alignment: .center) })
                .frame(maxWidth: Self.maxWidth)
        }
    }
}

private struct LoggedOutActionsView: View {
    private let viewModel: LoggedOutViewModel

    init(viewModel: LoggedOutViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            Button {
                viewModel.signUp()
            } label: {
                Text("Sign Up".localized()).style(.header.sansSerif.h8.with(color: .ui.white))
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .frame(maxWidth: 320)
            }.buttonStyle(ActionsPrimaryButtonStyle())

            Button {
                viewModel.logIn()
            } label: {
                Text("Log In".localized())
                    .style(.header.sansSerif.p4)
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }
    }
}
