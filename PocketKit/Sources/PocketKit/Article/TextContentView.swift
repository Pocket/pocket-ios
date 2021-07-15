// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Textile
import Sync


struct TextContentView: View {
    private let text: TextContent
    private let style: Style

    @EnvironmentObject
    private var settings: ReaderSettings
    
    @EnvironmentObject
    private var articleState: ArticleViewState

    init(_ text: TextContent, style: Style) {
        self.text = text
        self.style = style
    }
    
    private var content: AttributedString? {
        text.attributedString(baseStyle: style.with(settings: settings))
    }

    private var tappedURL: Binding<URL?> {
        $articleState.url
    }

    var body: some View {
        if let content = content {
            Text(content)
        } else {
            Text("An error occurred while trying to load your article.")
                .style(style.with(settings: settings))
        }
    }
}

private extension Style {
    func with(settings: ReaderSettings) -> Style {
        self.with(family: settings.fontFamily).adjustingSize(by: settings.fontSizeAdjustment)
    }
}
