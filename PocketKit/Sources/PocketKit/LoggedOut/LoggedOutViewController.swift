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
        .banner(data: BannerModifier.BannerData(image: .accountDeleted, title: L10n.Login.DeletedAccount.Banner.title, detail: L10n.Login.DeletedAccount.Banner.detail, action: BannerModifier.BannerData.BannerAction(text: L10n.Login.DeletedAccount.Banner.action, style: PocketButtonStyle(.primary)) {
            viewModel.exitSurveyButtonClicked()
        }), show: $viewModel.isPresentingExitSurveyBanner)
        .sheet(isPresented: $viewModel.isPresentingExitSurvey) {
            SFSafariView(url: LinkedExternalURLS.ExitSurvey)
                .edgesIgnoringSafeArea(.bottom).onAppear {
                    viewModel.exitSurveyAppeared()
                }
        }
    }
}

private struct LoggedOutCarouselView: View {
    var body: some View {
        TabView {
            LoggedOutCarouselPageView(
                imageAsset: .loggedOutCarousel1,
                text: L10n.saveWhatReallyInterestsYou,
                detailText: L10n.collectArticlesVideosOrAnyOnlineContentYouLike
            )

            LoggedOutCarouselPageView(
                imageAsset: .loggedOutCarousel2,
                text: L10n.makeTheMostOfAnyMoment,
                detailText: L10n.SaveFromSafariTwitterYouTubeOrYourFavoriteNewsAppForStarters.yourArticlesAndVideosWillBeReadyForYouInPocket
            )

            LoggedOutCarouselPageView(
                imageAsset: .loggedOutCarousel3,
                text: L10n.yourQuietCornerOfTheInternet,
                detailText: L10n.pocketSavesArticlesInACleanLayoutDesignedForReadingNoInterruptionsNoPopupsSoYouCanSidestepTheInternetSNoise
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
                Text(L10n.signUp).style(.header.sansSerif.h8.with(color: .ui.white))
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                    .frame(maxWidth: 320)
            }.buttonStyle(ActionsPrimaryButtonStyle())

            Button {
                viewModel.logIn()
            } label: {
                Text(L10n.logIn)
                    .style(.header.sansSerif.p4)
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
            }
        }
    }
}
