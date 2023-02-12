// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

public typealias UIHierarchy = UInt
public typealias UIIndex = UInt

public struct OldUIEntity: OldEntity {
    public static let schema = "iglu:com.pocket/ui/jsonschema/1-0-3"

    let type: OldUIType
    let hierarchy: UIHierarchy
    let identifier: Identifier
    let componentDetail: ComponentDetail?
    let index: UIIndex?
    let label: Label?

    public init(
        type: OldUIType,
        hierarchy: UIHierarchy = 0,
        identifier: Identifier,
        componentDetail: ComponentDetail? = nil,
        index: UIIndex? = nil,
        label: Label? = nil
    ) {
        self.type = type
        self.hierarchy = hierarchy
        self.identifier = identifier
        self.componentDetail = componentDetail
        self.index = index
        self.label = label
    }

    func with(hierarchy: UIHierarchy) -> OldUIEntity {
        OldUIEntity(
            type: type,
            hierarchy: hierarchy,
            identifier: identifier,
            componentDetail: componentDetail,
            index: index,
            label: label
        )
    }
}

private extension OldUIEntity {
    enum CodingKeys: String, CodingKey {
        case type
        case hierarchy
        case identifier
        case componentDetail = "component_detail"
        case index
        case label
    }
}

extension OldUIEntity {
    public enum OldUIType: String, Encodable {
        case card
        case list
        case screen
        case reader
        case link
        case button
        case dialog
    }
}

extension OldUIEntity {
    public enum Identifier: String, Encodable {
        case home
        case saves = "saves"
        case archive
        case search
        case favorites
        case reader
        case item
        case articleLink = "article_link"
        case switchToWebView = "switch_to_web_view"
        case itemOverflow = "itemOverflow"
        case itemEditTags = "itemEditTags"
        case itemAddTags = "item_add_tags"
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
        case account
        case loggedOut = "logged_out"
        case logIn = "log_in"
        case signUp = "sign_up"
        case taggedChip = "taggedChip"
        case selectedTag = "selectedTagChip"
        case notTagged = "notTagged"
        case tagBadge = "tagBadge"
        case tagsOverflow = "tagsOverflow"
        case tagsDelete = "tagsDelete"
        case tagsSaveChanges = "tagsSaveChanges"
        case externalApp = "external_app"
        case saveExtension = "save_extension"
        case sortFilterSheet = "sort_filter"
        case sortByNewest = "sortByNewest"
        case sortByOldest = "sortByOldest"
        case sortByLongest = "sortByLongest"
        case sortByShortest = "sortByShortest"
        case navigationDrawer = "navigationDrawer"
    }
}

extension OldUIEntity {
    public enum ComponentDetail: String, Encodable {
        case itemRow = "item_row"
        case homeCard = "discover_tile"
        case overlay = "overlay"
        case addTags = "add_tags"
        case addTagsDone = "add_tags_done"
    }
}

extension OldUIEntity {
    public enum Label: String, Encodable {
        case saveToPocket = "Save to Pocket"
        case tagsAdded = "Tags Added"
    }
}

extension OldUIEntity {
    public struct LoggedOut {
        public let screen = OldUIEntity(type: .screen, identifier: .loggedOut)
    }

    public struct Home {
        public let screen = OldUIEntity(type: .screen, identifier: .home)

        public func item(index: UIIndex) -> OldUIEntity {
            OldUIEntity(
                type: .card,
                hierarchy: 0,
                identifier: .item,
                componentDetail: .homeCard,
                index: index
            )
        }

        public func recentSave(index: UIIndex) -> OldUIEntity {
            OldUIEntity(
                type: .card,
                hierarchy: 0,
                identifier: .item,
                componentDetail: .itemRow,
                index: index
            )
        }
    }

    public struct Saves {
        public let screen = OldUIEntity(type: .screen, hierarchy: 0, identifier: .saves)
        public let saves = OldUIEntity(type: .list, hierarchy: 0, identifier: .saves)
        public let archive = OldUIEntity(type: .list, hierarchy: 0, identifier: .archive)
        public let search = OldUIEntity(type: .list, hierarchy: 0, identifier: .search)
        public let favorites = OldUIEntity(type: .list, hierarchy: 0, identifier: .favorites)
        public let sortFilterSheet = OldUIEntity(type: .screen, identifier: .sortFilterSheet)

        public func item(index: UIIndex) -> OldUIEntity {
            OldUIEntity(type: .card, hierarchy: 0, identifier: .item, componentDetail: .itemRow, index: index)
        }
    }

    public struct Account {
        public let screen = OldUIEntity(type: .screen, hierarchy: 0, identifier: .account)
    }

    public struct ArticleView {
        public let screen = OldUIEntity(type: .screen, hierarchy: 0, identifier: .reader)
        public let link = OldUIEntity(type: .link, hierarchy: 0, identifier: .articleLink)
        public let switchToWebView = OldUIEntity(type: .button, hierarchy: 0, identifier: .switchToWebView)
    }

    public struct SlateDetail {
        public let screen = OldUIEntity(type: .screen, identifier: .slateDetail)

        public func recommendation(index: UIIndex) -> OldUIEntity {
            OldUIEntity(type: .card, hierarchy: 0, identifier: .recommendation, componentDetail: .homeCard, index: index)
        }
    }

    public static let loggedOut = LoggedOut()
    public static let home = Home()
    public static let saves = Saves()
    public static let account = Account()
    public static let articleView = ArticleView()
    public static let slateDetail = SlateDetail()

    public static let reportDialog = OldUIEntity(type: .dialog, identifier: .reportItem)

    public static let navigationDrawer = OldUIEntity(type: .screen, identifier: .navigationDrawer)

    public static func button(identifier: Identifier) -> OldUIEntity {
        OldUIEntity(
            type: .button,
            hierarchy: 0,
            identifier: identifier
        )
    }
}
