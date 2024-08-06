// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Localization
import SharedPocketKit
import SwiftUI
import Textile

/// Cell that displays the Sign in or sign up banner at the top of the Home screen in anonymous mode.
/// This cell embeds a SwiftUI view.
class SigninBannerCell: UICollectionViewCell {
    func configure(action: @escaping () -> Void) {
        let view = UIView.embedSwiftUIView(SigninBannerView(action: action))
        contentView.addSubview(view)
        contentView.pinSubviewToAllEdges(view)
    }

    private func configureLayout() {
        layer.cornerRadius = 16
        layer.shadowColor = UIColor(.ui.border).cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 6
        layer.shadowPath = UIBezierPath(roundedRect: layer.bounds, cornerRadius: 16).cgPath
        layer.backgroundColor = UIColor(.ui.homeCellBackground).cgColor
    }

    override func layoutSubviews() {
        configureLayout()
    }
}

/// The SwiftUI view associated with `SigninBannerCell`
struct SigninBannerView: View {
    private let title = Localization.LoggedOut.Banner.title
    private let buttonTitle = Localization.LoggedOut.continue

    @Environment(\.horizontalSizeClass)
    private var horizontalSize

    let action: () -> Void

    var body: some View {
        if horizontalSize == .regular {
            makeRegularWidthView()
        } else {
            makeCompactWidthView()
        }
    }

    func makeCompactWidthView() -> some View {
        VStack(spacing: 8) {
            Text(title)
                .style(.title)
            Button {
                action()
            }
        label: {
            Text(buttonTitle).style(.buttonLabel)
                .frame(maxWidth: .infinity)
                .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
        }
        .buttonStyle(ActionsPrimaryButtonStyle())
        }
        .padding()
    }

    func makeRegularWidthView() -> some View {
        HStack {
            Text(title)
                .style(.title)
            Spacer()
            Button {
                action()
            }
        label: {
            Text(buttonTitle).style(.buttonLabel)
                .padding(EdgeInsets(top: 12, leading: 48, bottom: 12, trailing: 48))
        }
        .buttonStyle(ActionsPrimaryButtonStyle())
        }
        .padding()
    }
}

private extension Style {
    static let title: Self = .header.sansSerif.h6.with { $0.with(alignment: .center).with(lineSpacing: 6) }.with(color: .ui.black1)
    static let buttonLabel: Self = .header.sansSerif.h7.with(color: .ui.white)
}
