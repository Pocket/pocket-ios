// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import Sync

struct ItemDestinationView: View {
    private let item: Item
    
    private let article: Article?
    
    @Environment(\.presentationMode) @Binding
    private var presentationMode: PresentationMode
    
    @State
    private var shouldPresentWebView = false
    
    @State
    private var shouldPresentOverflow = false
    
    @StateObject
    private var settings = ReaderSettings()
    
    @ViewBuilder
    private var destinationView: some View {
        if let article = article {
            ArticleView(article: article).navigationBarHidden(true)
        } else {
            // TODO: Implement a view for when an article for the item doesn't exist.
            EmptyView()
        }
    }
    
    init(item: Item, article: Article?) {
        self.item = item
        self.article = article
    }
    
    var body: some View {
        destinationView
            .toolbar(item: item,
                     presentationMode: _presentationMode.wrappedValue,
                     shouldPresentWebView: $shouldPresentWebView,
                     shouldPresentOverflow: $shouldPresentOverflow)
            .environmentObject(settings)
    }
}

private struct ItemToolbar: ViewModifier {
    private let item: Item
    
    @Binding
    private var presentationMode: PresentationMode
    
    @Binding
    private var shouldPresentWebView: Bool
    
    @Binding
    private var shouldPresentOverflow: Bool
    
    init(item: Item, presentationMode: Binding<PresentationMode>,
         shouldPresentWebView: Binding<Bool>,
         shouldPresentOverflow: Binding<Bool>) {
        self.item = item
        _presentationMode = presentationMode
        _shouldPresentWebView = shouldPresentWebView
        _shouldPresentOverflow = shouldPresentOverflow
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
                
                Button(action: {
                    shouldPresentOverflow = true
                }) {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $shouldPresentWebView) {
            SafariView(url: item.url!).ignoresSafeArea()
        }
        .popover(isPresented: $shouldPresentOverflow) {
            ReaderSettingsView()
        }
    }
}

private extension View {
    func toolbar(item: Item,
                 presentationMode: Binding<PresentationMode>,
                 shouldPresentWebView: Binding<Bool>,
                 shouldPresentOverflow: Binding<Bool>) -> some View {
        self.modifier(ItemToolbar(item: item,
                                  presentationMode: presentationMode,
                                  shouldPresentWebView: shouldPresentWebView,
                                  shouldPresentOverflow: shouldPresentOverflow))
    }
}
