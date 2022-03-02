// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public typealias UIHierarchy = UInt
public typealias UIIndex = UInt

public struct UIContext: Context {
    public static let schema = "iglu:com.pocket/ui/jsonschema/1-0-3"
    
    let type: UIType
    let hierarchy: UIHierarchy
    let identifier: Identifier
    let componentDetail: ComponentDetail?
    let index: UIIndex?
    
    public init(
        type: UIType,
        hierarchy: UIHierarchy = 0,
        identifier: Identifier,
        componentDetail: ComponentDetail? = nil,
        index: UIIndex? = nil
    ) {
        self.type = type
        self.hierarchy = hierarchy
        self.identifier = identifier
        self.componentDetail = componentDetail
        self.index = index
    }
    
    func with(hierarchy: UIHierarchy) -> UIContext {
        UIContext(
            type: type,
            hierarchy: hierarchy,
            identifier: identifier,
            componentDetail: componentDetail,
            index: index
        )
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

extension UIContext {
    public enum UIType: String, Encodable {
        case card
        case list
        case screen
        case reader
        case link
        case button
        case dialog
    }
}

extension UIContext {
    public enum Identifier: String, Encodable {
        case home
        case myList = "my_list"
        case archive
        case favorites
        case reader
        case item
        case articleLink = "article_link"
        case switchToWebView = "switch_to_web_view"
        case itemDelete = "item_delete"
        case itemArchive = "item_archive"
        case itemFavorite = "item_favorite"
        case itemUnfavorite = "item_unfavorite"
        case itemShare = "item_share"
        case itemSave = "item_save"
        case slateDetail = "discover_topic"
        case recommendation = "recommendation"
        case reportItem = "report_item"
        case submit
        case settings
        case loggedOut = "logged_out"
        case logIn = "log_in"
        case signUp = "sign_up"
    }
}

extension UIContext {
    public enum ComponentDetail: String, Encodable {
        case itemRow = "item_row"
        case homeCard = "discover_tile"
    }
}

extension UIContext {
    public struct LoggedOut {
        public let screen = UIContext(type: .screen, identifier: .loggedOut)
    }

    public struct Home {
        public let screen = UIContext(type: .screen, identifier: .home)
        
        public func item(index: UIIndex) -> UIContext {
            UIContext(type: .card, hierarchy: 0, identifier: .item, componentDetail: .homeCard, index: index)
        }
    }
    
    public struct MyList {
        public let screen = UIContext(type: .screen, hierarchy: 0, identifier: .myList)
        public let myList = UIContext(type: .list, hierarchy: 0, identifier: .myList)
        public let archive = UIContext(type: .list, hierarchy: 0, identifier: .archive)
        public let favorites = UIContext(type: .list, hierarchy: 0, identifier: .favorites)
        
        public func item(index: UIIndex) -> UIContext {
            UIContext(type: .card, hierarchy: 0, identifier: .item, componentDetail: .itemRow, index: index)
        }
    }

    public struct Settings {
        public let screen = UIContext(type: .screen, hierarchy: 0, identifier: .settings)
    }
    
    public struct ArticleView {
        public let screen = UIContext(type: .screen, hierarchy: 0, identifier: .reader)
        public let link = UIContext(type: .link, hierarchy: 0, identifier: .articleLink)
        public let switchToWebView = UIContext(type: .button, hierarchy: 0, identifier: .switchToWebView)
    }
    
    public struct SlateDetail {
        public let screen = UIContext(type: .screen, identifier: .slateDetail)
        
        public func recommendation(index: UIIndex) -> UIContext {
            UIContext(type: .card, hierarchy: 0, identifier: .recommendation, componentDetail: .homeCard, index: index)
        }
    }

    public static let loggedOut = LoggedOut()
    public static let home = Home()
    public static let myList = MyList()
    public static let settings = Settings()
    public static let articleView = ArticleView()
    public static let slateDetail = SlateDetail()
    
    public static let reportDialog = UIContext(type: .dialog, identifier: .reportItem)
    
    public static func button(identifier: Identifier) -> UIContext {
        UIContext(
            type: .button,
            hierarchy: 0,
            identifier: identifier
        )
    }
}
