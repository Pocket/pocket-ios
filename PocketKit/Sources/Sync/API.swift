// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

/// Pagination request. To determine which edges to return, the connection
/// evaluates the `before` and `after` cursors (if given) to filter the
/// edges, then evaluates `first`/`last` to slice the edges (only include a
/// value for either `first` or `last`, not both). If all fields are null,
/// by default will return a page with the first 30 elements.
public struct PaginationInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - after: Returns the elements in the list that come after the specified cursor.
  /// The specified cursor is not included in the result.
  ///   - before: Returns the elements in the list that come before the specified cursor.
  /// The specified cursor is not included in the result.
  ///   - first: Returns the first _n_ elements from the list. Must be a non-negative integer.
  /// If `first` contains a value, `last` should be null/omitted in the input.
  ///   - last: Returns the last _n_ elements from the list. Must be a non-negative integer.
  /// If `last` contains a value, `first` should be null/omitted in the input.
  public init(after: Swift.Optional<String?> = nil, before: Swift.Optional<String?> = nil, first: Swift.Optional<Int?> = nil, last: Swift.Optional<Int?> = nil) {
    graphQLMap = ["after": after, "before": before, "first": first, "last": last]
  }

  /// Returns the elements in the list that come after the specified cursor.
  /// The specified cursor is not included in the result.
  public var after: Swift.Optional<String?> {
    get {
      return graphQLMap["after"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "after")
    }
  }

  /// Returns the elements in the list that come before the specified cursor.
  /// The specified cursor is not included in the result.
  public var before: Swift.Optional<String?> {
    get {
      return graphQLMap["before"] as? Swift.Optional<String?> ?? Swift.Optional<String?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "before")
    }
  }

  /// Returns the first _n_ elements from the list. Must be a non-negative integer.
  /// If `first` contains a value, `last` should be null/omitted in the input.
  public var first: Swift.Optional<Int?> {
    get {
      return graphQLMap["first"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "first")
    }
  }

  /// Returns the last _n_ elements from the list. Must be a non-negative integer.
  /// If `last` contains a value, `first` should be null/omitted in the input.
  public var last: Swift.Optional<Int?> {
    get {
      return graphQLMap["last"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "last")
    }
  }
}

/// Input field for filtering a user's list
public struct SavedItemsFilter: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - updatedSince: Optional, filter to get SavedItems updated since a unix timestamp
  ///   - isFavorite: Optional, filter to get SavedItems that have been favorited
  ///   - isArchived: Optional, filter to get SavedItems that have been archived.
  /// This field is deprecated. Use status instead.
  /// TODO: Add deprecate tag once input field deprecation is enabled.
  /// Ref: https://github.com/apollographql/federation/issues/912
  ///   - tagIds: Optional, filter to get SavedItems associated to the specified Tag.
  ///   - tagNames: Optional, filter to get SavedItems associated to the specified Tag name.
  /// To get untagged items, include the string '_untagged_'.
  ///   - isHighlighted: Optional, filter to get SavedItems with highlights
  ///   - contentType: Optional, filter to get SavedItems based on content type
  ///   - status: Optional, filter to get user items based on status.
  public init(updatedSince: Swift.Optional<Int?> = nil, isFavorite: Swift.Optional<Bool?> = nil, isArchived: Swift.Optional<Bool?> = nil, tagIds: Swift.Optional<[GraphQLID]?> = nil, tagNames: Swift.Optional<[String]?> = nil, isHighlighted: Swift.Optional<Bool?> = nil, contentType: Swift.Optional<SavedItemsContentType?> = nil, status: Swift.Optional<SavedItemStatusFilter?> = nil) {
    graphQLMap = ["updatedSince": updatedSince, "isFavorite": isFavorite, "isArchived": isArchived, "tagIds": tagIds, "tagNames": tagNames, "isHighlighted": isHighlighted, "contentType": contentType, "status": status]
  }

  /// Optional, filter to get SavedItems updated since a unix timestamp
  public var updatedSince: Swift.Optional<Int?> {
    get {
      return graphQLMap["updatedSince"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "updatedSince")
    }
  }

  /// Optional, filter to get SavedItems that have been favorited
  public var isFavorite: Swift.Optional<Bool?> {
    get {
      return graphQLMap["isFavorite"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isFavorite")
    }
  }

  /// Optional, filter to get SavedItems that have been archived.
  /// This field is deprecated. Use status instead.
  /// TODO: Add deprecate tag once input field deprecation is enabled.
  /// Ref: https://github.com/apollographql/federation/issues/912
  public var isArchived: Swift.Optional<Bool?> {
    get {
      return graphQLMap["isArchived"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isArchived")
    }
  }

  /// Optional, filter to get SavedItems associated to the specified Tag.
  public var tagIds: Swift.Optional<[GraphQLID]?> {
    get {
      return graphQLMap["tagIds"] as? Swift.Optional<[GraphQLID]?> ?? Swift.Optional<[GraphQLID]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagIds")
    }
  }

  /// Optional, filter to get SavedItems associated to the specified Tag name.
  /// To get untagged items, include the string '_untagged_'.
  public var tagNames: Swift.Optional<[String]?> {
    get {
      return graphQLMap["tagNames"] as? Swift.Optional<[String]?> ?? Swift.Optional<[String]?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "tagNames")
    }
  }

  /// Optional, filter to get SavedItems with highlights
  public var isHighlighted: Swift.Optional<Bool?> {
    get {
      return graphQLMap["isHighlighted"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isHighlighted")
    }
  }

  /// Optional, filter to get SavedItems based on content type
  public var contentType: Swift.Optional<SavedItemsContentType?> {
    get {
      return graphQLMap["contentType"] as? Swift.Optional<SavedItemsContentType?> ?? Swift.Optional<SavedItemsContentType?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "contentType")
    }
  }

  /// Optional, filter to get user items based on status.
  public var status: Swift.Optional<SavedItemStatusFilter?> {
    get {
      return graphQLMap["status"] as? Swift.Optional<SavedItemStatusFilter?> ?? Swift.Optional<SavedItemStatusFilter?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "status")
    }
  }
}

