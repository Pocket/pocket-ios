// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync

struct ItemDestinationView: View {
    private let item: Item

    private var article: Article? {
        item.particle
    }

    @Environment(\.presentationMode) @Binding
    var presentationMode: PresentationMode
    
    @State
    var shouldPresentWebView = false
    
    @ViewBuilder
    private var destinationView: some View {
        if let article = article {
            ArticleView(article: article).navigationBarHidden(true)
        } else {
            // TODO: Implement a view for when an article for the item doesn't exist.
            EmptyView()
        }
    }
    
    init(item: Item) {
        self.item = item
    }
    
    var body: some View {
        destinationView
            .toolbar(item: item,
                     presentationMode: _presentationMode.wrappedValue,
                     shouldPresentWebView: $shouldPresentWebView)
    }
}

private struct ItemToolbar: ViewModifier {
    private let item: Item
    
    @Binding
    private var presentationMode: PresentationMode
    
    @Binding
    private var shouldPresentWebView: Bool
    
    init(item: Item, presentationMode: Binding<PresentationMode>, shouldPresentWebView: Binding<Bool>) {
        self.item = item
        _presentationMode = presentationMode
        _shouldPresentWebView = shouldPresentWebView
    }
    
    func body(content: Content) -> some View {
        content
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: {
                    presentationMode.dismiss()
                }) {
                    Image(systemName: "chevron.backward")
                }
                
                Spacer()
                
                Button(action: {
                    guard item.url != nil else {
                        return
                    }
                    
                    shouldPresentWebView = true
                }) {
                    Image(systemName: "safari")
                }
                .disabled(item.url == nil)
            }
        }
        .sheet(isPresented: $shouldPresentWebView) {
            SafariView(url: item.url!).ignoresSafeArea()
        }
    }
}

private extension View {
    func toolbar(item: Item, presentationMode: Binding<PresentationMode>, shouldPresentWebView: Binding<Bool>) -> some View {
        self.modifier(ItemToolbar(item: item, presentationMode: presentationMode, shouldPresentWebView: shouldPresentWebView))
    }
}
