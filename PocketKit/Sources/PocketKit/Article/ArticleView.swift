// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync
import Textile



struct ArticleView: View {
    @StateObject
    private var state = ArticleViewState()
    
    private let article: Article
    
    init(article: Article) {
        self.article = article
    }
    
    var body: some View {
        List {
            ForEach(article.content) { component in
                ArticleComponentView(component)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .padding([.top])
        .environmentObject(state)
        .accessibility(identifier: "article-view")
    }
}

struct ArticleView_Preview: PreviewProvider {
    static var previews: some View {
        ArticleView(article: Article.sample)
            .preferredColorScheme(.dark)
            .environment(\.sizeCategory, .extraSmall)
    }
}