/// A SavedItem can be one of these content types
public enum SavedItemsContentType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case video
  case article
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "VIDEO": self = .video
      case "ARTICLE": self = .article
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .video: return "VIDEO"
      case .article: return "ARTICLE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SavedItemsContentType, rhs: SavedItemsContentType) -> Bool {
    switch (lhs, rhs) {
      case (.video, .video): return true
      case (.article, .article): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SavedItemsContentType] {
    return [
      .video,
      .article,
    ]
  }
}

/// Valid statuses a client may use to filter SavedItems
public enum SavedItemStatusFilter: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case unread
  case archived
  case hidden
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "UNREAD": self = .unread
      case "ARCHIVED": self = .archived
      case "HIDDEN": self = .hidden
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .unread: return "UNREAD"
      case .archived: return "ARCHIVED"
      case .hidden: return "HIDDEN"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: SavedItemStatusFilter, rhs: SavedItemStatusFilter) -> Bool {
    switch (lhs, rhs) {
      case (.unread, .unread): return true
      case (.archived, .archived): return true
      case (.hidden, .hidden): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [SavedItemStatusFilter] {
    return [
      .unread,
      .archived,
      .hidden,
    ]
  }
}

public enum PendingItemStatus: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  case resolved
  case unresolved
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "RESOLVED": self = .resolved
      case "UNRESOLVED": self = .unresolved
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .resolved: return "RESOLVED"
      case .unresolved: return "UNRESOLVED"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: PendingItemStatus, rhs: PendingItemStatus) -> Bool {
    switch (lhs, rhs) {
      case (.resolved, .resolved): return true
      case (.unresolved, .unresolved): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [PendingItemStatus] {
    return [
      .resolved,
      .unresolved,
    ]
  }
}

public final class UserByTokenQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query UserByToken($token: String!, $pagination: PaginationInput, $savedItemsFilter: SavedItemsFilter) {
      userByToken(token: $token) {
        __typename
        savedItems(pagination: $pagination, filter: $savedItemsFilter) {
          __typename
          pageInfo {
            __typename
            hasNextPage
            endCursor
          }
          edges {
            __typename
            cursor
            node {
              __typename
              ...SavedItemParts
            }
          }
        }
      }
    }
    """

  public let operationName: String = "UserByToken"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + SavedItemParts.fragmentDefinition)
    document.append("\n" + ItemParts.fragmentDefinition)
    document.append("\n" + PendingItemParts.fragmentDefinition)
    return document
  }

  public var token: String
  public var pagination: PaginationInput?
  public var savedItemsFilter: SavedItemsFilter?

  public init(token: String, pagination: PaginationInput? = nil, savedItemsFilter: SavedItemsFilter? = nil) {
    self.token = token
    self.pagination = pagination
    self.savedItemsFilter = savedItemsFilter
  }

  public var variables: GraphQLMap? {
    return ["token": token, "pagination": pagination, "savedItemsFilter": savedItemsFilter]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("userByToken", arguments: ["token": GraphQLVariable("token")], type: .object(UserByToken.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(userByToken: UserByToken? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "userByToken": userByToken.flatMap { (value: UserByToken) -> ResultMap in value.resultMap }])
    }

    /// Gets a user entity for a given access token
    public var userByToken: UserByToken? {
      get {
        return (resultMap["userByToken"] as? ResultMap).flatMap { UserByToken(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "userByToken")
      }
    }

    public struct UserByToken: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["User"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("savedItems", arguments: ["pagination": GraphQLVariable("pagination"), "filter": GraphQLVariable("savedItemsFilter")], type: .object(SavedItem.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(savedItems: SavedItem? = nil) {
        self.init(unsafeResultMap: ["__typename": "User", "savedItems": savedItems.flatMap { (value: SavedItem) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Get a general paginated listing of all SavedItems for the user
      public var savedItems: SavedItem? {
        get {
          return (resultMap["savedItems"] as? ResultMap).flatMap { SavedItem(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "savedItems")
        }
      }

      public struct SavedItem: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["SavedItemConnection"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("pageInfo", type: .nonNull(.object(PageInfo.selections))),
            GraphQLField("edges", type: .list(.object(Edge.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(pageInfo: PageInfo, edges: [Edge?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "SavedItemConnection", "pageInfo": pageInfo.resultMap, "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Information to aid in pagination.
        public var pageInfo: PageInfo {
          get {
            return PageInfo(unsafeResultMap: resultMap["pageInfo"]! as! ResultMap)
          }
          set {
            resultMap.updateValue(newValue.resultMap, forKey: "pageInfo")
          }
        }

        /// A list of edges.
        public var edges: [Edge?]? {
          get {
            return (resultMap["edges"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Edge?] in value.map { (value: ResultMap?) -> Edge? in value.flatMap { (value: ResultMap) -> Edge in Edge(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }, forKey: "edges")
          }
        }

        public struct PageInfo: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["PageInfo"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("hasNextPage", type: .nonNull(.scalar(Bool.self))),
              GraphQLField("endCursor", type: .scalar(String.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(hasNextPage: Bool, endCursor: String? = nil) {
            self.init(unsafeResultMap: ["__typename": "PageInfo", "hasNextPage": hasNextPage, "endCursor": endCursor])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// When paginating forwards, are there more items?
          public var hasNextPage: Bool {
            get {
              return resultMap["hasNextPage"]! as! Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasNextPage")
            }
          }

          /// When paginating forwards, the cursor to continue.
          public var endCursor: String? {
            get {
              return resultMap["endCursor"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "endCursor")
            }
          }
        }

        public struct Edge: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["SavedItemEdge"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("cursor", type: .nonNull(.scalar(String.self))),
              GraphQLField("node", type: .object(Node.selections)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(cursor: String, node: Node? = nil) {
            self.init(unsafeResultMap: ["__typename": "SavedItemEdge", "cursor": cursor, "node": node.flatMap { (value: Node) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A cursor for use in pagination.
          public var cursor: String {
            get {
              return resultMap["cursor"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "cursor")
            }
          }

          /// The SavedItem at the end of the edge.
          public var node: Node? {
            get {
              return (resultMap["node"] as? ResultMap).flatMap { Node(unsafeResultMap: $0) }
            }
            set {
              resultMap.updateValue(newValue?.resultMap, forKey: "node")
            }
          }

          public struct Node: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["SavedItem"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", alias: "itemId", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("url", type: .nonNull(.scalar(String.self))),
                GraphQLField("isArchived", type: .nonNull(.scalar(Bool.self))),
                GraphQLField("isFavorite", type: .nonNull(.scalar(Bool.self))),
                GraphQLField("_deletedAt", type: .scalar(Int.self)),
                GraphQLField("_createdAt", type: .nonNull(.scalar(Int.self))),
                GraphQLField("item", type: .nonNull(.object(Item.selections))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(itemId: GraphQLID, url: String, isArchived: Bool, isFavorite: Bool, _deletedAt: Int? = nil, _createdAt: Int, item: Item) {
              self.init(unsafeResultMap: ["__typename": "SavedItem", "itemId": itemId, "url": url, "isArchived": isArchived, "isFavorite": isFavorite, "_deletedAt": _deletedAt, "_createdAt": _createdAt, "item": item.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
            public var itemId: GraphQLID {
              get {
                return resultMap["itemId"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "itemId")
              }
            }

            /// The url the user saved to their list
            public var url: String {
              get {
                return resultMap["url"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "url")
              }
            }

            /// Helper property to indicate if the SavedItem is archived
            public var isArchived: Bool {
              get {
                return resultMap["isArchived"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "isArchived")
              }
            }

            /// Helper property to indicate if the SavedItem is favorited
            public var isFavorite: Bool {
              get {
                return resultMap["isFavorite"]! as! Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "isFavorite")
              }
            }

            /// Unix timestamp of when the entity was deleted, 30 days after this date this entity will be HARD deleted from the database and no longer exist
            public var _deletedAt: Int? {
              get {
                return resultMap["_deletedAt"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "_deletedAt")
              }
            }

            /// Unix timestamp of when the entity was created
            public var _createdAt: Int {
              get {
                return resultMap["_createdAt"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "_createdAt")
              }
            }

            /// Link to the underlying Pocket Item for the URL
            public var item: Item {
              get {
                return Item(unsafeResultMap: resultMap["item"]! as! ResultMap)
              }
              set {
                resultMap.updateValue(newValue.resultMap, forKey: "item")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var savedItemParts: SavedItemParts {
                get {
                  return SavedItemParts(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct Item: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["PendingItem", "Item"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLTypeCase(
                    variants: ["Item": AsItem.selections, "PendingItem": AsPendingItem.selections],
                    default: [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    ]
                  )
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public static func makeItem(title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, particleJson: String? = nil, excerpt: String? = nil, domainMetadata: AsItem.DomainMetadatum? = nil, images: [AsItem.Image?]? = nil) -> Item {
                return Item(unsafeResultMap: ["__typename": "Item", "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "particleJson": particleJson, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: AsItem.DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [AsItem.Image?]) -> [ResultMap?] in value.map { (value: AsItem.Image?) -> ResultMap? in value.flatMap { (value: AsItem.Image) -> ResultMap in value.resultMap } } }])
              }

              public static func makePendingItem(url: String, status: PendingItemStatus? = nil) -> Item {
                return Item(unsafeResultMap: ["__typename": "PendingItem", "url": url, "status": status])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var fragments: Fragments {
                get {
                  return Fragments(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }

              public struct Fragments {
                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public var itemParts: ItemParts? {
                  get {
                    if !ItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ItemParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var pendingItemParts: PendingItemParts? {
                  get {
                    if !PendingItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return PendingItemParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }

              public var asItem: AsItem? {
                get {
                  if !AsItem.possibleTypes.contains(__typename) { return nil }
                  return AsItem(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsItem: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Item"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("title", type: .scalar(String.self)),
                    GraphQLField("language", type: .scalar(String.self)),
                    GraphQLField("topImageUrl", type: .scalar(String.self)),
                    GraphQLField("timeToRead", type: .scalar(Int.self)),
                    GraphQLField("domain", type: .scalar(String.self)),
                    GraphQLField("particleJson", type: .scalar(String.self)),
                    GraphQLField("excerpt", type: .scalar(String.self)),
                    GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
                    GraphQLField("images", type: .list(.object(Image.selections))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, particleJson: String? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "Item", "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "particleJson": particleJson, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// The title as determined by the parser.
                public var title: String? {
                  get {
                    return resultMap["title"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "title")
                  }
                }

                /// The detected language of the article
                public var language: String? {
                  get {
                    return resultMap["language"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "language")
                  }
                }

                /// The page's / publisher's preferred thumbnail image
                public var topImageUrl: String? {
                  get {
                    return resultMap["topImageUrl"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "topImageUrl")
                  }
                }

                /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
                public var timeToRead: Int? {
                  get {
                    return resultMap["timeToRead"] as? Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "timeToRead")
                  }
                }

                /// The domain, such as 'getpocket.com' of the {.resolved_url}
                public var domain: String? {
                  get {
                    return resultMap["domain"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "domain")
                  }
                }

                /// The pocket particle format of the article. Json encoded string.
                /// Reserving the particle field for when we decide to define the
                /// particle format/schema in the graph
                public var particleJson: String? {
                  get {
                    return resultMap["particleJson"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "particleJson")
                  }
                }

                /// A snippet of text from the article
                public var excerpt: String? {
                  get {
                    return resultMap["excerpt"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "excerpt")
                  }
                }

                /// Additional information about the item domain, when present, use this for displaying the domain name
                public var domainMetadata: DomainMetadatum? {
                  get {
                    return (resultMap["domainMetadata"] as? ResultMap).flatMap { DomainMetadatum(unsafeResultMap: $0) }
                  }
                  set {
                    resultMap.updateValue(newValue?.resultMap, forKey: "domainMetadata")
                  }
                }

                /// Array of images within an article
                public var images: [Image?]? {
                  get {
                    return (resultMap["images"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Image?] in value.map { (value: ResultMap?) -> Image? in value.flatMap { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }, forKey: "images")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var itemParts: ItemParts {
                    get {
                      return ItemParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var pendingItemParts: PendingItemParts? {
                    get {
                      if !PendingItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return PendingItemParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }

                public struct DomainMetadatum: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["DomainMetadata"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("name", type: .scalar(String.self)),
                      GraphQLField("logo", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(name: String? = nil, logo: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "DomainMetadata", "name": name, "logo": logo])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// The name of the domain (e.g., The New York Times)
                  public var name: String? {
                    get {
                      return resultMap["name"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "name")
                    }
                  }

                  /// Url for the logo image
                  public var logo: String? {
                    get {
                      return resultMap["logo"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "logo")
                    }
                  }
                }

                public struct Image: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Image"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("height", type: .scalar(Int.self)),
                      GraphQLField("width", type: .scalar(Int.self)),
                      GraphQLField("src", type: .scalar(String.self)),
                      GraphQLField("imageId", type: .scalar(Int.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(height: Int? = nil, width: Int? = nil, src: String? = nil, imageId: Int? = nil) {
                    self.init(unsafeResultMap: ["__typename": "Image", "height": height, "width": width, "src": src, "imageId": imageId])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// If known, the height of the image in px
                  public var height: Int? {
                    get {
                      return resultMap["height"] as? Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "height")
                    }
                  }

                  /// If known, the width of the image in px
                  public var width: Int? {
                    get {
                      return resultMap["width"] as? Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "width")
                    }
                  }

                  /// Absolute url to the image
                  public var src: String? {
                    get {
                      return resultMap["src"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "src")
                    }
                  }

                  /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
                  public var imageId: Int? {
                    get {
                      return resultMap["imageId"] as? Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "imageId")
                    }
                  }
                }
              }

              public var asPendingItem: AsPendingItem? {
                get {
                  if !AsPendingItem.possibleTypes.contains(__typename) { return nil }
                  return AsPendingItem(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsPendingItem: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["PendingItem"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("url", type: .nonNull(.scalar(String.self))),
                    GraphQLField("status", type: .scalar(PendingItemStatus.self)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(url: String, status: PendingItemStatus? = nil) {
                  self.init(unsafeResultMap: ["__typename": "PendingItem", "url": url, "status": status])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// URL of the item that the user gave for the SavedItem
                /// that is pending processing by parser
                public var url: String {
                  get {
                    return resultMap["url"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "url")
                  }
                }

                public var status: PendingItemStatus? {
                  get {
                    return resultMap["status"] as? PendingItemStatus
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "status")
                  }
                }

                public var fragments: Fragments {
                  get {
                    return Fragments(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public struct Fragments {
                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public var itemParts: ItemParts? {
                    get {
                      if !ItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ItemParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var pendingItemParts: PendingItemParts {
                    get {
                      return PendingItemParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

public final class FavoriteItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation FavoriteItem($itemID: ID!) {
      updateSavedItemFavorite(id: $itemID) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "FavoriteItem"

  public var itemID: GraphQLID

  public init(itemID: GraphQLID) {
    self.itemID = itemID
  }

  public var variables: GraphQLMap? {
    return ["itemID": itemID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSavedItemFavorite", arguments: ["id": GraphQLVariable("itemID")], type: .nonNull(.object(UpdateSavedItemFavorite.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSavedItemFavorite: UpdateSavedItemFavorite) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSavedItemFavorite": updateSavedItemFavorite.resultMap])
    }

    /// Favorites a SavedItem
    public var updateSavedItemFavorite: UpdateSavedItemFavorite {
      get {
        return UpdateSavedItemFavorite(unsafeResultMap: resultMap["updateSavedItemFavorite"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateSavedItemFavorite")
      }
    }

    public struct UpdateSavedItemFavorite: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SavedItem"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "SavedItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class UnfavoriteItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UnfavoriteItem($itemID: ID!) {
      updateSavedItemUnFavorite(id: $itemID) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "UnfavoriteItem"

  public var itemID: GraphQLID

  public init(itemID: GraphQLID) {
    self.itemID = itemID
  }

  public var variables: GraphQLMap? {
    return ["itemID": itemID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSavedItemUnFavorite", arguments: ["id": GraphQLVariable("itemID")], type: .nonNull(.object(UpdateSavedItemUnFavorite.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSavedItemUnFavorite: UpdateSavedItemUnFavorite) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSavedItemUnFavorite": updateSavedItemUnFavorite.resultMap])
    }

    /// Unfavorites a SavedItem
    public var updateSavedItemUnFavorite: UpdateSavedItemUnFavorite {
      get {
        return UpdateSavedItemUnFavorite(unsafeResultMap: resultMap["updateSavedItemUnFavorite"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateSavedItemUnFavorite")
      }
    }

    public struct UpdateSavedItemUnFavorite: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SavedItem"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "SavedItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class ArchiveItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation ArchiveItem($itemID: ID!) {
      updateSavedItemArchive(id: $itemID) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "ArchiveItem"

  public var itemID: GraphQLID

  public init(itemID: GraphQLID) {
    self.itemID = itemID
  }

  public var variables: GraphQLMap? {
    return ["itemID": itemID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("updateSavedItemArchive", arguments: ["id": GraphQLVariable("itemID")], type: .nonNull(.object(UpdateSavedItemArchive.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSavedItemArchive: UpdateSavedItemArchive) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSavedItemArchive": updateSavedItemArchive.resultMap])
    }

    /// Archives a SavedItem
    public var updateSavedItemArchive: UpdateSavedItemArchive {
      get {
        return UpdateSavedItemArchive(unsafeResultMap: resultMap["updateSavedItemArchive"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateSavedItemArchive")
      }
    }

    public struct UpdateSavedItemArchive: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SavedItem"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID) {
        self.init(unsafeResultMap: ["__typename": "SavedItem", "id": id])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }
    }
  }
}

public final class DeleteItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation DeleteItem($itemID: ID!) {
      deleteSavedItem(id: $itemID)
    }
    """

  public let operationName: String = "DeleteItem"

  public var itemID: GraphQLID

  public init(itemID: GraphQLID) {
    self.itemID = itemID
  }

  public var variables: GraphQLMap? {
    return ["itemID": itemID]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("deleteSavedItem", arguments: ["id": GraphQLVariable("itemID")], type: .nonNull(.scalar(GraphQLID.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(deleteSavedItem: GraphQLID) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "deleteSavedItem": deleteSavedItem])
    }

    /// Deletes a SavedItem from the users list. Returns ID of the
    /// deleted SavedItem
    public var deleteSavedItem: GraphQLID {
      get {
        return resultMap["deleteSavedItem"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "deleteSavedItem")
      }
    }
  }
}

