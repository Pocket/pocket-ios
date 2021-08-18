// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI


// MARK: - Trackable
public typealias UIHierarchy = UInt
public typealias UIIndex = UInt

public enum UIType: String, Encodable {
    case card
    case list
    case screen
    case reader
    case link
    case button
}

public enum UIIdentifier: String, Encodable {
    case home
    case reader
    case item
    case articleLink = "article_link"
    case switchToWebView = "switch_to_web_view"
    case itemDelete = "item_delete"
    case itemArchive = "item_archive"
    case itemFavorite = "item_favorite"
    case itemUnfavorite = "item_unfavorite"
    case itemShare = "item_share"
}

public enum UIComponentDetail: String, Encodable {
    case itemRow = "item_row"
}

public struct UIContext: SnowplowContext {
    public static let schema = "iglu:com.pocket/ui/jsonschema/1-0-3"
    let type: UIType
    let hierarchy: UIHierarchy
    let identifier: UIIdentifier
    let componentDetail: UIComponentDetail?
    let index: UIIndex?
    
    public init(
        type: UIType,
        hierarchy: UIHierarchy,
        identifier: UIIdentifier,
        componentDetail: UIComponentDetail? = nil,
        index: UIIndex? = nil
    ) {
        self.type = type
        self.hierarchy = hierarchy
        self.identifier = identifier
        self.componentDetail = componentDetail
        self.index = index
    }
}

private extension UIContext {
    enum CodingKeys: String, CodingKey {
        case type
        case hierarchy
        case identifier
        case componentDetail = "component_detail"
        case index
    }
}

public extension UIContext {
    struct Home {
        public var list = UIContext(type: .screen, hierarchy: 0, identifier: .home)
        
        public func item(index: UIIndex) -> UIContext {
            UIContext(type: .card, hierarchy: 0, identifier: .item, componentDetail: .itemRow, index: index)
        }
    }
    
    struct ArticleView {
        public var screen = UIContext(type: .screen, hierarchy: 0, identifier: .reader)
        public var link = UIContext(type: .link, hierarchy: 0, identifier: .articleLink)
        public var switchToWebView = UIContext(type: .button, hierarchy: 0, identifier: .switchToWebView)
    }
    
    static let home = Home()
    static let articleView = ArticleView()

    static func button(identifier: UIIdentifier) -> UIContext {
        UIContext(
            type: .button,
            hierarchy: 0,
            identifier: identifier
        )
    }
}

// MARK: - SwiftUI
public struct TrackableView<T: View>: View {
    private var content: T
    
    @Environment(\.uiContexts)
    private var viewContexts: [UIContext]
    
    private var currentContext: UIContext
    
    init(_ context: UIContext, _ content: () -> T) {
        self.content = content()
        self.currentContext = context
    }
    
    public var body: some View {
        content.environment(\.uiContexts, viewContexts + [currentContext])
    }
}

public extension View {
    @ViewBuilder
    func trackable(_ context: UIContext) -> TrackableView<Self> {
        TrackableView(context) { self }
    }
}
