// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile

class EmptyStateCollectionViewCell: UICollectionViewCell {
    func configure(viewModel: EmptyStateViewModel) {
        let view = UIView.embedSwiftUIView(EmptyStateView<EmptyView>(viewModel: viewModel))
        contentView.addSubview(view)
        contentView.pinSubviewToAllEdges(view)
        view.accessibilityIdentifier = viewModel.accessibilityIdentifier
    }

    override func prepareForReuse() {
        // default implementation does nothing, adding it here just in case it changes in the future
        super.prepareForReuse()
        // clear up any existing content from the view before adding one
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}

struct EmptyStateView<Content: View>: View {
    enum Constants {
        static var maxWidth: CGFloat {
            return 380
        }
    }
    private let viewModel: EmptyStateViewModel
    private var content: Content?

    @State private var showSafariView = false

    init(viewModel: EmptyStateViewModel, content: (() -> Content)? = nil) {
        self.viewModel = viewModel
        self.content = content?()
    }

    var body: some View {
        VStack(alignment: .center, spacing: 35) {
            Image(asset: viewModel.imageAsset)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: viewModel.maxWidth)
                .accessibilityIdentifier(viewModel.accessibilityIdentifier)

            VStack(alignment: .center, spacing: 20) {
                if let headline = viewModel.headline {
                    Text(headline).style(.main)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: Constants.maxWidth)
                }

                if let subtitle = viewModel.detailText {
                    if let icon = viewModel.icon {
                        VStack(alignment: .center, spacing: 5) {
                            Image(asset: icon)
                            Text(subtitle).style(.detail)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: Constants.maxWidth)
                        }
                    } else {
                        Text(subtitle).style(.detail)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: Constants.maxWidth)
                    }
                }
                if let content {
                    content
                } else if case .normal(let buttonText) = viewModel.buttonType, let webURL = viewModel.webURL {
                    Button(action: {
                        if let action = viewModel.buttonAction {
                            action()
                        } else {
                            self.showSafariView = true
                        }
                    }, label: {
                        Text(buttonText).style(.buttonLabel)
                            .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
                            .frame(maxWidth: Constants.maxWidth)
                    })
                    .buttonStyle(ActionsPrimaryButtonStyle())
                        .sheet(isPresented: self.$showSafariView) {
                            SFSafariView(url: webURL)
                        }
                        .accessibilityIdentifier("empty-state-button")
                } else if case .reportIssue(let buttonText, let userEmail) = viewModel.buttonType {
                    ReportIssueButton(text: buttonText, userEmail: userEmail)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(viewModel.accessibilityIdentifier)
    }
}

private extension Style {
    static let main: Self = .header.sansSerif.h2.with(weight: .semibold).with { $0.with(alignment: .center).with(lineSpacing: 6) }
    static let detail: Self = .header.sansSerif.p2.with { $0.with(alignment: .center).with(lineSpacing: 6) }
    static let buttonLabel: Self = .header.sansSerif.h7.with(color: .ui.white)
}