public final class GetSlateLineupQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetSlateLineup($lineupID: String!, $maxRecommendations: Int!) {
      getSlateLineup(
        slateLineupId: $lineupID
        recommendationCount: $maxRecommendations
      ) {
        __typename
        id
        slates {
          __typename
          id
          displayName
          description
          recommendations {
            __typename
            id
            itemId
            feedId
            publisher
            recSrc
            item {
              __typename
              ...ItemParts
            }
          }
        }
      }
    }
    """

  public let operationName: String = "GetSlateLineup"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + ItemParts.fragmentDefinition)
    return document
  }

  public var lineupID: String
  public var maxRecommendations: Int

  public init(lineupID: String, maxRecommendations: Int) {
    self.lineupID = lineupID
    self.maxRecommendations = maxRecommendations
  }

  public var variables: GraphQLMap? {
    return ["lineupID": lineupID, "maxRecommendations": maxRecommendations]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSlateLineup", arguments: ["slateLineupId": GraphQLVariable("lineupID"), "recommendationCount": GraphQLVariable("maxRecommendations")], type: .object(GetSlateLineup.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getSlateLineup: GetSlateLineup? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getSlateLineup": getSlateLineup.flatMap { (value: GetSlateLineup) -> ResultMap in value.resultMap }])
    }

    /// Request a specific `SlateLineup` by id
    public var getSlateLineup: GetSlateLineup? {
      get {
        return (resultMap["getSlateLineup"] as? ResultMap).flatMap { GetSlateLineup(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getSlateLineup")
      }
    }

    public struct GetSlateLineup: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SlateLineup"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("slates", type: .nonNull(.list(.nonNull(.object(Slate.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, slates: [Slate]) {
        self.init(unsafeResultMap: ["__typename": "SlateLineup", "id": id, "slates": slates.map { (value: Slate) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A unique slug/id that describes a SlateLineup. The Data & Learning team will provide apps what id to use here for specific cases.
      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      /// An ordered list of slates for the client to display
      public var slates: [Slate] {
        get {
          return (resultMap["slates"] as! [ResultMap]).map { (value: ResultMap) -> Slate in Slate(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Slate) -> ResultMap in value.resultMap }, forKey: "slates")
        }
      }

      public struct Slate: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Slate"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("displayName", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("recommendations", type: .nonNull(.list(.nonNull(.object(Recommendation.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, displayName: String? = nil, description: String? = nil, recommendations: [Recommendation]) {
          self.init(unsafeResultMap: ["__typename": "Slate", "id": id, "displayName": displayName, "description": description, "recommendations": recommendations.map { (value: Recommendation) -> ResultMap in value.resultMap }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        public var id: String {
          get {
            return resultMap["id"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// The name to show to the user for this set of recomendations
        public var displayName: String? {
          get {
            return resultMap["displayName"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "displayName")
          }
        }

        /// The description of the the slate
        public var description: String? {
          get {
            return resultMap["description"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "description")
          }
        }

        /// An ordered list of the recomendations to show to the user
        public var recommendations: [Recommendation] {
          get {
            return (resultMap["recommendations"] as! [ResultMap]).map { (value: ResultMap) -> Recommendation in Recommendation(unsafeResultMap: value) }
          }
          set {
            resultMap.updateValue(newValue.map { (value: Recommendation) -> ResultMap in value.resultMap }, forKey: "recommendations")
          }
        }

        public struct Recommendation: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Recommendation"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(GraphQLID.self)),
              GraphQLField("itemId", type: .nonNull(.scalar(GraphQLID.self))),
              GraphQLField("feedId", type: .scalar(Int.self)),
              GraphQLField("publisher", type: .scalar(String.self)),
              GraphQLField("recSrc", type: .nonNull(.scalar(String.self))),
              GraphQLField("item", type: .nonNull(.object(Item.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID? = nil, itemId: GraphQLID, feedId: Int? = nil, publisher: String? = nil, recSrc: String, item: Item) {
            self.init(unsafeResultMap: ["__typename": "Recommendation", "id": id, "itemId": itemId, "feedId": feedId, "publisher": publisher, "recSrc": recSrc, "item": item.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A generated id from the Data and Learning team that represents the Recomendation
          public var id: GraphQLID? {
            get {
              return resultMap["id"] as? GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "id")
            }
          }

          /// The ID of the item this recomendation represents
          /// TODO: Use apollo federation to turn this into an Item type.
          public var itemId: GraphQLID {
            get {
              return resultMap["itemId"]! as! GraphQLID
            }
            set {
              resultMap.updateValue(newValue, forKey: "itemId")
            }
          }

          /// The feed id from mysql that this item was curated from (if it was curated)
          public var feedId: Int? {
            get {
              return resultMap["feedId"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "feedId")
            }
          }

          /// The publisher of the item
          public var publisher: String? {
            get {
              return resultMap["publisher"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "publisher")
            }
          }

          /// The source of the recommendation
          public var recSrc: String {
            get {
              return resultMap["recSrc"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "recSrc")
            }
          }

          /// The Item that is resolved by apollo federation using the itemId
          public var item: Item {
            get {
              return Item(unsafeResultMap: resultMap["item"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "item")
            }
          }

          public struct Item: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Item"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("title", type: .scalar(String.self)),
                GraphQLField("language", type: .scalar(String.self)),
                GraphQLField("topImageUrl", type: .scalar(String.self)),
                GraphQLField("timeToRead", type: .scalar(Int.self)),
                GraphQLField("domain", type: .scalar(String.self)),
                GraphQLField("particleJson", type: .scalar(String.self)),
                GraphQLField("excerpt", type: .scalar(String.self)),
                GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
                GraphQLField("images", type: .list(.object(Image.selections))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, particleJson: String? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Item", "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "particleJson": particleJson, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// The title as determined by the parser.
            public var title: String? {
              get {
                return resultMap["title"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "title")
              }
            }

            /// The detected language of the article
            public var language: String? {
              get {
                return resultMap["language"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "language")
              }
            }

            /// The page's / publisher's preferred thumbnail image
            public var topImageUrl: String? {
              get {
                return resultMap["topImageUrl"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "topImageUrl")
              }
            }

            /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
            public var timeToRead: Int? {
              get {
                return resultMap["timeToRead"] as? Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "timeToRead")
              }
            }

            /// The domain, such as 'getpocket.com' of the {.resolved_url}
            public var domain: String? {
              get {
                return resultMap["domain"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "domain")
              }
            }

            /// The pocket particle format of the article. Json encoded string.
            /// Reserving the particle field for when we decide to define the
            /// particle format/schema in the graph
            public var particleJson: String? {
              get {
                return resultMap["particleJson"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "particleJson")
              }
            }

            /// A snippet of text from the article
            public var excerpt: String? {
              get {
                return resultMap["excerpt"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "excerpt")
              }
            }

            /// Additional information about the item domain, when present, use this for displaying the domain name
            public var domainMetadata: DomainMetadatum? {
              get {
                return (resultMap["domainMetadata"] as? ResultMap).flatMap { DomainMetadatum(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "domainMetadata")
              }
            }

            /// Array of images within an article
            public var images: [Image?]? {
              get {
                return (resultMap["images"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Image?] in value.map { (value: ResultMap?) -> Image? in value.flatMap { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }, forKey: "images")
              }
            }

            public var fragments: Fragments {
              get {
                return Fragments(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public struct Fragments {
              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public var itemParts: ItemParts {
                get {
                  return ItemParts(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
              }
            }

            public struct DomainMetadatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DomainMetadata"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("name", type: .scalar(String.self)),
                  GraphQLField("logo", type: .scalar(String.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(name: String? = nil, logo: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "DomainMetadata", "name": name, "logo": logo])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// The name of the domain (e.g., The New York Times)
              public var name: String? {
                get {
                  return resultMap["name"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "name")
                }
              }

              /// Url for the logo image
              public var logo: String? {
                get {
                  return resultMap["logo"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "logo")
                }
              }
            }

            public struct Image: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Image"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("height", type: .scalar(Int.self)),
                  GraphQLField("width", type: .scalar(Int.self)),
                  GraphQLField("src", type: .scalar(String.self)),
                  GraphQLField("imageId", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(height: Int? = nil, width: Int? = nil, src: String? = nil, imageId: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Image", "height": height, "width": width, "src": src, "imageId": imageId])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// If known, the height of the image in px
              public var height: Int? {
                get {
                  return resultMap["height"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "height")
                }
              }

              /// If known, the width of the image in px
              public var width: Int? {
                get {
                  return resultMap["width"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "width")
                }
              }

              /// Absolute url to the image
              public var src: String? {
                get {
                  return resultMap["src"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "src")
                }
              }

              /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
              public var imageId: Int? {
                get {
                  return resultMap["imageId"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "imageId")
                }
              }
            }
          }
        }
      }
    }
  }
}

public struct SavedItemParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment SavedItemParts on SavedItem {
      __typename
      itemId: id
      url
      isArchived
      isFavorite
      _deletedAt
      _createdAt
      item {
        __typename
        ...ItemParts
        ...PendingItemParts
      }
    }
    """

  public static let possibleTypes: [String] = ["SavedItem"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", alias: "itemId", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("url", type: .nonNull(.scalar(String.self))),
      GraphQLField("isArchived", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("isFavorite", type: .nonNull(.scalar(Bool.self))),
      GraphQLField("_deletedAt", type: .scalar(Int.self)),
      GraphQLField("_createdAt", type: .nonNull(.scalar(Int.self))),
      GraphQLField("item", type: .nonNull(.object(Item.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(itemId: GraphQLID, url: String, isArchived: Bool, isFavorite: Bool, _deletedAt: Int? = nil, _createdAt: Int, item: Item) {
    self.init(unsafeResultMap: ["__typename": "SavedItem", "itemId": itemId, "url": url, "isArchived": isArchived, "isFavorite": isFavorite, "_deletedAt": _deletedAt, "_createdAt": _createdAt, "item": item.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
  public var itemId: GraphQLID {
    get {
      return resultMap["itemId"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "itemId")
    }
  }

  /// The url the user saved to their list
  public var url: String {
    get {
      return resultMap["url"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "url")
    }
  }

  /// Helper property to indicate if the SavedItem is archived
  public var isArchived: Bool {
    get {
      return resultMap["isArchived"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isArchived")
    }
  }

  /// Helper property to indicate if the SavedItem is favorited
  public var isFavorite: Bool {
    get {
      return resultMap["isFavorite"]! as! Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isFavorite")
    }
  }

  /// Unix timestamp of when the entity was deleted, 30 days after this date this entity will be HARD deleted from the database and no longer exist
  public var _deletedAt: Int? {
    get {
      return resultMap["_deletedAt"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "_deletedAt")
    }
  }

  /// Unix timestamp of when the entity was created
  public var _createdAt: Int {
    get {
      return resultMap["_createdAt"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "_createdAt")
    }
  }

  /// Link to the underlying Pocket Item for the URL
  public var item: Item {
    get {
      return Item(unsafeResultMap: resultMap["item"]! as! ResultMap)
    }
    set {
      resultMap.updateValue(newValue.resultMap, forKey: "item")
    }
  }

  public struct Item: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["PendingItem", "Item"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["Item": AsItem.selections, "PendingItem": AsPendingItem.selections],
          default: [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          ]
        )
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public static func makeItem(title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, particleJson: String? = nil, excerpt: String? = nil, domainMetadata: AsItem.DomainMetadatum? = nil, images: [AsItem.Image?]? = nil) -> Item {
      return Item(unsafeResultMap: ["__typename": "Item", "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "particleJson": particleJson, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: AsItem.DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [AsItem.Image?]) -> [ResultMap?] in value.map { (value: AsItem.Image?) -> ResultMap? in value.flatMap { (value: AsItem.Image) -> ResultMap in value.resultMap } } }])
    }

    public static func makePendingItem(url: String, status: PendingItemStatus? = nil) -> Item {
      return Item(unsafeResultMap: ["__typename": "PendingItem", "url": url, "status": status])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    public var fragments: Fragments {
      get {
        return Fragments(unsafeResultMap: resultMap)
      }
      set {
        resultMap += newValue.resultMap
      }
    }

    public struct Fragments {
      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public var itemParts: ItemParts? {
        get {
          if !ItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return ItemParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var pendingItemParts: PendingItemParts? {
        get {
          if !PendingItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return PendingItemParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }
    }

    public var asItem: AsItem? {
      get {
        if !AsItem.possibleTypes.contains(__typename) { return nil }
        return AsItem(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Item"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("language", type: .scalar(String.self)),
          GraphQLField("topImageUrl", type: .scalar(String.self)),
          GraphQLField("timeToRead", type: .scalar(Int.self)),
          GraphQLField("domain", type: .scalar(String.self)),
          GraphQLField("particleJson", type: .scalar(String.self)),
          GraphQLField("excerpt", type: .scalar(String.self)),
          GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
          GraphQLField("images", type: .list(.object(Image.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, particleJson: String? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Item", "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "particleJson": particleJson, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// The title as determined by the parser.
      public var title: String? {
        get {
          return resultMap["title"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }

      /// The detected language of the article
      public var language: String? {
        get {
          return resultMap["language"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "language")
        }
      }

      /// The page's / publisher's preferred thumbnail image
      public var topImageUrl: String? {
        get {
          return resultMap["topImageUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "topImageUrl")
        }
      }

      /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
      public var timeToRead: Int? {
        get {
          return resultMap["timeToRead"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "timeToRead")
        }
      }

      /// The domain, such as 'getpocket.com' of the {.resolved_url}
      public var domain: String? {
        get {
          return resultMap["domain"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "domain")
        }
      }

      /// The pocket particle format of the article. Json encoded string.
      /// Reserving the particle field for when we decide to define the
      /// particle format/schema in the graph
      public var particleJson: String? {
        get {
          return resultMap["particleJson"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "particleJson")
        }
      }

      /// A snippet of text from the article
      public var excerpt: String? {
        get {
          return resultMap["excerpt"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "excerpt")
        }
      }

      /// Additional information about the item domain, when present, use this for displaying the domain name
      public var domainMetadata: DomainMetadatum? {
        get {
          return (resultMap["domainMetadata"] as? ResultMap).flatMap { DomainMetadatum(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "domainMetadata")
        }
      }

      /// Array of images within an article
      public var images: [Image?]? {
        get {
          return (resultMap["images"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Image?] in value.map { (value: ResultMap?) -> Image? in value.flatMap { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }, forKey: "images")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var itemParts: ItemParts {
          get {
            return ItemParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var pendingItemParts: PendingItemParts? {
          get {
            if !PendingItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return PendingItemParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }

      public struct DomainMetadatum: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["DomainMetadata"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("logo", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(name: String? = nil, logo: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "DomainMetadata", "name": name, "logo": logo])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// The name of the domain (e.g., The New York Times)
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// Url for the logo image
        public var logo: String? {
          get {
            return resultMap["logo"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "logo")
          }
        }
      }

      public struct Image: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Image"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("height", type: .scalar(Int.self)),
            GraphQLField("width", type: .scalar(Int.self)),
            GraphQLField("src", type: .scalar(String.self)),
            GraphQLField("imageId", type: .scalar(Int.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Int? = nil, width: Int? = nil, src: String? = nil, imageId: Int? = nil) {
          self.init(unsafeResultMap: ["__typename": "Image", "height": height, "width": width, "src": src, "imageId": imageId])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// If known, the height of the image in px
        public var height: Int? {
          get {
            return resultMap["height"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "height")
          }
        }

        /// If known, the width of the image in px
        public var width: Int? {
          get {
            return resultMap["width"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "width")
          }
        }

        /// Absolute url to the image
        public var src: String? {
          get {
            return resultMap["src"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "src")
          }
        }

        /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
        public var imageId: Int? {
          get {
            return resultMap["imageId"] as? Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "imageId")
          }
        }
      }
    }

    public var asPendingItem: AsPendingItem? {
      get {
        if !AsPendingItem.possibleTypes.contains(__typename) { return nil }
        return AsPendingItem(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsPendingItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["PendingItem"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
          GraphQLField("status", type: .scalar(PendingItemStatus.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(url: String, status: PendingItemStatus? = nil) {
        self.init(unsafeResultMap: ["__typename": "PendingItem", "url": url, "status": status])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// URL of the item that the user gave for the SavedItem
      /// that is pending processing by parser
      public var url: String {
        get {
          return resultMap["url"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "url")
        }
      }

      public var status: PendingItemStatus? {
        get {
          return resultMap["status"] as? PendingItemStatus
        }
        set {
          resultMap.updateValue(newValue, forKey: "status")
        }
      }

      public var fragments: Fragments {
        get {
          return Fragments(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
      }

      public struct Fragments {
        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public var itemParts: ItemParts? {
          get {
            if !ItemParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ItemParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var pendingItemParts: PendingItemParts {
          get {
            return PendingItemParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }
}

public struct ItemParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ItemParts on Item {
      __typename
      title
      language
      topImageUrl
      timeToRead
      domain
      particleJson
      excerpt
      domainMetadata {
        __typename
        name
        logo
      }
      images {
        __typename
        height
        width
        src
        imageId
      }
    }
    """

  public static let possibleTypes: [String] = ["Item"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("title", type: .scalar(String.self)),
      GraphQLField("language", type: .scalar(String.self)),
      GraphQLField("topImageUrl", type: .scalar(String.self)),
      GraphQLField("timeToRead", type: .scalar(Int.self)),
      GraphQLField("domain", type: .scalar(String.self)),
      GraphQLField("particleJson", type: .scalar(String.self)),
      GraphQLField("excerpt", type: .scalar(String.self)),
      GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
      GraphQLField("images", type: .list(.object(Image.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, particleJson: String? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
    self.init(unsafeResultMap: ["__typename": "Item", "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "particleJson": particleJson, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// The title as determined by the parser.
  public var title: String? {
    get {
      return resultMap["title"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "title")
    }
  }

  /// The detected language of the article
  public var language: String? {
    get {
      return resultMap["language"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "language")
    }
  }

  /// The page's / publisher's preferred thumbnail image
  public var topImageUrl: String? {
    get {
      return resultMap["topImageUrl"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "topImageUrl")
    }
  }

  /// How long it will take to read the article (TODO in what time unit? and by what calculation?)
  public var timeToRead: Int? {
    get {
      return resultMap["timeToRead"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "timeToRead")
    }
  }

  /// The domain, such as 'getpocket.com' of the {.resolved_url}
  public var domain: String? {
    get {
      return resultMap["domain"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "domain")
    }
  }

  /// The pocket particle format of the article. Json encoded string.
  /// Reserving the particle field for when we decide to define the
  /// particle format/schema in the graph
  public var particleJson: String? {
    get {
      return resultMap["particleJson"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "particleJson")
    }
  }

  /// A snippet of text from the article
  public var excerpt: String? {
    get {
      return resultMap["excerpt"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "excerpt")
    }
  }

  /// Additional information about the item domain, when present, use this for displaying the domain name
  public var domainMetadata: DomainMetadatum? {
    get {
      return (resultMap["domainMetadata"] as? ResultMap).flatMap { DomainMetadatum(unsafeResultMap: $0) }
    }
    set {
      resultMap.updateValue(newValue?.resultMap, forKey: "domainMetadata")
    }
  }

  /// Array of images within an article
  public var images: [Image?]? {
    get {
      return (resultMap["images"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Image?] in value.map { (value: ResultMap?) -> Image? in value.flatMap { (value: ResultMap) -> Image in Image(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }, forKey: "images")
    }
  }

  public struct DomainMetadatum: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["DomainMetadata"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("logo", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(name: String? = nil, logo: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "DomainMetadata", "name": name, "logo": logo])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// The name of the domain (e.g., The New York Times)
    public var name: String? {
      get {
        return resultMap["name"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// Url for the logo image
    public var logo: String? {
      get {
        return resultMap["logo"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "logo")
      }
    }
  }

  public struct Image: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Image"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("height", type: .scalar(Int.self)),
        GraphQLField("width", type: .scalar(Int.self)),
        GraphQLField("src", type: .scalar(String.self)),
        GraphQLField("imageId", type: .scalar(Int.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(height: Int? = nil, width: Int? = nil, src: String? = nil, imageId: Int? = nil) {
      self.init(unsafeResultMap: ["__typename": "Image", "height": height, "width": width, "src": src, "imageId": imageId])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// If known, the height of the image in px
    public var height: Int? {
      get {
        return resultMap["height"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "height")
      }
    }

    /// If known, the width of the image in px
    public var width: Int? {
      get {
        return resultMap["width"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "width")
      }
    }

    /// Absolute url to the image
    public var src: String? {
      get {
        return resultMap["src"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "src")
      }
    }

    /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
    public var imageId: Int? {
      get {
        return resultMap["imageId"] as? Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "imageId")
      }
    }
  }
}

public struct PendingItemParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment PendingItemParts on PendingItem {
      __typename
      url
      status
    }
    """

  public static let possibleTypes: [String] = ["PendingItem"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("url", type: .nonNull(.scalar(String.self))),
      GraphQLField("status", type: .scalar(PendingItemStatus.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(url: String, status: PendingItemStatus? = nil) {
    self.init(unsafeResultMap: ["__typename": "PendingItem", "url": url, "status": status])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// URL of the item that the user gave for the SavedItem
  /// that is pending processing by parser
  public var url: String {
    get {
      return resultMap["url"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "url")
    }
  }

  public var status: PendingItemStatus? {
    get {
      return resultMap["status"] as? PendingItemStatus
    }
    set {
      resultMap.updateValue(newValue, forKey: "status")
    }
  }
}
