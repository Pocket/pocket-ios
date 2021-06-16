// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Sync


struct ArticleComponentView: View {
    @EnvironmentObject
    var settings: ReaderSettings
    
    private let component: ArticleComponent

    init(_ component: ArticleComponent) {
        self.component = component
    }

    var body: some View {
        switch component {
        case .bodyText(let bodyText):
            TextContentView(bodyText.text, style: .body.serif.with(settings: settings))
        case .byline(let byline):
            TextContentView(byline.text, style: .byline.with(settings: settings))
        case .copyright(let copyright):
            TextContentView(copyright.text, style: .copyright.with(settings: settings))
        case .header(let header):
            TextContentView(header.text, style: header.style.with(settings: settings))
        case .message(let message):
            TextContentView(message.text, style: .message.with(settings: settings))
        case .pre(let pre):
            TextContentView(pre.text, style: .pre.with(settings: settings))
        case .publisherMessage(let publisherMessage):
            TextContentView(publisherMessage.text, style: .message.with(settings: settings))
        case .quote(let quote):
            TextContentView(quote.text, style: .quote.with(settings: settings))
        case .title(let title):
            TextContentView(title.text, style: .title.with(settings: settings))
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
    
    func with(settings: ReaderSettings) -> Style {
        self.with(family: settings.fontFamily).adjustingSize(by: settings.fontSizeAdjustment)
    }
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
