// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Sync


struct ArticleComponentView: View {
    private let component: ArticleComponent

    init(_ component: ArticleComponent) {
        self.component = component
    }

    var body: some View {
        switch component {
        case .bodyText(let bodyText):
            TextContentView(bodyText.text, style: .body.serif)
        case .byline(let byline):
            TextContentView(byline.text, style: .byline)
        case .copyright(let copyright):
            TextContentView(copyright.text, style: .copyright)
        case .header(let header):
            TextContentView(header.text, style: header.style)
        case .message(let message):
            TextContentView(message.text, style: .message)
        case .pre(let pre):
            TextContentView(pre.text, style: .pre)
        case .publisherMessage(let publisherMessage):
            TextContentView(publisherMessage.text, style: .message)
        case .quote(let quote):
            TextContentView(quote.text, style: .quote)
        case .title(let title):
            TextContentView(title.text, style: .title)
        case .image:
            EmptyView()
        case .unsupported:
            EmptyView()
        }
    }
}

private extension Style {
    static let byline: Style = .body.sansSerif.with(color: .ui.grey2)
    static let copyright: Style = .body.serif.with(size: .p4).with(slant: .italic)
    static let message: Style = .body.serif.with(slant: .italic)
    static let quote: Style = .body.serif.with(slant: .italic)
    static let title: Style = .header.sansSerif.h1
    static let pre: Style = .body.sansSerif
}

extension Header {
    var style: Style {
        switch level {
        case 1:
            return .header.serif.h1
        case 2:
            return .header.serif.h2
        case 3:
            return .header.serif.h3
        case 4:
            return .header.serif.h4
        case 5:
            return .header.serif.h5
        case 6:
            return .header.serif.h6
        default:
            return .header.serif.h1
        }
    }
}
