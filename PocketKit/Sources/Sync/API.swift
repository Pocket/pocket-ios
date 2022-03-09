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

/// Input field for upserting a SavedItem
public struct SavedItemUpsertInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - url: The url to create/update the SavedItem with. (the url to save to the list)
  ///   - isFavorite: Optional, create/update the SavedItem as a favorited item
  ///   - timestamp: Optional, time that request was submitted by client epoch/unix time
  public init(url: String, isFavorite: Swift.Optional<Bool?> = nil, timestamp: Swift.Optional<Int?> = nil) {
    graphQLMap = ["url": url, "isFavorite": isFavorite, "timestamp": timestamp]
  }

  /// The url to create/update the SavedItem with. (the url to save to the list)
  public var url: String {
    get {
      return graphQLMap["url"] as! String
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "url")
    }
  }

  /// Optional, create/update the SavedItem as a favorited item
  public var isFavorite: Swift.Optional<Bool?> {
    get {
      return graphQLMap["isFavorite"] as? Swift.Optional<Bool?> ?? Swift.Optional<Bool?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "isFavorite")
    }
  }

  /// Optional, time that request was submitted by client epoch/unix time
  public var timestamp: Swift.Optional<Int?> {
    get {
      return graphQLMap["timestamp"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "timestamp")
    }
  }
}

public enum Imageness: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// No images (v3 value is 0)
  case noImages
  /// Contains images (v3 value is 1)
  case hasImages
  /// Is an image (v3 value is 2)
  case isImage
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NO_IMAGES": self = .noImages
      case "HAS_IMAGES": self = .hasImages
      case "IS_IMAGE": self = .isImage
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .noImages: return "NO_IMAGES"
      case .hasImages: return "HAS_IMAGES"
      case .isImage: return "IS_IMAGE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: Imageness, rhs: Imageness) -> Bool {
    switch (lhs, rhs) {
      case (.noImages, .noImages): return true
      case (.hasImages, .hasImages): return true
      case (.isImage, .isImage): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [Imageness] {
    return [
      .noImages,
      .hasImages,
      .isImage,
    ]
  }
}

public enum Videoness: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// No videos (v3 value is 0)
  case noVideos
  /// Contains videos (v3 value is 1)
  case hasVideos
  /// Is a video (v3 value is 2)
  case isVideo
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "NO_VIDEOS": self = .noVideos
      case "HAS_VIDEOS": self = .hasVideos
      case "IS_VIDEO": self = .isVideo
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .noVideos: return "NO_VIDEOS"
      case .hasVideos: return "HAS_VIDEOS"
      case .isVideo: return "IS_VIDEO"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: Videoness, rhs: Videoness) -> Bool {
    switch (lhs, rhs) {
      case (.noVideos, .noVideos): return true
      case (.hasVideos, .hasVideos): return true
      case (.isVideo, .isVideo): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [Videoness] {
    return [
      .noVideos,
      .hasVideos,
      .isVideo,
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

public enum VideoType: RawRepresentable, Equatable, Hashable, CaseIterable, Apollo.JSONDecodable, Apollo.JSONEncodable {
  public typealias RawValue = String
  /// Youtube (v3 value is 1)
  case youtube
  /// Vimeo Link (v3 value is 2)
  case vimeoLink
  /// Vimeo Moogaloop (v3 value is 3)
  case vimeoMoogaloop
  /// video iframe (v3 value is 4)
  case vimeoIframe
  /// html5 (v3 value is 5)
  case html5
  /// Flash (v3 value is 6)
  case flash
  /// iframe (v3 value is 7)
  case iframe
  /// Brightcove (v3 value is 8)
  case brightcove
  /// Auto generated constant for unknown enum values
  case __unknown(RawValue)

  public init?(rawValue: RawValue) {
    switch rawValue {
      case "YOUTUBE": self = .youtube
      case "VIMEO_LINK": self = .vimeoLink
      case "VIMEO_MOOGALOOP": self = .vimeoMoogaloop
      case "VIMEO_IFRAME": self = .vimeoIframe
      case "HTML5": self = .html5
      case "FLASH": self = .flash
      case "IFRAME": self = .iframe
      case "BRIGHTCOVE": self = .brightcove
      default: self = .__unknown(rawValue)
    }
  }

  public var rawValue: RawValue {
    switch self {
      case .youtube: return "YOUTUBE"
      case .vimeoLink: return "VIMEO_LINK"
      case .vimeoMoogaloop: return "VIMEO_MOOGALOOP"
      case .vimeoIframe: return "VIMEO_IFRAME"
      case .html5: return "HTML5"
      case .flash: return "FLASH"
      case .iframe: return "IFRAME"
      case .brightcove: return "BRIGHTCOVE"
      case .__unknown(let value): return value
    }
  }

  public static func == (lhs: VideoType, rhs: VideoType) -> Bool {
    switch (lhs, rhs) {
      case (.youtube, .youtube): return true
      case (.vimeoLink, .vimeoLink): return true
      case (.vimeoMoogaloop, .vimeoMoogaloop): return true
      case (.vimeoIframe, .vimeoIframe): return true
      case (.html5, .html5): return true
      case (.flash, .flash): return true
      case (.iframe, .iframe): return true
      case (.brightcove, .brightcove): return true
      case (.__unknown(let lhsValue), .__unknown(let rhsValue)): return lhsValue == rhsValue
      default: return false
    }
  }

  public static var allCases: [VideoType] {
    return [
      .youtube,
      .vimeoLink,
      .vimeoMoogaloop,
      .vimeoIframe,
      .html5,
      .flash,
      .iframe,
      .brightcove,
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
    document.append("\n" + MarticleTextParts.fragmentDefinition)
    document.append("\n" + ImageParts.fragmentDefinition)
    document.append("\n" + MarticleDividerParts.fragmentDefinition)
    document.append("\n" + MarticleTableParts.fragmentDefinition)
    document.append("\n" + MarticleHeadingParts.fragmentDefinition)
    document.append("\n" + MarticleCodeBlockParts.fragmentDefinition)
    document.append("\n" + VideoParts.fragmentDefinition)
    document.append("\n" + MarticleBulletedListParts.fragmentDefinition)
    document.append("\n" + MarticleNumberedListParts.fragmentDefinition)
    document.append("\n" + MarticleBlockquoteParts.fragmentDefinition)
    document.append("\n" + DomainMetadataParts.fragmentDefinition)
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
                GraphQLField("url", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", alias: "remoteID", type: .nonNull(.scalar(GraphQLID.self))),
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

            public init(url: String, remoteId: GraphQLID, isArchived: Bool, isFavorite: Bool, _deletedAt: Int? = nil, _createdAt: Int, item: Item) {
              self.init(unsafeResultMap: ["__typename": "SavedItem", "url": url, "remoteID": remoteId, "isArchived": isArchived, "isFavorite": isFavorite, "_deletedAt": _deletedAt, "_createdAt": _createdAt, "item": item.resultMap])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
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

            /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
            public var remoteId: GraphQLID {
              get {
                return resultMap["remoteID"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "remoteID")
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

              public static func makeItem(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [AsItem.Author?]? = nil, marticle: [AsItem.Marticle]? = nil, excerpt: String? = nil, domainMetadata: AsItem.DomainMetadatum? = nil, images: [AsItem.Image?]? = nil) -> Item {
                return Item(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [AsItem.Author?]) -> [ResultMap?] in value.map { (value: AsItem.Author?) -> ResultMap? in value.flatMap { (value: AsItem.Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [AsItem.Marticle]) -> [ResultMap] in value.map { (value: AsItem.Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: AsItem.DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [AsItem.Image?]) -> [ResultMap?] in value.map { (value: AsItem.Image?) -> ResultMap? in value.flatMap { (value: AsItem.Image) -> ResultMap in value.resultMap } } }])
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
                    GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
                    GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
                    GraphQLField("resolvedUrl", type: .scalar(String.self)),
                    GraphQLField("title", type: .scalar(String.self)),
                    GraphQLField("language", type: .scalar(String.self)),
                    GraphQLField("topImageUrl", type: .scalar(String.self)),
                    GraphQLField("timeToRead", type: .scalar(Int.self)),
                    GraphQLField("domain", type: .scalar(String.self)),
                    GraphQLField("datePublished", type: .scalar(String.self)),
                    GraphQLField("isArticle", type: .scalar(Bool.self)),
                    GraphQLField("hasImage", type: .scalar(Imageness.self)),
                    GraphQLField("hasVideo", type: .scalar(Videoness.self)),
                    GraphQLField("authors", type: .list(.object(Author.selections))),
                    GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
                    GraphQLField("excerpt", type: .scalar(String.self)),
                    GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
                    GraphQLField("images", type: .list(.object(Image.selections))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
                  self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
                public var remoteId: String {
                  get {
                    return resultMap["remoteID"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "remoteID")
                  }
                }

                /// The url as provided by the user when saving. Only http or https schemes allowed.
                public var givenUrl: String {
                  get {
                    return resultMap["givenUrl"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "givenUrl")
                  }
                }

                /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
                public var resolvedUrl: String? {
                  get {
                    return resultMap["resolvedUrl"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

                /// The date the article was published
                public var datePublished: String? {
                  get {
                    return resultMap["datePublished"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "datePublished")
                  }
                }

                /// true if the item is an article
                public var isArticle: Bool? {
                  get {
                    return resultMap["isArticle"] as? Bool
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "isArticle")
                  }
                }

                /// 0=no images, 1=contains images, 2=is an image
                public var hasImage: Imageness? {
                  get {
                    return resultMap["hasImage"] as? Imageness
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "hasImage")
                  }
                }

                /// 0=no videos, 1=contains video, 2=is a video
                public var hasVideo: Videoness? {
                  get {
                    return resultMap["hasVideo"] as? Videoness
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "hasVideo")
                  }
                }

                /// List of Authors involved with this article
                public var authors: [Author?]? {
                  get {
                    return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
                  }
                }

                /// The Marticle format of the article, used by clients for native article view.
                public var marticle: [Marticle]? {
                  get {
                    return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
                  }
                  set {
                    resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

                public struct Author: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["Author"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                      GraphQLField("name", type: .scalar(String.self)),
                      GraphQLField("url", type: .scalar(String.self)),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
                    self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// Unique id for that Author
                  public var id: GraphQLID {
                    get {
                      return resultMap["id"]! as! GraphQLID
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "id")
                    }
                  }

                  /// Display name
                  public var name: String? {
                    get {
                      return resultMap["name"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "name")
                    }
                  }

                  /// A url to that Author's site
                  public var url: String? {
                    get {
                      return resultMap["url"] as? String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "url")
                    }
                  }
                }

                public struct Marticle: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLTypeCase(
                        variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

                  public static func makeUnMarseable() -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
                  }

                  public static func makeMarticleText(content: String) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
                  }

                  public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
                  }

                  public static func makeMarticleDivider(content: String) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
                  }

                  public static func makeMarticleTable(html: String) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
                  }

                  public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
                  }

                  public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
                  }

                  public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
                  }

                  public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
                  }

                  public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
                  }

                  public static func makeMarticleBlockquote(content: String) -> Marticle {
                    return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

                    public var marticleTextParts: MarticleTextParts? {
                      get {
                        if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleTextParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var imageParts: ImageParts? {
                      get {
                        if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return ImageParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleDividerParts: MarticleDividerParts? {
                      get {
                        if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleDividerParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleTableParts: MarticleTableParts? {
                      get {
                        if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleTableParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleHeadingParts: MarticleHeadingParts? {
                      get {
                        if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleHeadingParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                      get {
                        if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var videoParts: VideoParts? {
                      get {
                        if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return VideoParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleBulletedListParts: MarticleBulletedListParts? {
                      get {
                        if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleBulletedListParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleNumberedListParts: MarticleNumberedListParts? {
                      get {
                        if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleNumberedListParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }

                    public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                      get {
                        if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                        return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                      }
                      set {
                        guard let newValue = newValue else { return }
                        resultMap += newValue.resultMap
                      }
                    }
                  }

                  public var asMarticleText: AsMarticleText? {
                    get {
                      if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleText(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleText: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleText"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("content", type: .nonNull(.scalar(String.self))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(content: String) {
                      self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// Markdown text content. Typically, a paragraph.
                    public var content: String {
                      get {
                        return resultMap["content"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "content")
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

                      public var marticleTextParts: MarticleTextParts {
                        get {
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asImage: AsImage? {
                    get {
                      if !AsImage.possibleTypes.contains(__typename) { return nil }
                      return AsImage(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsImage: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["Image"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("caption", type: .scalar(String.self)),
                        GraphQLField("credit", type: .scalar(String.self)),
                        GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
                        GraphQLField("src", type: .nonNull(.scalar(String.self))),
                        GraphQLField("height", type: .scalar(Int.self)),
                        GraphQLField("width", type: .scalar(Int.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
                      self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// A caption or description of the image
                    public var caption: String? {
                      get {
                        return resultMap["caption"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "caption")
                      }
                    }

                    /// A credit for the image, typically who the image belongs to / created by
                    public var credit: String? {
                      get {
                        return resultMap["credit"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "credit")
                      }
                    }

                    /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
                    public var imageId: Int {
                      get {
                        return resultMap["imageID"]! as! Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "imageID")
                      }
                    }

                    /// Absolute url to the image
                    public var src: String {
                      get {
                        return resultMap["src"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "src")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts {
                        get {
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asMarticleDivider: AsMarticleDivider? {
                    get {
                      if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleDivider(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleDivider: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleDivider"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("content", type: .nonNull(.scalar(String.self))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(content: String) {
                      self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// Always '---'; provided for convenience if building a markdown string
                    public var content: String {
                      get {
                        return resultMap["content"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "content")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts {
                        get {
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asMarticleTable: AsMarticleTable? {
                    get {
                      if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleTable(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleTable: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleTable"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("html", type: .nonNull(.scalar(String.self))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(html: String) {
                      self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// Raw HTML representation of the table.
                    public var html: String {
                      get {
                        return resultMap["html"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "html")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts {
                        get {
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asMarticleHeading: AsMarticleHeading? {
                    get {
                      if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleHeading(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleHeading: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleHeading"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("content", type: .nonNull(.scalar(String.self))),
                        GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(content: String, level: Int) {
                      self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// Heading text, in markdown.
                    public var content: String {
                      get {
                        return resultMap["content"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "content")
                      }
                    }

                    /// Heading level. Restricted to values 1-6.
                    public var level: Int {
                      get {
                        return resultMap["level"]! as! Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "level")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts {
                        get {
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asMarticleCodeBlock: AsMarticleCodeBlock? {
                    get {
                      if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleCodeBlock(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleCodeBlock: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleCodeBlock"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("text", type: .nonNull(.scalar(String.self))),
                        GraphQLField("language", type: .scalar(Int.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(text: String, language: Int? = nil) {
                      self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// Content of a pre tag
                    public var text: String {
                      get {
                        return resultMap["text"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "text")
                      }
                    }

                    /// Assuming the codeblock was a programming language, this field is used to identify it.
                    public var language: Int? {
                      get {
                        return resultMap["language"] as? Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "language")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts {
                        get {
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asVideo: AsVideo? {
                    get {
                      if !AsVideo.possibleTypes.contains(__typename) { return nil }
                      return AsVideo(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsVideo: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["Video"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("height", type: .scalar(Int.self)),
                        GraphQLField("src", type: .nonNull(.scalar(String.self))),
                        GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
                        GraphQLField("vid", type: .scalar(String.self)),
                        GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
                        GraphQLField("width", type: .scalar(Int.self)),
                        GraphQLField("length", type: .scalar(Int.self)),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
                      self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// If known, the height of the video in px
                    public var height: Int? {
                      get {
                        return resultMap["height"] as? Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "height")
                      }
                    }

                    /// Absolute url to the video
                    public var src: String {
                      get {
                        return resultMap["src"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "src")
                      }
                    }

                    /// The type of video
                    public var type: VideoType {
                      get {
                        return resultMap["type"]! as! VideoType
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "type")
                      }
                    }

                    /// The video's id within the service defined by type
                    public var vid: String? {
                      get {
                        return resultMap["vid"] as? String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "vid")
                      }
                    }

                    /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
                    public var videoId: Int {
                      get {
                        return resultMap["videoID"]! as! Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "videoID")
                      }
                    }

                    /// If known, the width of the video in px
                    public var width: Int? {
                      get {
                        return resultMap["width"] as? Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "width")
                      }
                    }

                    /// If known, the length of the video in seconds
                    public var length: Int? {
                      get {
                        return resultMap["length"] as? Int
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "length")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts {
                        get {
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }

                  public var asMarticleBulletedList: AsMarticleBulletedList? {
                    get {
                      if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleBulletedList(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleBulletedList: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleBulletedList"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(rows: [Row]) {
                      self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var rows: [Row] {
                      get {
                        return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                      }
                      set {
                        resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts {
                        get {
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }

                    public struct Row: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["BulletedListElement"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("content", type: .nonNull(.scalar(String.self))),
                          GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(content: String, level: Int) {
                        self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      /// Row in a list.
                      public var content: String {
                        get {
                          return resultMap["content"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "content")
                        }
                      }

                      /// Zero-indexed level, for handling nested lists.
                      public var level: Int {
                        get {
                          return resultMap["level"]! as! Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "level")
                        }
                      }
                    }
                  }

                  public var asMarticleNumberedList: AsMarticleNumberedList? {
                    get {
                      if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleNumberedList(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleNumberedList: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleNumberedList"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(rows: [Row]) {
                      self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    public var rows: [Row] {
                      get {
                        return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                      }
                      set {
                        resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts {
                        get {
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                        get {
                          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }
                    }

                    public struct Row: GraphQLSelectionSet {
                      public static let possibleTypes: [String] = ["NumberedListElement"]

                      public static var selections: [GraphQLSelection] {
                        return [
                          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                          GraphQLField("content", type: .nonNull(.scalar(String.self))),
                          GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                          GraphQLField("index", type: .nonNull(.scalar(Int.self))),
                        ]
                      }

                      public private(set) var resultMap: ResultMap

                      public init(unsafeResultMap: ResultMap) {
                        self.resultMap = unsafeResultMap
                      }

                      public init(content: String, level: Int, index: Int) {
                        self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
                      }

                      public var __typename: String {
                        get {
                          return resultMap["__typename"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "__typename")
                        }
                      }

                      /// Row in a list
                      public var content: String {
                        get {
                          return resultMap["content"]! as! String
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "content")
                        }
                      }

                      /// Zero-indexed level, for handling nexted lists.
                      public var level: Int {
                        get {
                          return resultMap["level"]! as! Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "level")
                        }
                      }

                      /// Numeric index. If a nested item, the index is zero-indexed from the first child.
                      public var index: Int {
                        get {
                          return resultMap["index"]! as! Int
                        }
                        set {
                          resultMap.updateValue(newValue, forKey: "index")
                        }
                      }
                    }
                  }

                  public var asMarticleBlockquote: AsMarticleBlockquote? {
                    get {
                      if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
                      return AsMarticleBlockquote(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap = newValue.resultMap
                    }
                  }

                  public struct AsMarticleBlockquote: GraphQLSelectionSet {
                    public static let possibleTypes: [String] = ["MarticleBlockquote"]

                    public static var selections: [GraphQLSelection] {
                      return [
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                        GraphQLField("content", type: .nonNull(.scalar(String.self))),
                      ]
                    }

                    public private(set) var resultMap: ResultMap

                    public init(unsafeResultMap: ResultMap) {
                      self.resultMap = unsafeResultMap
                    }

                    public init(content: String) {
                      self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
                    }

                    public var __typename: String {
                      get {
                        return resultMap["__typename"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "__typename")
                      }
                    }

                    /// Markdown text content.
                    public var content: String {
                      get {
                        return resultMap["content"]! as! String
                      }
                      set {
                        resultMap.updateValue(newValue, forKey: "content")
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

                      public var marticleTextParts: MarticleTextParts? {
                        get {
                          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTextParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var imageParts: ImageParts? {
                        get {
                          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return ImageParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleDividerParts: MarticleDividerParts? {
                        get {
                          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleDividerParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleTableParts: MarticleTableParts? {
                        get {
                          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleTableParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleHeadingParts: MarticleHeadingParts? {
                        get {
                          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleHeadingParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                        get {
                          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var videoParts: VideoParts? {
                        get {
                          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return VideoParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBulletedListParts: MarticleBulletedListParts? {
                        get {
                          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleBulletedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleNumberedListParts: MarticleNumberedListParts? {
                        get {
                          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                          return MarticleNumberedListParts(unsafeResultMap: resultMap)
                        }
                        set {
                          guard let newValue = newValue else { return }
                          resultMap += newValue.resultMap
                        }
                      }

                      public var marticleBlockquoteParts: MarticleBlockquoteParts {
                        get {
                          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                        }
                        set {
                          resultMap += newValue.resultMap
                        }
                      }
                    }
                  }
                }

                public struct DomainMetadatum: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["DomainMetadata"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

                    public var domainMetadataParts: DomainMetadataParts {
                      get {
                        return DomainMetadataParts(unsafeResultMap: resultMap)
                      }
                      set {
                        resultMap += newValue.resultMap
                      }
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
                      GraphQLField("src", type: .nonNull(.scalar(String.self))),
                      GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
                  public var src: String {
                    get {
                      return resultMap["src"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "src")
                    }
                  }

                  /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
                  public var imageId: Int {
                    get {
                      return resultMap["imageId"]! as! Int
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

public final class SaveItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation SaveItem($input: SavedItemUpsertInput!) {
      upsertSavedItem(input: $input) {
        __typename
        ...SavedItemParts
      }
    }
    """

  public let operationName: String = "SaveItem"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + SavedItemParts.fragmentDefinition)
    document.append("\n" + ItemParts.fragmentDefinition)
    document.append("\n" + MarticleTextParts.fragmentDefinition)
    document.append("\n" + ImageParts.fragmentDefinition)
    document.append("\n" + MarticleDividerParts.fragmentDefinition)
    document.append("\n" + MarticleTableParts.fragmentDefinition)
    document.append("\n" + MarticleHeadingParts.fragmentDefinition)
    document.append("\n" + MarticleCodeBlockParts.fragmentDefinition)
    document.append("\n" + VideoParts.fragmentDefinition)
    document.append("\n" + MarticleBulletedListParts.fragmentDefinition)
    document.append("\n" + MarticleNumberedListParts.fragmentDefinition)
    document.append("\n" + MarticleBlockquoteParts.fragmentDefinition)
    document.append("\n" + DomainMetadataParts.fragmentDefinition)
    document.append("\n" + PendingItemParts.fragmentDefinition)
    return document
  }

  public var input: SavedItemUpsertInput

  public init(input: SavedItemUpsertInput) {
    self.input = input
  }

  public var variables: GraphQLMap? {
    return ["input": input]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Mutation"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("upsertSavedItem", arguments: ["input": GraphQLVariable("input")], type: .nonNull(.object(UpsertSavedItem.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(upsertSavedItem: UpsertSavedItem) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "upsertSavedItem": upsertSavedItem.resultMap])
    }

    /// Updates a SavedItem, undeletes and unarchives it, bringing it to the top of the user's list, if it exists
    /// and creates it if it doesn't.
    public var upsertSavedItem: UpsertSavedItem {
      get {
        return UpsertSavedItem(unsafeResultMap: resultMap["upsertSavedItem"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "upsertSavedItem")
      }
    }

    public struct UpsertSavedItem: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["SavedItem"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("url", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", alias: "remoteID", type: .nonNull(.scalar(GraphQLID.self))),
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

      public init(url: String, remoteId: GraphQLID, isArchived: Bool, isFavorite: Bool, _deletedAt: Int? = nil, _createdAt: Int, item: Item) {
        self.init(unsafeResultMap: ["__typename": "SavedItem", "url": url, "remoteID": remoteId, "isArchived": isArchived, "isFavorite": isFavorite, "_deletedAt": _deletedAt, "_createdAt": _createdAt, "item": item.resultMap])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
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

      /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
      public var remoteId: GraphQLID {
        get {
          return resultMap["remoteID"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "remoteID")
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

        public static func makeItem(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [AsItem.Author?]? = nil, marticle: [AsItem.Marticle]? = nil, excerpt: String? = nil, domainMetadata: AsItem.DomainMetadatum? = nil, images: [AsItem.Image?]? = nil) -> Item {
          return Item(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [AsItem.Author?]) -> [ResultMap?] in value.map { (value: AsItem.Author?) -> ResultMap? in value.flatMap { (value: AsItem.Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [AsItem.Marticle]) -> [ResultMap] in value.map { (value: AsItem.Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: AsItem.DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [AsItem.Image?]) -> [ResultMap?] in value.map { (value: AsItem.Image?) -> ResultMap? in value.flatMap { (value: AsItem.Image) -> ResultMap in value.resultMap } } }])
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
              GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
              GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
              GraphQLField("resolvedUrl", type: .scalar(String.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("language", type: .scalar(String.self)),
              GraphQLField("topImageUrl", type: .scalar(String.self)),
              GraphQLField("timeToRead", type: .scalar(Int.self)),
              GraphQLField("domain", type: .scalar(String.self)),
              GraphQLField("datePublished", type: .scalar(String.self)),
              GraphQLField("isArticle", type: .scalar(Bool.self)),
              GraphQLField("hasImage", type: .scalar(Imageness.self)),
              GraphQLField("hasVideo", type: .scalar(Videoness.self)),
              GraphQLField("authors", type: .list(.object(Author.selections))),
              GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
              GraphQLField("excerpt", type: .scalar(String.self)),
              GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
              GraphQLField("images", type: .list(.object(Image.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
          public var remoteId: String {
            get {
              return resultMap["remoteID"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "remoteID")
            }
          }

          /// The url as provided by the user when saving. Only http or https schemes allowed.
          public var givenUrl: String {
            get {
              return resultMap["givenUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "givenUrl")
            }
          }

          /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
          public var resolvedUrl: String? {
            get {
              return resultMap["resolvedUrl"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

          /// The date the article was published
          public var datePublished: String? {
            get {
              return resultMap["datePublished"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "datePublished")
            }
          }

          /// true if the item is an article
          public var isArticle: Bool? {
            get {
              return resultMap["isArticle"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isArticle")
            }
          }

          /// 0=no images, 1=contains images, 2=is an image
          public var hasImage: Imageness? {
            get {
              return resultMap["hasImage"] as? Imageness
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasImage")
            }
          }

          /// 0=no videos, 1=contains video, 2=is a video
          public var hasVideo: Videoness? {
            get {
              return resultMap["hasVideo"] as? Videoness
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasVideo")
            }
          }

          /// List of Authors involved with this article
          public var authors: [Author?]? {
            get {
              return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
            }
          }

          /// The Marticle format of the article, used by clients for native article view.
          public var marticle: [Marticle]? {
            get {
              return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

          public struct Author: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Author"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("name", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Unique id for that Author
            public var id: GraphQLID {
              get {
                return resultMap["id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            /// Display name
            public var name: String? {
              get {
                return resultMap["name"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            /// A url to that Author's site
            public var url: String? {
              get {
                return resultMap["url"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "url")
              }
            }
          }

          public struct Marticle: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLTypeCase(
                  variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

            public static func makeUnMarseable() -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
            }

            public static func makeMarticleText(content: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
            }

            public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
            }

            public static func makeMarticleDivider(content: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
            }

            public static func makeMarticleTable(html: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
            }

            public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
            }

            public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
            }

            public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
            }

            public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
            }

            public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
            }

            public static func makeMarticleBlockquote(content: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

              public var marticleTextParts: MarticleTextParts? {
                get {
                  if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleTextParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var imageParts: ImageParts? {
                get {
                  if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return ImageParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleDividerParts: MarticleDividerParts? {
                get {
                  if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleDividerParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleTableParts: MarticleTableParts? {
                get {
                  if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleTableParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleHeadingParts: MarticleHeadingParts? {
                get {
                  if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleHeadingParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                get {
                  if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var videoParts: VideoParts? {
                get {
                  if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return VideoParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleBulletedListParts: MarticleBulletedListParts? {
                get {
                  if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleBulletedListParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleNumberedListParts: MarticleNumberedListParts? {
                get {
                  if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleNumberedListParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                get {
                  if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }
            }

            public var asMarticleText: AsMarticleText? {
              get {
                if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
                return AsMarticleText(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleText: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleText"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Markdown text content. Typically, a paragraph.
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
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

                public var marticleTextParts: MarticleTextParts {
                  get {
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asImage: AsImage? {
              get {
                if !AsImage.possibleTypes.contains(__typename) { return nil }
                return AsImage(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsImage: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Image"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("caption", type: .scalar(String.self)),
                  GraphQLField("credit", type: .scalar(String.self)),
                  GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
                  GraphQLField("src", type: .nonNull(.scalar(String.self))),
                  GraphQLField("height", type: .scalar(Int.self)),
                  GraphQLField("width", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// A caption or description of the image
              public var caption: String? {
                get {
                  return resultMap["caption"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "caption")
                }
              }

              /// A credit for the image, typically who the image belongs to / created by
              public var credit: String? {
                get {
                  return resultMap["credit"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "credit")
                }
              }

              /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
              public var imageId: Int {
                get {
                  return resultMap["imageID"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "imageID")
                }
              }

              /// Absolute url to the image
              public var src: String {
                get {
                  return resultMap["src"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "src")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts {
                  get {
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleDivider: AsMarticleDivider? {
              get {
                if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
                return AsMarticleDivider(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleDivider: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleDivider"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Always '---'; provided for convenience if building a markdown string
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts {
                  get {
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleTable: AsMarticleTable? {
              get {
                if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
                return AsMarticleTable(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleTable: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleTable"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("html", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(html: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Raw HTML representation of the table.
              public var html: String {
                get {
                  return resultMap["html"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "html")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts {
                  get {
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleHeading: AsMarticleHeading? {
              get {
                if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
                return AsMarticleHeading(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleHeading: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleHeading"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                  GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String, level: Int) {
                self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Heading text, in markdown.
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
                }
              }

              /// Heading level. Restricted to values 1-6.
              public var level: Int {
                get {
                  return resultMap["level"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "level")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts {
                  get {
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleCodeBlock: AsMarticleCodeBlock? {
              get {
                if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
                return AsMarticleCodeBlock(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleCodeBlock: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleCodeBlock"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("text", type: .nonNull(.scalar(String.self))),
                  GraphQLField("language", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(text: String, language: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Content of a pre tag
              public var text: String {
                get {
                  return resultMap["text"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              /// Assuming the codeblock was a programming language, this field is used to identify it.
              public var language: Int? {
                get {
                  return resultMap["language"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "language")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts {
                  get {
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asVideo: AsVideo? {
              get {
                if !AsVideo.possibleTypes.contains(__typename) { return nil }
                return AsVideo(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsVideo: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Video"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("height", type: .scalar(Int.self)),
                  GraphQLField("src", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
                  GraphQLField("vid", type: .scalar(String.self)),
                  GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
                  GraphQLField("width", type: .scalar(Int.self)),
                  GraphQLField("length", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// If known, the height of the video in px
              public var height: Int? {
                get {
                  return resultMap["height"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "height")
                }
              }

              /// Absolute url to the video
              public var src: String {
                get {
                  return resultMap["src"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "src")
                }
              }

              /// The type of video
              public var type: VideoType {
                get {
                  return resultMap["type"]! as! VideoType
                }
                set {
                  resultMap.updateValue(newValue, forKey: "type")
                }
              }

              /// The video's id within the service defined by type
              public var vid: String? {
                get {
                  return resultMap["vid"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "vid")
                }
              }

              /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
              public var videoId: Int {
                get {
                  return resultMap["videoID"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "videoID")
                }
              }

              /// If known, the width of the video in px
              public var width: Int? {
                get {
                  return resultMap["width"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "width")
                }
              }

              /// If known, the length of the video in seconds
              public var length: Int? {
                get {
                  return resultMap["length"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "length")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts {
                  get {
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleBulletedList: AsMarticleBulletedList? {
              get {
                if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
                return AsMarticleBulletedList(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleBulletedList: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleBulletedList"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(rows: [Row]) {
                self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var rows: [Row] {
                get {
                  return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts {
                  get {
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct Row: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["BulletedListElement"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                    GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String, level: Int) {
                  self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Row in a list.
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
                  }
                }

                /// Zero-indexed level, for handling nested lists.
                public var level: Int {
                  get {
                    return resultMap["level"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "level")
                  }
                }
              }
            }

            public var asMarticleNumberedList: AsMarticleNumberedList? {
              get {
                if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
                return AsMarticleNumberedList(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleNumberedList: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleNumberedList"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(rows: [Row]) {
                self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var rows: [Row] {
                get {
                  return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts {
                  get {
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct Row: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["NumberedListElement"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                    GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                    GraphQLField("index", type: .nonNull(.scalar(Int.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String, level: Int, index: Int) {
                  self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Row in a list
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
                  }
                }

                /// Zero-indexed level, for handling nexted lists.
                public var level: Int {
                  get {
                    return resultMap["level"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "level")
                  }
                }

                /// Numeric index. If a nested item, the index is zero-indexed from the first child.
                public var index: Int {
                  get {
                    return resultMap["index"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "index")
                  }
                }
              }
            }

            public var asMarticleBlockquote: AsMarticleBlockquote? {
              get {
                if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
                return AsMarticleBlockquote(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleBlockquote: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleBlockquote"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Markdown text content.
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts {
                  get {
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }

          public struct DomainMetadatum: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DomainMetadata"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

              public var domainMetadataParts: DomainMetadataParts {
                get {
                  return DomainMetadataParts(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
                GraphQLField("src", type: .nonNull(.scalar(String.self))),
                GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
            public var src: String {
              get {
                return resultMap["src"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "src")
              }
            }

            /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
            public var imageId: Int {
              get {
                return resultMap["imageId"]! as! Int
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

public final class UnarchiveItemMutation: GraphQLMutation {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    mutation UnarchiveItem($itemID: ID!) {
      updateSavedItemUnArchive(id: $itemID) {
        __typename
        id
      }
    }
    """

  public let operationName: String = "UnarchiveItem"

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
        GraphQLField("updateSavedItemUnArchive", arguments: ["id": GraphQLVariable("itemID")], type: .nonNull(.object(UpdateSavedItemUnArchive.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(updateSavedItemUnArchive: UpdateSavedItemUnArchive) {
      self.init(unsafeResultMap: ["__typename": "Mutation", "updateSavedItemUnArchive": updateSavedItemUnArchive.resultMap])
    }

    /// Unarchives a SavedItem
    public var updateSavedItemUnArchive: UpdateSavedItemUnArchive {
      get {
        return UpdateSavedItemUnArchive(unsafeResultMap: resultMap["updateSavedItemUnArchive"]! as! ResultMap)
      }
      set {
        resultMap.updateValue(newValue.resultMap, forKey: "updateSavedItemUnArchive")
      }
    }

    public struct UpdateSavedItemUnArchive: GraphQLSelectionSet {
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
        requestId
        experimentId
        slates {
          __typename
          ...SlateParts
        }
      }
    }
    """

  public let operationName: String = "GetSlateLineup"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + SlateParts.fragmentDefinition)
    document.append("\n" + ItemParts.fragmentDefinition)
    document.append("\n" + MarticleTextParts.fragmentDefinition)
    document.append("\n" + ImageParts.fragmentDefinition)
    document.append("\n" + MarticleDividerParts.fragmentDefinition)
    document.append("\n" + MarticleTableParts.fragmentDefinition)
    document.append("\n" + MarticleHeadingParts.fragmentDefinition)
    document.append("\n" + MarticleCodeBlockParts.fragmentDefinition)
    document.append("\n" + VideoParts.fragmentDefinition)
    document.append("\n" + MarticleBulletedListParts.fragmentDefinition)
    document.append("\n" + MarticleNumberedListParts.fragmentDefinition)
    document.append("\n" + MarticleBlockquoteParts.fragmentDefinition)
    document.append("\n" + DomainMetadataParts.fragmentDefinition)
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
          GraphQLField("requestId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("experimentId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("slates", type: .nonNull(.list(.nonNull(.object(Slate.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, requestId: GraphQLID, experimentId: GraphQLID, slates: [Slate]) {
        self.init(unsafeResultMap: ["__typename": "SlateLineup", "id": id, "requestId": requestId, "experimentId": experimentId, "slates": slates.map { (value: Slate) -> ResultMap in value.resultMap }])
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

      /// A guid that is unique to every API request that returned slates, such as `getRecommendationSlateLineup` or `getSlate`.
      /// The API will provide a new request id every time apps hit the API.
      public var requestId: GraphQLID {
        get {
          return resultMap["requestId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "requestId")
        }
      }

      /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment.
      /// Production apps typically won't request a specific one, but can for QA or during a/b testing.
      public var experimentId: GraphQLID {
        get {
          return resultMap["experimentId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "experimentId")
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
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(String.self))),
            GraphQLField("requestId", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("experimentId", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("displayName", type: .scalar(String.self)),
            GraphQLField("description", type: .scalar(String.self)),
            GraphQLField("recommendations", type: .nonNull(.list(.nonNull(.object(Recommendation.selections))))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: String, requestId: GraphQLID, experimentId: GraphQLID, displayName: String? = nil, description: String? = nil, recommendations: [Recommendation]) {
          self.init(unsafeResultMap: ["__typename": "Slate", "id": id, "requestId": requestId, "experimentId": experimentId, "displayName": displayName, "description": description, "recommendations": recommendations.map { (value: Recommendation) -> ResultMap in value.resultMap }])
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

        /// A guid that is unique to every API request that returned slates, such as `getSlateLineup` or `getSlate`.
        /// The API will provide a new request id every time apps hit the API.
        public var requestId: GraphQLID {
          get {
            return resultMap["requestId"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "requestId")
          }
        }

        /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment.
        /// Production apps typically won't request a specific one, but can for QA or during a/b testing.
        public var experimentId: GraphQLID {
          get {
            return resultMap["experimentId"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "experimentId")
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

          public var slateParts: SlateParts {
            get {
              return SlateParts(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
          }
        }

        public struct Recommendation: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Recommendation"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("id", type: .scalar(GraphQLID.self)),
              GraphQLField("item", type: .nonNull(.object(Item.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(id: GraphQLID? = nil, item: Item) {
            self.init(unsafeResultMap: ["__typename": "Recommendation", "id": id, "item": item.resultMap])
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
                GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
                GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
                GraphQLField("resolvedUrl", type: .scalar(String.self)),
                GraphQLField("title", type: .scalar(String.self)),
                GraphQLField("language", type: .scalar(String.self)),
                GraphQLField("topImageUrl", type: .scalar(String.self)),
                GraphQLField("timeToRead", type: .scalar(Int.self)),
                GraphQLField("domain", type: .scalar(String.self)),
                GraphQLField("datePublished", type: .scalar(String.self)),
                GraphQLField("isArticle", type: .scalar(Bool.self)),
                GraphQLField("hasImage", type: .scalar(Imageness.self)),
                GraphQLField("hasVideo", type: .scalar(Videoness.self)),
                GraphQLField("authors", type: .list(.object(Author.selections))),
                GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
                GraphQLField("excerpt", type: .scalar(String.self)),
                GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
                GraphQLField("images", type: .list(.object(Image.selections))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
              self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
            public var remoteId: String {
              get {
                return resultMap["remoteID"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "remoteID")
              }
            }

            /// The url as provided by the user when saving. Only http or https schemes allowed.
            public var givenUrl: String {
              get {
                return resultMap["givenUrl"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "givenUrl")
              }
            }

            /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
            public var resolvedUrl: String? {
              get {
                return resultMap["resolvedUrl"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

            /// The date the article was published
            public var datePublished: String? {
              get {
                return resultMap["datePublished"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "datePublished")
              }
            }

            /// true if the item is an article
            public var isArticle: Bool? {
              get {
                return resultMap["isArticle"] as? Bool
              }
              set {
                resultMap.updateValue(newValue, forKey: "isArticle")
              }
            }

            /// 0=no images, 1=contains images, 2=is an image
            public var hasImage: Imageness? {
              get {
                return resultMap["hasImage"] as? Imageness
              }
              set {
                resultMap.updateValue(newValue, forKey: "hasImage")
              }
            }

            /// 0=no videos, 1=contains video, 2=is a video
            public var hasVideo: Videoness? {
              get {
                return resultMap["hasVideo"] as? Videoness
              }
              set {
                resultMap.updateValue(newValue, forKey: "hasVideo")
              }
            }

            /// List of Authors involved with this article
            public var authors: [Author?]? {
              get {
                return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
              }
            }

            /// The Marticle format of the article, used by clients for native article view.
            public var marticle: [Marticle]? {
              get {
                return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
              }
              set {
                resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

            public struct Author: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Author"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                  GraphQLField("name", type: .scalar(String.self)),
                  GraphQLField("url", type: .scalar(String.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Unique id for that Author
              public var id: GraphQLID {
                get {
                  return resultMap["id"]! as! GraphQLID
                }
                set {
                  resultMap.updateValue(newValue, forKey: "id")
                }
              }

              /// Display name
              public var name: String? {
                get {
                  return resultMap["name"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "name")
                }
              }

              /// A url to that Author's site
              public var url: String? {
                get {
                  return resultMap["url"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "url")
                }
              }
            }

            public struct Marticle: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLTypeCase(
                    variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

              public static func makeUnMarseable() -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
              }

              public static func makeMarticleText(content: String) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
              }

              public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
              }

              public static func makeMarticleDivider(content: String) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
              }

              public static func makeMarticleTable(html: String) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
              }

              public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
              }

              public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
              }

              public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
              }

              public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
              }

              public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
              }

              public static func makeMarticleBlockquote(content: String) -> Marticle {
                return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }

              public var asMarticleText: AsMarticleText? {
                get {
                  if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleText(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleText: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleText"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String) {
                  self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Markdown text content. Typically, a paragraph.
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
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

                  public var marticleTextParts: MarticleTextParts {
                    get {
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asImage: AsImage? {
                get {
                  if !AsImage.possibleTypes.contains(__typename) { return nil }
                  return AsImage(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsImage: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Image"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("caption", type: .scalar(String.self)),
                    GraphQLField("credit", type: .scalar(String.self)),
                    GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
                    GraphQLField("src", type: .nonNull(.scalar(String.self))),
                    GraphQLField("height", type: .scalar(Int.self)),
                    GraphQLField("width", type: .scalar(Int.self)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
                  self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// A caption or description of the image
                public var caption: String? {
                  get {
                    return resultMap["caption"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "caption")
                  }
                }

                /// A credit for the image, typically who the image belongs to / created by
                public var credit: String? {
                  get {
                    return resultMap["credit"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "credit")
                  }
                }

                /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
                public var imageId: Int {
                  get {
                    return resultMap["imageID"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "imageID")
                  }
                }

                /// Absolute url to the image
                public var src: String {
                  get {
                    return resultMap["src"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "src")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts {
                    get {
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asMarticleDivider: AsMarticleDivider? {
                get {
                  if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleDivider(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleDivider: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleDivider"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String) {
                  self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Always '---'; provided for convenience if building a markdown string
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts {
                    get {
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asMarticleTable: AsMarticleTable? {
                get {
                  if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleTable(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleTable: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleTable"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("html", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(html: String) {
                  self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Raw HTML representation of the table.
                public var html: String {
                  get {
                    return resultMap["html"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "html")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts {
                    get {
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asMarticleHeading: AsMarticleHeading? {
                get {
                  if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleHeading(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleHeading: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleHeading"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                    GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String, level: Int) {
                  self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Heading text, in markdown.
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
                  }
                }

                /// Heading level. Restricted to values 1-6.
                public var level: Int {
                  get {
                    return resultMap["level"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "level")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts {
                    get {
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asMarticleCodeBlock: AsMarticleCodeBlock? {
                get {
                  if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleCodeBlock(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleCodeBlock: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleCodeBlock"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("text", type: .nonNull(.scalar(String.self))),
                    GraphQLField("language", type: .scalar(Int.self)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(text: String, language: Int? = nil) {
                  self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Content of a pre tag
                public var text: String {
                  get {
                    return resultMap["text"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "text")
                  }
                }

                /// Assuming the codeblock was a programming language, this field is used to identify it.
                public var language: Int? {
                  get {
                    return resultMap["language"] as? Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "language")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts {
                    get {
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asVideo: AsVideo? {
                get {
                  if !AsVideo.possibleTypes.contains(__typename) { return nil }
                  return AsVideo(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsVideo: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["Video"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("height", type: .scalar(Int.self)),
                    GraphQLField("src", type: .nonNull(.scalar(String.self))),
                    GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
                    GraphQLField("vid", type: .scalar(String.self)),
                    GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
                    GraphQLField("width", type: .scalar(Int.self)),
                    GraphQLField("length", type: .scalar(Int.self)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
                  self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// If known, the height of the video in px
                public var height: Int? {
                  get {
                    return resultMap["height"] as? Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "height")
                  }
                }

                /// Absolute url to the video
                public var src: String {
                  get {
                    return resultMap["src"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "src")
                  }
                }

                /// The type of video
                public var type: VideoType {
                  get {
                    return resultMap["type"]! as! VideoType
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "type")
                  }
                }

                /// The video's id within the service defined by type
                public var vid: String? {
                  get {
                    return resultMap["vid"] as? String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "vid")
                  }
                }

                /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
                public var videoId: Int {
                  get {
                    return resultMap["videoID"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "videoID")
                  }
                }

                /// If known, the width of the video in px
                public var width: Int? {
                  get {
                    return resultMap["width"] as? Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "width")
                  }
                }

                /// If known, the length of the video in seconds
                public var length: Int? {
                  get {
                    return resultMap["length"] as? Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "length")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts {
                    get {
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }

              public var asMarticleBulletedList: AsMarticleBulletedList? {
                get {
                  if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleBulletedList(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleBulletedList: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleBulletedList"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(rows: [Row]) {
                  self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var rows: [Row] {
                  get {
                    return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                  }
                  set {
                    resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts {
                    get {
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }

                public struct Row: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["BulletedListElement"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("content", type: .nonNull(.scalar(String.self))),
                      GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(content: String, level: Int) {
                    self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// Row in a list.
                  public var content: String {
                    get {
                      return resultMap["content"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "content")
                    }
                  }

                  /// Zero-indexed level, for handling nested lists.
                  public var level: Int {
                    get {
                      return resultMap["level"]! as! Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "level")
                    }
                  }
                }
              }

              public var asMarticleNumberedList: AsMarticleNumberedList? {
                get {
                  if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleNumberedList(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleNumberedList: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleNumberedList"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(rows: [Row]) {
                  self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                public var rows: [Row] {
                  get {
                    return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                  }
                  set {
                    resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts {
                    get {
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                    get {
                      if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }
                }

                public struct Row: GraphQLSelectionSet {
                  public static let possibleTypes: [String] = ["NumberedListElement"]

                  public static var selections: [GraphQLSelection] {
                    return [
                      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                      GraphQLField("content", type: .nonNull(.scalar(String.self))),
                      GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                      GraphQLField("index", type: .nonNull(.scalar(Int.self))),
                    ]
                  }

                  public private(set) var resultMap: ResultMap

                  public init(unsafeResultMap: ResultMap) {
                    self.resultMap = unsafeResultMap
                  }

                  public init(content: String, level: Int, index: Int) {
                    self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
                  }

                  public var __typename: String {
                    get {
                      return resultMap["__typename"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "__typename")
                    }
                  }

                  /// Row in a list
                  public var content: String {
                    get {
                      return resultMap["content"]! as! String
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "content")
                    }
                  }

                  /// Zero-indexed level, for handling nexted lists.
                  public var level: Int {
                    get {
                      return resultMap["level"]! as! Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "level")
                    }
                  }

                  /// Numeric index. If a nested item, the index is zero-indexed from the first child.
                  public var index: Int {
                    get {
                      return resultMap["index"]! as! Int
                    }
                    set {
                      resultMap.updateValue(newValue, forKey: "index")
                    }
                  }
                }
              }

              public var asMarticleBlockquote: AsMarticleBlockquote? {
                get {
                  if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
                  return AsMarticleBlockquote(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap = newValue.resultMap
                }
              }

              public struct AsMarticleBlockquote: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["MarticleBlockquote"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String) {
                  self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Markdown text content.
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
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

                  public var marticleTextParts: MarticleTextParts? {
                    get {
                      if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTextParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var imageParts: ImageParts? {
                    get {
                      if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return ImageParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleDividerParts: MarticleDividerParts? {
                    get {
                      if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleDividerParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleTableParts: MarticleTableParts? {
                    get {
                      if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleTableParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleHeadingParts: MarticleHeadingParts? {
                    get {
                      if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleHeadingParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                    get {
                      if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var videoParts: VideoParts? {
                    get {
                      if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return VideoParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBulletedListParts: MarticleBulletedListParts? {
                    get {
                      if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleBulletedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleNumberedListParts: MarticleNumberedListParts? {
                    get {
                      if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                      return MarticleNumberedListParts(unsafeResultMap: resultMap)
                    }
                    set {
                      guard let newValue = newValue else { return }
                      resultMap += newValue.resultMap
                    }
                  }

                  public var marticleBlockquoteParts: MarticleBlockquoteParts {
                    get {
                      return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                    }
                    set {
                      resultMap += newValue.resultMap
                    }
                  }
                }
              }
            }

            public struct DomainMetadatum: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["DomainMetadata"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

                public var domainMetadataParts: DomainMetadataParts {
                  get {
                    return DomainMetadataParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
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
                  GraphQLField("src", type: .nonNull(.scalar(String.self))),
                  GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
              public var src: String {
                get {
                  return resultMap["src"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "src")
                }
              }

              /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
              public var imageId: Int {
                get {
                  return resultMap["imageId"]! as! Int
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

public final class GetSlateQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query GetSlate($slateID: String!, $recommendationCount: Int!) {
      getSlate(slateId: $slateID, recommendationCount: $recommendationCount) {
        __typename
        ...SlateParts
      }
    }
    """

  public let operationName: String = "GetSlate"

  public var queryDocument: String {
    var document: String = operationDefinition
    document.append("\n" + SlateParts.fragmentDefinition)
    document.append("\n" + ItemParts.fragmentDefinition)
    document.append("\n" + MarticleTextParts.fragmentDefinition)
    document.append("\n" + ImageParts.fragmentDefinition)
    document.append("\n" + MarticleDividerParts.fragmentDefinition)
    document.append("\n" + MarticleTableParts.fragmentDefinition)
    document.append("\n" + MarticleHeadingParts.fragmentDefinition)
    document.append("\n" + MarticleCodeBlockParts.fragmentDefinition)
    document.append("\n" + VideoParts.fragmentDefinition)
    document.append("\n" + MarticleBulletedListParts.fragmentDefinition)
    document.append("\n" + MarticleNumberedListParts.fragmentDefinition)
    document.append("\n" + MarticleBlockquoteParts.fragmentDefinition)
    document.append("\n" + DomainMetadataParts.fragmentDefinition)
    return document
  }

  public var slateID: String
  public var recommendationCount: Int

  public init(slateID: String, recommendationCount: Int) {
    self.slateID = slateID
    self.recommendationCount = recommendationCount
  }

  public var variables: GraphQLMap? {
    return ["slateID": slateID, "recommendationCount": recommendationCount]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("getSlate", arguments: ["slateId": GraphQLVariable("slateID"), "recommendationCount": GraphQLVariable("recommendationCount")], type: .object(GetSlate.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(getSlate: GetSlate? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "getSlate": getSlate.flatMap { (value: GetSlate) -> ResultMap in value.resultMap }])
    }

    /// Request a specific `Slate` by id
    public var getSlate: GetSlate? {
      get {
        return (resultMap["getSlate"] as? ResultMap).flatMap { GetSlate(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "getSlate")
      }
    }

    public struct GetSlate: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Slate"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(String.self))),
          GraphQLField("requestId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("experimentId", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("displayName", type: .scalar(String.self)),
          GraphQLField("description", type: .scalar(String.self)),
          GraphQLField("recommendations", type: .nonNull(.list(.nonNull(.object(Recommendation.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: String, requestId: GraphQLID, experimentId: GraphQLID, displayName: String? = nil, description: String? = nil, recommendations: [Recommendation]) {
        self.init(unsafeResultMap: ["__typename": "Slate", "id": id, "requestId": requestId, "experimentId": experimentId, "displayName": displayName, "description": description, "recommendations": recommendations.map { (value: Recommendation) -> ResultMap in value.resultMap }])
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

      /// A guid that is unique to every API request that returned slates, such as `getSlateLineup` or `getSlate`.
      /// The API will provide a new request id every time apps hit the API.
      public var requestId: GraphQLID {
        get {
          return resultMap["requestId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "requestId")
        }
      }

      /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment.
      /// Production apps typically won't request a specific one, but can for QA or during a/b testing.
      public var experimentId: GraphQLID {
        get {
          return resultMap["experimentId"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "experimentId")
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

        public var slateParts: SlateParts {
          get {
            return SlateParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Recommendation: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Recommendation"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .scalar(GraphQLID.self)),
            GraphQLField("item", type: .nonNull(.object(Item.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID? = nil, item: Item) {
          self.init(unsafeResultMap: ["__typename": "Recommendation", "id": id, "item": item.resultMap])
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
              GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
              GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
              GraphQLField("resolvedUrl", type: .scalar(String.self)),
              GraphQLField("title", type: .scalar(String.self)),
              GraphQLField("language", type: .scalar(String.self)),
              GraphQLField("topImageUrl", type: .scalar(String.self)),
              GraphQLField("timeToRead", type: .scalar(Int.self)),
              GraphQLField("domain", type: .scalar(String.self)),
              GraphQLField("datePublished", type: .scalar(String.self)),
              GraphQLField("isArticle", type: .scalar(Bool.self)),
              GraphQLField("hasImage", type: .scalar(Imageness.self)),
              GraphQLField("hasVideo", type: .scalar(Videoness.self)),
              GraphQLField("authors", type: .list(.object(Author.selections))),
              GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
              GraphQLField("excerpt", type: .scalar(String.self)),
              GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
              GraphQLField("images", type: .list(.object(Image.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
            self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
          public var remoteId: String {
            get {
              return resultMap["remoteID"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "remoteID")
            }
          }

          /// The url as provided by the user when saving. Only http or https schemes allowed.
          public var givenUrl: String {
            get {
              return resultMap["givenUrl"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "givenUrl")
            }
          }

          /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
          public var resolvedUrl: String? {
            get {
              return resultMap["resolvedUrl"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

          /// The date the article was published
          public var datePublished: String? {
            get {
              return resultMap["datePublished"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "datePublished")
            }
          }

          /// true if the item is an article
          public var isArticle: Bool? {
            get {
              return resultMap["isArticle"] as? Bool
            }
            set {
              resultMap.updateValue(newValue, forKey: "isArticle")
            }
          }

          /// 0=no images, 1=contains images, 2=is an image
          public var hasImage: Imageness? {
            get {
              return resultMap["hasImage"] as? Imageness
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasImage")
            }
          }

          /// 0=no videos, 1=contains video, 2=is a video
          public var hasVideo: Videoness? {
            get {
              return resultMap["hasVideo"] as? Videoness
            }
            set {
              resultMap.updateValue(newValue, forKey: "hasVideo")
            }
          }

          /// List of Authors involved with this article
          public var authors: [Author?]? {
            get {
              return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
            }
          }

          /// The Marticle format of the article, used by clients for native article view.
          public var marticle: [Marticle]? {
            get {
              return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
            }
            set {
              resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

          public struct Author: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["Author"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
                GraphQLField("name", type: .scalar(String.self)),
                GraphQLField("url", type: .scalar(String.self)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
              self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Unique id for that Author
            public var id: GraphQLID {
              get {
                return resultMap["id"]! as! GraphQLID
              }
              set {
                resultMap.updateValue(newValue, forKey: "id")
              }
            }

            /// Display name
            public var name: String? {
              get {
                return resultMap["name"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "name")
              }
            }

            /// A url to that Author's site
            public var url: String? {
              get {
                return resultMap["url"] as? String
              }
              set {
                resultMap.updateValue(newValue, forKey: "url")
              }
            }
          }

          public struct Marticle: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLTypeCase(
                  variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

            public static func makeUnMarseable() -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
            }

            public static func makeMarticleText(content: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
            }

            public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
            }

            public static func makeMarticleDivider(content: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
            }

            public static func makeMarticleTable(html: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
            }

            public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
            }

            public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
            }

            public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
            }

            public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
            }

            public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
            }

            public static func makeMarticleBlockquote(content: String) -> Marticle {
              return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

              public var marticleTextParts: MarticleTextParts? {
                get {
                  if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleTextParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var imageParts: ImageParts? {
                get {
                  if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return ImageParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleDividerParts: MarticleDividerParts? {
                get {
                  if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleDividerParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleTableParts: MarticleTableParts? {
                get {
                  if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleTableParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleHeadingParts: MarticleHeadingParts? {
                get {
                  if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleHeadingParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                get {
                  if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var videoParts: VideoParts? {
                get {
                  if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return VideoParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleBulletedListParts: MarticleBulletedListParts? {
                get {
                  if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleBulletedListParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleNumberedListParts: MarticleNumberedListParts? {
                get {
                  if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleNumberedListParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }

              public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                get {
                  if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                  return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                }
                set {
                  guard let newValue = newValue else { return }
                  resultMap += newValue.resultMap
                }
              }
            }

            public var asMarticleText: AsMarticleText? {
              get {
                if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
                return AsMarticleText(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleText: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleText"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Markdown text content. Typically, a paragraph.
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
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

                public var marticleTextParts: MarticleTextParts {
                  get {
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asImage: AsImage? {
              get {
                if !AsImage.possibleTypes.contains(__typename) { return nil }
                return AsImage(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsImage: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Image"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("caption", type: .scalar(String.self)),
                  GraphQLField("credit", type: .scalar(String.self)),
                  GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
                  GraphQLField("src", type: .nonNull(.scalar(String.self))),
                  GraphQLField("height", type: .scalar(Int.self)),
                  GraphQLField("width", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// A caption or description of the image
              public var caption: String? {
                get {
                  return resultMap["caption"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "caption")
                }
              }

              /// A credit for the image, typically who the image belongs to / created by
              public var credit: String? {
                get {
                  return resultMap["credit"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "credit")
                }
              }

              /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
              public var imageId: Int {
                get {
                  return resultMap["imageID"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "imageID")
                }
              }

              /// Absolute url to the image
              public var src: String {
                get {
                  return resultMap["src"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "src")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts {
                  get {
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleDivider: AsMarticleDivider? {
              get {
                if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
                return AsMarticleDivider(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleDivider: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleDivider"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Always '---'; provided for convenience if building a markdown string
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts {
                  get {
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleTable: AsMarticleTable? {
              get {
                if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
                return AsMarticleTable(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleTable: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleTable"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("html", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(html: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Raw HTML representation of the table.
              public var html: String {
                get {
                  return resultMap["html"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "html")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts {
                  get {
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleHeading: AsMarticleHeading? {
              get {
                if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
                return AsMarticleHeading(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleHeading: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleHeading"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                  GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String, level: Int) {
                self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Heading text, in markdown.
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
                }
              }

              /// Heading level. Restricted to values 1-6.
              public var level: Int {
                get {
                  return resultMap["level"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "level")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts {
                  get {
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleCodeBlock: AsMarticleCodeBlock? {
              get {
                if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
                return AsMarticleCodeBlock(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleCodeBlock: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleCodeBlock"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("text", type: .nonNull(.scalar(String.self))),
                  GraphQLField("language", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(text: String, language: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Content of a pre tag
              public var text: String {
                get {
                  return resultMap["text"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "text")
                }
              }

              /// Assuming the codeblock was a programming language, this field is used to identify it.
              public var language: Int? {
                get {
                  return resultMap["language"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "language")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts {
                  get {
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asVideo: AsVideo? {
              get {
                if !AsVideo.possibleTypes.contains(__typename) { return nil }
                return AsVideo(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsVideo: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Video"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("height", type: .scalar(Int.self)),
                  GraphQLField("src", type: .nonNull(.scalar(String.self))),
                  GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
                  GraphQLField("vid", type: .scalar(String.self)),
                  GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
                  GraphQLField("width", type: .scalar(Int.self)),
                  GraphQLField("length", type: .scalar(Int.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
                self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// If known, the height of the video in px
              public var height: Int? {
                get {
                  return resultMap["height"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "height")
                }
              }

              /// Absolute url to the video
              public var src: String {
                get {
                  return resultMap["src"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "src")
                }
              }

              /// The type of video
              public var type: VideoType {
                get {
                  return resultMap["type"]! as! VideoType
                }
                set {
                  resultMap.updateValue(newValue, forKey: "type")
                }
              }

              /// The video's id within the service defined by type
              public var vid: String? {
                get {
                  return resultMap["vid"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "vid")
                }
              }

              /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
              public var videoId: Int {
                get {
                  return resultMap["videoID"]! as! Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "videoID")
                }
              }

              /// If known, the width of the video in px
              public var width: Int? {
                get {
                  return resultMap["width"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "width")
                }
              }

              /// If known, the length of the video in seconds
              public var length: Int? {
                get {
                  return resultMap["length"] as? Int
                }
                set {
                  resultMap.updateValue(newValue, forKey: "length")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts {
                  get {
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }
            }

            public var asMarticleBulletedList: AsMarticleBulletedList? {
              get {
                if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
                return AsMarticleBulletedList(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleBulletedList: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleBulletedList"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(rows: [Row]) {
                self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var rows: [Row] {
                get {
                  return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts {
                  get {
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct Row: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["BulletedListElement"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                    GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String, level: Int) {
                  self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Row in a list.
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
                  }
                }

                /// Zero-indexed level, for handling nested lists.
                public var level: Int {
                  get {
                    return resultMap["level"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "level")
                  }
                }
              }
            }

            public var asMarticleNumberedList: AsMarticleNumberedList? {
              get {
                if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
                return AsMarticleNumberedList(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleNumberedList: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleNumberedList"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(rows: [Row]) {
                self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var rows: [Row] {
                get {
                  return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
                }
                set {
                  resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts {
                  get {
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts? {
                  get {
                    if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }
              }

              public struct Row: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["NumberedListElement"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("content", type: .nonNull(.scalar(String.self))),
                    GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                    GraphQLField("index", type: .nonNull(.scalar(Int.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(content: String, level: Int, index: Int) {
                  self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
                  }
                }

                /// Row in a list
                public var content: String {
                  get {
                    return resultMap["content"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "content")
                  }
                }

                /// Zero-indexed level, for handling nexted lists.
                public var level: Int {
                  get {
                    return resultMap["level"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "level")
                  }
                }

                /// Numeric index. If a nested item, the index is zero-indexed from the first child.
                public var index: Int {
                  get {
                    return resultMap["index"]! as! Int
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "index")
                  }
                }
              }
            }

            public var asMarticleBlockquote: AsMarticleBlockquote? {
              get {
                if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
                return AsMarticleBlockquote(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap = newValue.resultMap
              }
            }

            public struct AsMarticleBlockquote: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["MarticleBlockquote"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("content", type: .nonNull(.scalar(String.self))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(content: String) {
                self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              /// Markdown text content.
              public var content: String {
                get {
                  return resultMap["content"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "content")
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

                public var marticleTextParts: MarticleTextParts? {
                  get {
                    if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTextParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var imageParts: ImageParts? {
                  get {
                    if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return ImageParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleDividerParts: MarticleDividerParts? {
                  get {
                    if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleDividerParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleTableParts: MarticleTableParts? {
                  get {
                    if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleTableParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleHeadingParts: MarticleHeadingParts? {
                  get {
                    if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleHeadingParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleCodeBlockParts: MarticleCodeBlockParts? {
                  get {
                    if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleCodeBlockParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var videoParts: VideoParts? {
                  get {
                    if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return VideoParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBulletedListParts: MarticleBulletedListParts? {
                  get {
                    if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleBulletedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleNumberedListParts: MarticleNumberedListParts? {
                  get {
                    if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                    return MarticleNumberedListParts(unsafeResultMap: resultMap)
                  }
                  set {
                    guard let newValue = newValue else { return }
                    resultMap += newValue.resultMap
                  }
                }

                public var marticleBlockquoteParts: MarticleBlockquoteParts {
                  get {
                    return MarticleBlockquoteParts(unsafeResultMap: resultMap)
                  }
                  set {
                    resultMap += newValue.resultMap
                  }
                }
              }
            }
          }

          public struct DomainMetadatum: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["DomainMetadata"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

              public var domainMetadataParts: DomainMetadataParts {
                get {
                  return DomainMetadataParts(unsafeResultMap: resultMap)
                }
                set {
                  resultMap += newValue.resultMap
                }
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
                GraphQLField("src", type: .nonNull(.scalar(String.self))),
                GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
            public var src: String {
              get {
                return resultMap["src"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "src")
              }
            }

            /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
            public var imageId: Int {
              get {
                return resultMap["imageId"]! as! Int
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

public struct SavedItemParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment SavedItemParts on SavedItem {
      __typename
      url
      remoteID: id
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
      GraphQLField("url", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", alias: "remoteID", type: .nonNull(.scalar(GraphQLID.self))),
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

  public init(url: String, remoteId: GraphQLID, isArchived: Bool, isFavorite: Bool, _deletedAt: Int? = nil, _createdAt: Int, item: Item) {
    self.init(unsafeResultMap: ["__typename": "SavedItem", "url": url, "remoteID": remoteId, "isArchived": isArchived, "isFavorite": isFavorite, "_deletedAt": _deletedAt, "_createdAt": _createdAt, "item": item.resultMap])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
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

  /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
  public var remoteId: GraphQLID {
    get {
      return resultMap["remoteID"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "remoteID")
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

    public static func makeItem(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [AsItem.Author?]? = nil, marticle: [AsItem.Marticle]? = nil, excerpt: String? = nil, domainMetadata: AsItem.DomainMetadatum? = nil, images: [AsItem.Image?]? = nil) -> Item {
      return Item(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [AsItem.Author?]) -> [ResultMap?] in value.map { (value: AsItem.Author?) -> ResultMap? in value.flatMap { (value: AsItem.Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [AsItem.Marticle]) -> [ResultMap] in value.map { (value: AsItem.Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: AsItem.DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [AsItem.Image?]) -> [ResultMap?] in value.map { (value: AsItem.Image?) -> ResultMap? in value.flatMap { (value: AsItem.Image) -> ResultMap in value.resultMap } } }])
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
          GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
          GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
          GraphQLField("resolvedUrl", type: .scalar(String.self)),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("language", type: .scalar(String.self)),
          GraphQLField("topImageUrl", type: .scalar(String.self)),
          GraphQLField("timeToRead", type: .scalar(Int.self)),
          GraphQLField("domain", type: .scalar(String.self)),
          GraphQLField("datePublished", type: .scalar(String.self)),
          GraphQLField("isArticle", type: .scalar(Bool.self)),
          GraphQLField("hasImage", type: .scalar(Imageness.self)),
          GraphQLField("hasVideo", type: .scalar(Videoness.self)),
          GraphQLField("authors", type: .list(.object(Author.selections))),
          GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
          GraphQLField("excerpt", type: .scalar(String.self)),
          GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
          GraphQLField("images", type: .list(.object(Image.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
      public var remoteId: String {
        get {
          return resultMap["remoteID"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "remoteID")
        }
      }

      /// The url as provided by the user when saving. Only http or https schemes allowed.
      public var givenUrl: String {
        get {
          return resultMap["givenUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "givenUrl")
        }
      }

      /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
      public var resolvedUrl: String? {
        get {
          return resultMap["resolvedUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

      /// The date the article was published
      public var datePublished: String? {
        get {
          return resultMap["datePublished"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "datePublished")
        }
      }

      /// true if the item is an article
      public var isArticle: Bool? {
        get {
          return resultMap["isArticle"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "isArticle")
        }
      }

      /// 0=no images, 1=contains images, 2=is an image
      public var hasImage: Imageness? {
        get {
          return resultMap["hasImage"] as? Imageness
        }
        set {
          resultMap.updateValue(newValue, forKey: "hasImage")
        }
      }

      /// 0=no videos, 1=contains video, 2=is a video
      public var hasVideo: Videoness? {
        get {
          return resultMap["hasVideo"] as? Videoness
        }
        set {
          resultMap.updateValue(newValue, forKey: "hasVideo")
        }
      }

      /// List of Authors involved with this article
      public var authors: [Author?]? {
        get {
          return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
        }
      }

      /// The Marticle format of the article, used by clients for native article view.
      public var marticle: [Marticle]? {
        get {
          return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

      public struct Author: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Author"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("url", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Unique id for that Author
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// Display name
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// A url to that Author's site
        public var url: String? {
          get {
            return resultMap["url"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }

      public struct Marticle: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

        public static func makeUnMarseable() -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
        }

        public static func makeMarticleText(content: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
        }

        public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
        }

        public static func makeMarticleDivider(content: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
        }

        public static func makeMarticleTable(html: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
        }

        public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
        }

        public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
        }

        public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
        }

        public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
        }

        public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
        }

        public static func makeMarticleBlockquote(content: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

          public var marticleTextParts: MarticleTextParts? {
            get {
              if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleTextParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var imageParts: ImageParts? {
            get {
              if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return ImageParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleDividerParts: MarticleDividerParts? {
            get {
              if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleDividerParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleTableParts: MarticleTableParts? {
            get {
              if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleTableParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleHeadingParts: MarticleHeadingParts? {
            get {
              if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleHeadingParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleCodeBlockParts: MarticleCodeBlockParts? {
            get {
              if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleCodeBlockParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var videoParts: VideoParts? {
            get {
              if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return VideoParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleBulletedListParts: MarticleBulletedListParts? {
            get {
              if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleBulletedListParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleNumberedListParts: MarticleNumberedListParts? {
            get {
              if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleNumberedListParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleBlockquoteParts: MarticleBlockquoteParts? {
            get {
              if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleBlockquoteParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }
        }

        public var asMarticleText: AsMarticleText? {
          get {
            if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
            return AsMarticleText(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleText: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleText"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Markdown text content. Typically, a paragraph.
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
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

            public var marticleTextParts: MarticleTextParts {
              get {
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asImage: AsImage? {
          get {
            if !AsImage.possibleTypes.contains(__typename) { return nil }
            return AsImage(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsImage: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Image"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("caption", type: .scalar(String.self)),
              GraphQLField("credit", type: .scalar(String.self)),
              GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
              GraphQLField("src", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", type: .scalar(Int.self)),
              GraphQLField("width", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A caption or description of the image
          public var caption: String? {
            get {
              return resultMap["caption"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "caption")
            }
          }

          /// A credit for the image, typically who the image belongs to / created by
          public var credit: String? {
            get {
              return resultMap["credit"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "credit")
            }
          }

          /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
          public var imageId: Int {
            get {
              return resultMap["imageID"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "imageID")
            }
          }

          /// Absolute url to the image
          public var src: String {
            get {
              return resultMap["src"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "src")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts {
              get {
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleDivider: AsMarticleDivider? {
          get {
            if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
            return AsMarticleDivider(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleDivider: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleDivider"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Always '---'; provided for convenience if building a markdown string
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts {
              get {
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleTable: AsMarticleTable? {
          get {
            if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
            return AsMarticleTable(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleTable: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleTable"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("html", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(html: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Raw HTML representation of the table.
          public var html: String {
            get {
              return resultMap["html"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "html")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts {
              get {
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleHeading: AsMarticleHeading? {
          get {
            if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
            return AsMarticleHeading(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleHeading: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleHeading"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
              GraphQLField("level", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String, level: Int) {
            self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Heading text, in markdown.
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
            }
          }

          /// Heading level. Restricted to values 1-6.
          public var level: Int {
            get {
              return resultMap["level"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "level")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts {
              get {
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleCodeBlock: AsMarticleCodeBlock? {
          get {
            if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
            return AsMarticleCodeBlock(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleCodeBlock: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleCodeBlock"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .nonNull(.scalar(String.self))),
              GraphQLField("language", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String, language: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Content of a pre tag
          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          /// Assuming the codeblock was a programming language, this field is used to identify it.
          public var language: Int? {
            get {
              return resultMap["language"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "language")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts {
              get {
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asVideo: AsVideo? {
          get {
            if !AsVideo.possibleTypes.contains(__typename) { return nil }
            return AsVideo(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsVideo: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Video"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", type: .scalar(Int.self)),
              GraphQLField("src", type: .nonNull(.scalar(String.self))),
              GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
              GraphQLField("vid", type: .scalar(String.self)),
              GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
              GraphQLField("width", type: .scalar(Int.self)),
              GraphQLField("length", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// If known, the height of the video in px
          public var height: Int? {
            get {
              return resultMap["height"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "height")
            }
          }

          /// Absolute url to the video
          public var src: String {
            get {
              return resultMap["src"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "src")
            }
          }

          /// The type of video
          public var type: VideoType {
            get {
              return resultMap["type"]! as! VideoType
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          /// The video's id within the service defined by type
          public var vid: String? {
            get {
              return resultMap["vid"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "vid")
            }
          }

          /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
          public var videoId: Int {
            get {
              return resultMap["videoID"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "videoID")
            }
          }

          /// If known, the width of the video in px
          public var width: Int? {
            get {
              return resultMap["width"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "width")
            }
          }

          /// If known, the length of the video in seconds
          public var length: Int? {
            get {
              return resultMap["length"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "length")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts {
              get {
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleBulletedList: AsMarticleBulletedList? {
          get {
            if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
            return AsMarticleBulletedList(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleBulletedList: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleBulletedList"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(rows: [Row]) {
            self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var rows: [Row] {
            get {
              return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts {
              get {
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Row: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["BulletedListElement"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("content", type: .nonNull(.scalar(String.self))),
                GraphQLField("level", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(content: String, level: Int) {
              self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Row in a list.
            public var content: String {
              get {
                return resultMap["content"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "content")
              }
            }

            /// Zero-indexed level, for handling nested lists.
            public var level: Int {
              get {
                return resultMap["level"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "level")
              }
            }
          }
        }

        public var asMarticleNumberedList: AsMarticleNumberedList? {
          get {
            if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
            return AsMarticleNumberedList(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleNumberedList: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleNumberedList"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(rows: [Row]) {
            self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var rows: [Row] {
            get {
              return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts {
              get {
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Row: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["NumberedListElement"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("content", type: .nonNull(.scalar(String.self))),
                GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                GraphQLField("index", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(content: String, level: Int, index: Int) {
              self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Row in a list
            public var content: String {
              get {
                return resultMap["content"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "content")
              }
            }

            /// Zero-indexed level, for handling nexted lists.
            public var level: Int {
              get {
                return resultMap["level"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "level")
              }
            }

            /// Numeric index. If a nested item, the index is zero-indexed from the first child.
            public var index: Int {
              get {
                return resultMap["index"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "index")
              }
            }
          }
        }

        public var asMarticleBlockquote: AsMarticleBlockquote? {
          get {
            if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
            return AsMarticleBlockquote(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleBlockquote: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleBlockquote"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Markdown text content.
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts {
              get {
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }

      public struct DomainMetadatum: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["DomainMetadata"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

          public var domainMetadataParts: DomainMetadataParts {
            get {
              return DomainMetadataParts(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
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
            GraphQLField("src", type: .nonNull(.scalar(String.self))),
            GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
        public var src: String {
          get {
            return resultMap["src"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "src")
          }
        }

        /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
        public var imageId: Int {
          get {
            return resultMap["imageId"]! as! Int
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
      remoteID: itemId
      givenUrl
      resolvedUrl
      title
      language
      topImageUrl
      timeToRead
      domain
      datePublished
      isArticle
      hasImage
      hasVideo
      authors {
        __typename
        id
        name
        url
      }
      marticle {
        __typename
        ...MarticleTextParts
        ...ImageParts
        ...MarticleDividerParts
        ...MarticleTableParts
        ...MarticleHeadingParts
        ...MarticleCodeBlockParts
        ...VideoParts
        ...MarticleBulletedListParts
        ...MarticleNumberedListParts
        ...MarticleBlockquoteParts
      }
      excerpt
      domainMetadata {
        __typename
        ...DomainMetadataParts
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
      GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
      GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
      GraphQLField("resolvedUrl", type: .scalar(String.self)),
      GraphQLField("title", type: .scalar(String.self)),
      GraphQLField("language", type: .scalar(String.self)),
      GraphQLField("topImageUrl", type: .scalar(String.self)),
      GraphQLField("timeToRead", type: .scalar(Int.self)),
      GraphQLField("domain", type: .scalar(String.self)),
      GraphQLField("datePublished", type: .scalar(String.self)),
      GraphQLField("isArticle", type: .scalar(Bool.self)),
      GraphQLField("hasImage", type: .scalar(Imageness.self)),
      GraphQLField("hasVideo", type: .scalar(Videoness.self)),
      GraphQLField("authors", type: .list(.object(Author.selections))),
      GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
      GraphQLField("excerpt", type: .scalar(String.self)),
      GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
      GraphQLField("images", type: .list(.object(Image.selections))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
    self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
  public var remoteId: String {
    get {
      return resultMap["remoteID"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "remoteID")
    }
  }

  /// The url as provided by the user when saving. Only http or https schemes allowed.
  public var givenUrl: String {
    get {
      return resultMap["givenUrl"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "givenUrl")
    }
  }

  /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
  public var resolvedUrl: String? {
    get {
      return resultMap["resolvedUrl"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

  /// The date the article was published
  public var datePublished: String? {
    get {
      return resultMap["datePublished"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "datePublished")
    }
  }

  /// true if the item is an article
  public var isArticle: Bool? {
    get {
      return resultMap["isArticle"] as? Bool
    }
    set {
      resultMap.updateValue(newValue, forKey: "isArticle")
    }
  }

  /// 0=no images, 1=contains images, 2=is an image
  public var hasImage: Imageness? {
    get {
      return resultMap["hasImage"] as? Imageness
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasImage")
    }
  }

  /// 0=no videos, 1=contains video, 2=is a video
  public var hasVideo: Videoness? {
    get {
      return resultMap["hasVideo"] as? Videoness
    }
    set {
      resultMap.updateValue(newValue, forKey: "hasVideo")
    }
  }

  /// List of Authors involved with this article
  public var authors: [Author?]? {
    get {
      return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
    }
  }

  /// The Marticle format of the article, used by clients for native article view.
  public var marticle: [Marticle]? {
    get {
      return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
    }
    set {
      resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

  public struct Author: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Author"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
        GraphQLField("name", type: .scalar(String.self)),
        GraphQLField("url", type: .scalar(String.self)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
      self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Unique id for that Author
    public var id: GraphQLID {
      get {
        return resultMap["id"]! as! GraphQLID
      }
      set {
        resultMap.updateValue(newValue, forKey: "id")
      }
    }

    /// Display name
    public var name: String? {
      get {
        return resultMap["name"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "name")
      }
    }

    /// A url to that Author's site
    public var url: String? {
      get {
        return resultMap["url"] as? String
      }
      set {
        resultMap.updateValue(newValue, forKey: "url")
      }
    }
  }

  public struct Marticle: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLTypeCase(
          variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

    public static func makeUnMarseable() -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
    }

    public static func makeMarticleText(content: String) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
    }

    public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
    }

    public static func makeMarticleDivider(content: String) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
    }

    public static func makeMarticleTable(html: String) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
    }

    public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
    }

    public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
    }

    public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
    }

    public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
    }

    public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
    }

    public static func makeMarticleBlockquote(content: String) -> Marticle {
      return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

      public var marticleTextParts: MarticleTextParts? {
        get {
          if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleTextParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var imageParts: ImageParts? {
        get {
          if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return ImageParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleDividerParts: MarticleDividerParts? {
        get {
          if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleDividerParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleTableParts: MarticleTableParts? {
        get {
          if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleTableParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleHeadingParts: MarticleHeadingParts? {
        get {
          if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleHeadingParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleCodeBlockParts: MarticleCodeBlockParts? {
        get {
          if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleCodeBlockParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var videoParts: VideoParts? {
        get {
          if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return VideoParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleBulletedListParts: MarticleBulletedListParts? {
        get {
          if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleBulletedListParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleNumberedListParts: MarticleNumberedListParts? {
        get {
          if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleNumberedListParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }

      public var marticleBlockquoteParts: MarticleBlockquoteParts? {
        get {
          if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
          return MarticleBlockquoteParts(unsafeResultMap: resultMap)
        }
        set {
          guard let newValue = newValue else { return }
          resultMap += newValue.resultMap
        }
      }
    }

    public var asMarticleText: AsMarticleText? {
      get {
        if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
        return AsMarticleText(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleText: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleText"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("content", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(content: String) {
        self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Markdown text content. Typically, a paragraph.
      public var content: String {
        get {
          return resultMap["content"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "content")
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

        public var marticleTextParts: MarticleTextParts {
          get {
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asImage: AsImage? {
      get {
        if !AsImage.possibleTypes.contains(__typename) { return nil }
        return AsImage(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsImage: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Image"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("caption", type: .scalar(String.self)),
          GraphQLField("credit", type: .scalar(String.self)),
          GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
          GraphQLField("src", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .scalar(Int.self)),
          GraphQLField("width", type: .scalar(Int.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A caption or description of the image
      public var caption: String? {
        get {
          return resultMap["caption"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "caption")
        }
      }

      /// A credit for the image, typically who the image belongs to / created by
      public var credit: String? {
        get {
          return resultMap["credit"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "credit")
        }
      }

      /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
      public var imageId: Int {
        get {
          return resultMap["imageID"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "imageID")
        }
      }

      /// Absolute url to the image
      public var src: String {
        get {
          return resultMap["src"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "src")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts {
          get {
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMarticleDivider: AsMarticleDivider? {
      get {
        if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
        return AsMarticleDivider(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleDivider: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleDivider"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("content", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(content: String) {
        self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Always '---'; provided for convenience if building a markdown string
      public var content: String {
        get {
          return resultMap["content"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "content")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts {
          get {
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMarticleTable: AsMarticleTable? {
      get {
        if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
        return AsMarticleTable(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleTable: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleTable"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("html", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(html: String) {
        self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Raw HTML representation of the table.
      public var html: String {
        get {
          return resultMap["html"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "html")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts {
          get {
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMarticleHeading: AsMarticleHeading? {
      get {
        if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
        return AsMarticleHeading(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleHeading: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleHeading"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("content", type: .nonNull(.scalar(String.self))),
          GraphQLField("level", type: .nonNull(.scalar(Int.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(content: String, level: Int) {
        self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Heading text, in markdown.
      public var content: String {
        get {
          return resultMap["content"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "content")
        }
      }

      /// Heading level. Restricted to values 1-6.
      public var level: Int {
        get {
          return resultMap["level"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "level")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts {
          get {
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMarticleCodeBlock: AsMarticleCodeBlock? {
      get {
        if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
        return AsMarticleCodeBlock(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleCodeBlock: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleCodeBlock"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("text", type: .nonNull(.scalar(String.self))),
          GraphQLField("language", type: .scalar(Int.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(text: String, language: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Content of a pre tag
      public var text: String {
        get {
          return resultMap["text"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "text")
        }
      }

      /// Assuming the codeblock was a programming language, this field is used to identify it.
      public var language: Int? {
        get {
          return resultMap["language"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "language")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts {
          get {
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asVideo: AsVideo? {
      get {
        if !AsVideo.possibleTypes.contains(__typename) { return nil }
        return AsVideo(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsVideo: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Video"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("height", type: .scalar(Int.self)),
          GraphQLField("src", type: .nonNull(.scalar(String.self))),
          GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
          GraphQLField("vid", type: .scalar(String.self)),
          GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
          GraphQLField("width", type: .scalar(Int.self)),
          GraphQLField("length", type: .scalar(Int.self)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
        self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// If known, the height of the video in px
      public var height: Int? {
        get {
          return resultMap["height"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "height")
        }
      }

      /// Absolute url to the video
      public var src: String {
        get {
          return resultMap["src"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "src")
        }
      }

      /// The type of video
      public var type: VideoType {
        get {
          return resultMap["type"]! as! VideoType
        }
        set {
          resultMap.updateValue(newValue, forKey: "type")
        }
      }

      /// The video's id within the service defined by type
      public var vid: String? {
        get {
          return resultMap["vid"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "vid")
        }
      }

      /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
      public var videoId: Int {
        get {
          return resultMap["videoID"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "videoID")
        }
      }

      /// If known, the width of the video in px
      public var width: Int? {
        get {
          return resultMap["width"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "width")
        }
      }

      /// If known, the length of the video in seconds
      public var length: Int? {
        get {
          return resultMap["length"] as? Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "length")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts {
          get {
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }
    }

    public var asMarticleBulletedList: AsMarticleBulletedList? {
      get {
        if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
        return AsMarticleBulletedList(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleBulletedList: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleBulletedList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(rows: [Row]) {
        self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var rows: [Row] {
        get {
          return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts {
          get {
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Row: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["BulletedListElement"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("content", type: .nonNull(.scalar(String.self))),
            GraphQLField("level", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(content: String, level: Int) {
          self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Row in a list.
        public var content: String {
          get {
            return resultMap["content"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "content")
          }
        }

        /// Zero-indexed level, for handling nested lists.
        public var level: Int {
          get {
            return resultMap["level"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "level")
          }
        }
      }
    }

    public var asMarticleNumberedList: AsMarticleNumberedList? {
      get {
        if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
        return AsMarticleNumberedList(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleNumberedList: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleNumberedList"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(rows: [Row]) {
        self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var rows: [Row] {
        get {
          return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
        }
        set {
          resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts {
          get {
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts? {
          get {
            if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }
      }

      public struct Row: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["NumberedListElement"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("content", type: .nonNull(.scalar(String.self))),
            GraphQLField("level", type: .nonNull(.scalar(Int.self))),
            GraphQLField("index", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(content: String, level: Int, index: Int) {
          self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Row in a list
        public var content: String {
          get {
            return resultMap["content"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "content")
          }
        }

        /// Zero-indexed level, for handling nexted lists.
        public var level: Int {
          get {
            return resultMap["level"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "level")
          }
        }

        /// Numeric index. If a nested item, the index is zero-indexed from the first child.
        public var index: Int {
          get {
            return resultMap["index"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "index")
          }
        }
      }
    }

    public var asMarticleBlockquote: AsMarticleBlockquote? {
      get {
        if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
        return AsMarticleBlockquote(unsafeResultMap: resultMap)
      }
      set {
        guard let newValue = newValue else { return }
        resultMap = newValue.resultMap
      }
    }

    public struct AsMarticleBlockquote: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["MarticleBlockquote"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("content", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(content: String) {
        self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// Markdown text content.
      public var content: String {
        get {
          return resultMap["content"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "content")
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

        public var marticleTextParts: MarticleTextParts? {
          get {
            if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTextParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var imageParts: ImageParts? {
          get {
            if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return ImageParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleDividerParts: MarticleDividerParts? {
          get {
            if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleDividerParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleTableParts: MarticleTableParts? {
          get {
            if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleTableParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleHeadingParts: MarticleHeadingParts? {
          get {
            if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleHeadingParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleCodeBlockParts: MarticleCodeBlockParts? {
          get {
            if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleCodeBlockParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var videoParts: VideoParts? {
          get {
            if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return VideoParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBulletedListParts: MarticleBulletedListParts? {
          get {
            if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleBulletedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleNumberedListParts: MarticleNumberedListParts? {
          get {
            if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
            return MarticleNumberedListParts(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap += newValue.resultMap
          }
        }

        public var marticleBlockquoteParts: MarticleBlockquoteParts {
          get {
            return MarticleBlockquoteParts(unsafeResultMap: resultMap)
          }
          set {
            resultMap += newValue.resultMap
          }
        }
      }
    }
  }

  public struct DomainMetadatum: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["DomainMetadata"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

      public var domainMetadataParts: DomainMetadataParts {
        get {
          return DomainMetadataParts(unsafeResultMap: resultMap)
        }
        set {
          resultMap += newValue.resultMap
        }
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
        GraphQLField("src", type: .nonNull(.scalar(String.self))),
        GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
    public var src: String {
      get {
        return resultMap["src"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "src")
      }
    }

    /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
    public var imageId: Int {
      get {
        return resultMap["imageId"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "imageId")
      }
    }
  }
}

public struct DomainMetadataParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment DomainMetadataParts on DomainMetadata {
      __typename
      name
      logo
    }
    """

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

public struct SlateParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment SlateParts on Slate {
      __typename
      id
      requestId
      experimentId
      displayName
      description
      recommendations {
        __typename
        id
        item {
          __typename
          ...ItemParts
        }
      }
    }
    """

  public static let possibleTypes: [String] = ["Slate"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("id", type: .nonNull(.scalar(String.self))),
      GraphQLField("requestId", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("experimentId", type: .nonNull(.scalar(GraphQLID.self))),
      GraphQLField("displayName", type: .scalar(String.self)),
      GraphQLField("description", type: .scalar(String.self)),
      GraphQLField("recommendations", type: .nonNull(.list(.nonNull(.object(Recommendation.selections))))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(id: String, requestId: GraphQLID, experimentId: GraphQLID, displayName: String? = nil, description: String? = nil, recommendations: [Recommendation]) {
    self.init(unsafeResultMap: ["__typename": "Slate", "id": id, "requestId": requestId, "experimentId": experimentId, "displayName": displayName, "description": description, "recommendations": recommendations.map { (value: Recommendation) -> ResultMap in value.resultMap }])
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

  /// A guid that is unique to every API request that returned slates, such as `getSlateLineup` or `getSlate`.
  /// The API will provide a new request id every time apps hit the API.
  public var requestId: GraphQLID {
    get {
      return resultMap["requestId"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "requestId")
    }
  }

  /// A unique guid/slug, provided by the Data & Learning team that can identify a specific experiment.
  /// Production apps typically won't request a specific one, but can for QA or during a/b testing.
  public var experimentId: GraphQLID {
    get {
      return resultMap["experimentId"]! as! GraphQLID
    }
    set {
      resultMap.updateValue(newValue, forKey: "experimentId")
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
        GraphQLField("item", type: .nonNull(.object(Item.selections))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(id: GraphQLID? = nil, item: Item) {
      self.init(unsafeResultMap: ["__typename": "Recommendation", "id": id, "item": item.resultMap])
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
          GraphQLField("itemId", alias: "remoteID", type: .nonNull(.scalar(String.self))),
          GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
          GraphQLField("resolvedUrl", type: .scalar(String.self)),
          GraphQLField("title", type: .scalar(String.self)),
          GraphQLField("language", type: .scalar(String.self)),
          GraphQLField("topImageUrl", type: .scalar(String.self)),
          GraphQLField("timeToRead", type: .scalar(Int.self)),
          GraphQLField("domain", type: .scalar(String.self)),
          GraphQLField("datePublished", type: .scalar(String.self)),
          GraphQLField("isArticle", type: .scalar(Bool.self)),
          GraphQLField("hasImage", type: .scalar(Imageness.self)),
          GraphQLField("hasVideo", type: .scalar(Videoness.self)),
          GraphQLField("authors", type: .list(.object(Author.selections))),
          GraphQLField("marticle", type: .list(.nonNull(.object(Marticle.selections)))),
          GraphQLField("excerpt", type: .scalar(String.self)),
          GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
          GraphQLField("images", type: .list(.object(Image.selections))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(remoteId: String, givenUrl: String, resolvedUrl: String? = nil, title: String? = nil, language: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, datePublished: String? = nil, isArticle: Bool? = nil, hasImage: Imageness? = nil, hasVideo: Videoness? = nil, authors: [Author?]? = nil, marticle: [Marticle]? = nil, excerpt: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
        self.init(unsafeResultMap: ["__typename": "Item", "remoteID": remoteId, "givenUrl": givenUrl, "resolvedUrl": resolvedUrl, "title": title, "language": language, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "datePublished": datePublished, "isArticle": isArticle, "hasImage": hasImage, "hasVideo": hasVideo, "authors": authors.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, "marticle": marticle.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, "excerpt": excerpt, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      /// A server generated unique id for this item. Item's whose {.normalUrl} are the same will have the same item_id. Most likely numeric, but to ensure future proofing this can be treated as a String in apps.
      public var remoteId: String {
        get {
          return resultMap["remoteID"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "remoteID")
        }
      }

      /// The url as provided by the user when saving. Only http or https schemes allowed.
      public var givenUrl: String {
        get {
          return resultMap["givenUrl"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "givenUrl")
        }
      }

      /// If the givenUrl redirects (once or many times), this is the final url. Otherwise, same as givenUrl
      public var resolvedUrl: String? {
        get {
          return resultMap["resolvedUrl"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "resolvedUrl")
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

      /// The date the article was published
      public var datePublished: String? {
        get {
          return resultMap["datePublished"] as? String
        }
        set {
          resultMap.updateValue(newValue, forKey: "datePublished")
        }
      }

      /// true if the item is an article
      public var isArticle: Bool? {
        get {
          return resultMap["isArticle"] as? Bool
        }
        set {
          resultMap.updateValue(newValue, forKey: "isArticle")
        }
      }

      /// 0=no images, 1=contains images, 2=is an image
      public var hasImage: Imageness? {
        get {
          return resultMap["hasImage"] as? Imageness
        }
        set {
          resultMap.updateValue(newValue, forKey: "hasImage")
        }
      }

      /// 0=no videos, 1=contains video, 2=is a video
      public var hasVideo: Videoness? {
        get {
          return resultMap["hasVideo"] as? Videoness
        }
        set {
          resultMap.updateValue(newValue, forKey: "hasVideo")
        }
      }

      /// List of Authors involved with this article
      public var authors: [Author?]? {
        get {
          return (resultMap["authors"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Author?] in value.map { (value: ResultMap?) -> Author? in value.flatMap { (value: ResultMap) -> Author in Author(unsafeResultMap: value) } } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Author?]) -> [ResultMap?] in value.map { (value: Author?) -> ResultMap? in value.flatMap { (value: Author) -> ResultMap in value.resultMap } } }, forKey: "authors")
        }
      }

      /// The Marticle format of the article, used by clients for native article view.
      public var marticle: [Marticle]? {
        get {
          return (resultMap["marticle"] as? [ResultMap]).flatMap { (value: [ResultMap]) -> [Marticle] in value.map { (value: ResultMap) -> Marticle in Marticle(unsafeResultMap: value) } }
        }
        set {
          resultMap.updateValue(newValue.flatMap { (value: [Marticle]) -> [ResultMap] in value.map { (value: Marticle) -> ResultMap in value.resultMap } }, forKey: "marticle")
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

      public struct Author: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["Author"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
            GraphQLField("name", type: .scalar(String.self)),
            GraphQLField("url", type: .scalar(String.self)),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(id: GraphQLID, name: String? = nil, url: String? = nil) {
          self.init(unsafeResultMap: ["__typename": "Author", "id": id, "name": name, "url": url])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// Unique id for that Author
        public var id: GraphQLID {
          get {
            return resultMap["id"]! as! GraphQLID
          }
          set {
            resultMap.updateValue(newValue, forKey: "id")
          }
        }

        /// Display name
        public var name: String? {
          get {
            return resultMap["name"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "name")
          }
        }

        /// A url to that Author's site
        public var url: String? {
          get {
            return resultMap["url"] as? String
          }
          set {
            resultMap.updateValue(newValue, forKey: "url")
          }
        }
      }

      public struct Marticle: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["MarticleText", "Image", "MarticleDivider", "MarticleTable", "MarticleHeading", "MarticleCodeBlock", "Video", "MarticleBulletedList", "MarticleNumberedList", "MarticleBlockquote", "UnMarseable"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLTypeCase(
              variants: ["MarticleText": AsMarticleText.selections, "Image": AsImage.selections, "MarticleDivider": AsMarticleDivider.selections, "MarticleTable": AsMarticleTable.selections, "MarticleHeading": AsMarticleHeading.selections, "MarticleCodeBlock": AsMarticleCodeBlock.selections, "Video": AsVideo.selections, "MarticleBulletedList": AsMarticleBulletedList.selections, "MarticleNumberedList": AsMarticleNumberedList.selections, "MarticleBlockquote": AsMarticleBlockquote.selections],
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

        public static func makeUnMarseable() -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "UnMarseable"])
        }

        public static func makeMarticleText(content: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleText", "content": content])
        }

        public static func makeImage(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
        }

        public static func makeMarticleDivider(content: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
        }

        public static func makeMarticleTable(html: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
        }

        public static func makeMarticleHeading(content: String, level: Int) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
        }

        public static func makeMarticleCodeBlock(text: String, language: Int? = nil) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
        }

        public static func makeVideo(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
        }

        public static func makeMarticleBulletedList(rows: [AsMarticleBulletedList.Row]) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: AsMarticleBulletedList.Row) -> ResultMap in value.resultMap }])
        }

        public static func makeMarticleNumberedList(rows: [AsMarticleNumberedList.Row]) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: AsMarticleNumberedList.Row) -> ResultMap in value.resultMap }])
        }

        public static func makeMarticleBlockquote(content: String) -> Marticle {
          return Marticle(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
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

          public var marticleTextParts: MarticleTextParts? {
            get {
              if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleTextParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var imageParts: ImageParts? {
            get {
              if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return ImageParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleDividerParts: MarticleDividerParts? {
            get {
              if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleDividerParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleTableParts: MarticleTableParts? {
            get {
              if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleTableParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleHeadingParts: MarticleHeadingParts? {
            get {
              if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleHeadingParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleCodeBlockParts: MarticleCodeBlockParts? {
            get {
              if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleCodeBlockParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var videoParts: VideoParts? {
            get {
              if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return VideoParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleBulletedListParts: MarticleBulletedListParts? {
            get {
              if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleBulletedListParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleNumberedListParts: MarticleNumberedListParts? {
            get {
              if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleNumberedListParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }

          public var marticleBlockquoteParts: MarticleBlockquoteParts? {
            get {
              if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
              return MarticleBlockquoteParts(unsafeResultMap: resultMap)
            }
            set {
              guard let newValue = newValue else { return }
              resultMap += newValue.resultMap
            }
          }
        }

        public var asMarticleText: AsMarticleText? {
          get {
            if !AsMarticleText.possibleTypes.contains(__typename) { return nil }
            return AsMarticleText(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleText: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleText"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Markdown text content. Typically, a paragraph.
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
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

            public var marticleTextParts: MarticleTextParts {
              get {
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asImage: AsImage? {
          get {
            if !AsImage.possibleTypes.contains(__typename) { return nil }
            return AsImage(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsImage: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Image"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("caption", type: .scalar(String.self)),
              GraphQLField("credit", type: .scalar(String.self)),
              GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
              GraphQLField("src", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", type: .scalar(Int.self)),
              GraphQLField("width", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// A caption or description of the image
          public var caption: String? {
            get {
              return resultMap["caption"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "caption")
            }
          }

          /// A credit for the image, typically who the image belongs to / created by
          public var credit: String? {
            get {
              return resultMap["credit"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "credit")
            }
          }

          /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
          public var imageId: Int {
            get {
              return resultMap["imageID"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "imageID")
            }
          }

          /// Absolute url to the image
          public var src: String {
            get {
              return resultMap["src"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "src")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts {
              get {
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleDivider: AsMarticleDivider? {
          get {
            if !AsMarticleDivider.possibleTypes.contains(__typename) { return nil }
            return AsMarticleDivider(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleDivider: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleDivider"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Always '---'; provided for convenience if building a markdown string
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts {
              get {
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleTable: AsMarticleTable? {
          get {
            if !AsMarticleTable.possibleTypes.contains(__typename) { return nil }
            return AsMarticleTable(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleTable: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleTable"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("html", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(html: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Raw HTML representation of the table.
          public var html: String {
            get {
              return resultMap["html"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "html")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts {
              get {
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleHeading: AsMarticleHeading? {
          get {
            if !AsMarticleHeading.possibleTypes.contains(__typename) { return nil }
            return AsMarticleHeading(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleHeading: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleHeading"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
              GraphQLField("level", type: .nonNull(.scalar(Int.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String, level: Int) {
            self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Heading text, in markdown.
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
            }
          }

          /// Heading level. Restricted to values 1-6.
          public var level: Int {
            get {
              return resultMap["level"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "level")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts {
              get {
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleCodeBlock: AsMarticleCodeBlock? {
          get {
            if !AsMarticleCodeBlock.possibleTypes.contains(__typename) { return nil }
            return AsMarticleCodeBlock(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleCodeBlock: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleCodeBlock"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("text", type: .nonNull(.scalar(String.self))),
              GraphQLField("language", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(text: String, language: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Content of a pre tag
          public var text: String {
            get {
              return resultMap["text"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "text")
            }
          }

          /// Assuming the codeblock was a programming language, this field is used to identify it.
          public var language: Int? {
            get {
              return resultMap["language"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "language")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts {
              get {
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asVideo: AsVideo? {
          get {
            if !AsVideo.possibleTypes.contains(__typename) { return nil }
            return AsVideo(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsVideo: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["Video"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("height", type: .scalar(Int.self)),
              GraphQLField("src", type: .nonNull(.scalar(String.self))),
              GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
              GraphQLField("vid", type: .scalar(String.self)),
              GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
              GraphQLField("width", type: .scalar(Int.self)),
              GraphQLField("length", type: .scalar(Int.self)),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
            self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// If known, the height of the video in px
          public var height: Int? {
            get {
              return resultMap["height"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "height")
            }
          }

          /// Absolute url to the video
          public var src: String {
            get {
              return resultMap["src"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "src")
            }
          }

          /// The type of video
          public var type: VideoType {
            get {
              return resultMap["type"]! as! VideoType
            }
            set {
              resultMap.updateValue(newValue, forKey: "type")
            }
          }

          /// The video's id within the service defined by type
          public var vid: String? {
            get {
              return resultMap["vid"] as? String
            }
            set {
              resultMap.updateValue(newValue, forKey: "vid")
            }
          }

          /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
          public var videoId: Int {
            get {
              return resultMap["videoID"]! as! Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "videoID")
            }
          }

          /// If known, the width of the video in px
          public var width: Int? {
            get {
              return resultMap["width"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "width")
            }
          }

          /// If known, the length of the video in seconds
          public var length: Int? {
            get {
              return resultMap["length"] as? Int
            }
            set {
              resultMap.updateValue(newValue, forKey: "length")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts {
              get {
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }
        }

        public var asMarticleBulletedList: AsMarticleBulletedList? {
          get {
            if !AsMarticleBulletedList.possibleTypes.contains(__typename) { return nil }
            return AsMarticleBulletedList(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleBulletedList: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleBulletedList"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(rows: [Row]) {
            self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var rows: [Row] {
            get {
              return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts {
              get {
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Row: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["BulletedListElement"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("content", type: .nonNull(.scalar(String.self))),
                GraphQLField("level", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(content: String, level: Int) {
              self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Row in a list.
            public var content: String {
              get {
                return resultMap["content"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "content")
              }
            }

            /// Zero-indexed level, for handling nested lists.
            public var level: Int {
              get {
                return resultMap["level"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "level")
              }
            }
          }
        }

        public var asMarticleNumberedList: AsMarticleNumberedList? {
          get {
            if !AsMarticleNumberedList.possibleTypes.contains(__typename) { return nil }
            return AsMarticleNumberedList(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleNumberedList: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleNumberedList"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(rows: [Row]) {
            self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var rows: [Row] {
            get {
              return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
            }
            set {
              resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts {
              get {
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts? {
              get {
                if !MarticleBlockquoteParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }
          }

          public struct Row: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["NumberedListElement"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("content", type: .nonNull(.scalar(String.self))),
                GraphQLField("level", type: .nonNull(.scalar(Int.self))),
                GraphQLField("index", type: .nonNull(.scalar(Int.self))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(content: String, level: Int, index: Int) {
              self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            /// Row in a list
            public var content: String {
              get {
                return resultMap["content"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "content")
              }
            }

            /// Zero-indexed level, for handling nexted lists.
            public var level: Int {
              get {
                return resultMap["level"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "level")
              }
            }

            /// Numeric index. If a nested item, the index is zero-indexed from the first child.
            public var index: Int {
              get {
                return resultMap["index"]! as! Int
              }
              set {
                resultMap.updateValue(newValue, forKey: "index")
              }
            }
          }
        }

        public var asMarticleBlockquote: AsMarticleBlockquote? {
          get {
            if !AsMarticleBlockquote.possibleTypes.contains(__typename) { return nil }
            return AsMarticleBlockquote(unsafeResultMap: resultMap)
          }
          set {
            guard let newValue = newValue else { return }
            resultMap = newValue.resultMap
          }
        }

        public struct AsMarticleBlockquote: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["MarticleBlockquote"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("content", type: .nonNull(.scalar(String.self))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(content: String) {
            self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          /// Markdown text content.
          public var content: String {
            get {
              return resultMap["content"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "content")
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

            public var marticleTextParts: MarticleTextParts? {
              get {
                if !MarticleTextParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTextParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var imageParts: ImageParts? {
              get {
                if !ImageParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return ImageParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleDividerParts: MarticleDividerParts? {
              get {
                if !MarticleDividerParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleDividerParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleTableParts: MarticleTableParts? {
              get {
                if !MarticleTableParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleTableParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleHeadingParts: MarticleHeadingParts? {
              get {
                if !MarticleHeadingParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleHeadingParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleCodeBlockParts: MarticleCodeBlockParts? {
              get {
                if !MarticleCodeBlockParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleCodeBlockParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var videoParts: VideoParts? {
              get {
                if !VideoParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return VideoParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBulletedListParts: MarticleBulletedListParts? {
              get {
                if !MarticleBulletedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleBulletedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleNumberedListParts: MarticleNumberedListParts? {
              get {
                if !MarticleNumberedListParts.possibleTypes.contains(resultMap["__typename"]! as! String) { return nil }
                return MarticleNumberedListParts(unsafeResultMap: resultMap)
              }
              set {
                guard let newValue = newValue else { return }
                resultMap += newValue.resultMap
              }
            }

            public var marticleBlockquoteParts: MarticleBlockquoteParts {
              get {
                return MarticleBlockquoteParts(unsafeResultMap: resultMap)
              }
              set {
                resultMap += newValue.resultMap
              }
            }
          }
        }
      }

      public struct DomainMetadatum: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["DomainMetadata"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
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

          public var domainMetadataParts: DomainMetadataParts {
            get {
              return DomainMetadataParts(unsafeResultMap: resultMap)
            }
            set {
              resultMap += newValue.resultMap
            }
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
            GraphQLField("src", type: .nonNull(.scalar(String.self))),
            GraphQLField("imageId", type: .nonNull(.scalar(Int.self))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(height: Int? = nil, width: Int? = nil, src: String, imageId: Int) {
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
        public var src: String {
          get {
            return resultMap["src"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "src")
          }
        }

        /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
        public var imageId: Int {
          get {
            return resultMap["imageId"]! as! Int
          }
          set {
            resultMap.updateValue(newValue, forKey: "imageId")
          }
        }
      }
    }
  }
}

public struct MarticleTextParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleTextParts on MarticleText {
      __typename
      content
    }
    """

  public static let possibleTypes: [String] = ["MarticleText"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("content", type: .nonNull(.scalar(String.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(content: String) {
    self.init(unsafeResultMap: ["__typename": "MarticleText", "content": content])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Markdown text content. Typically, a paragraph.
  public var content: String {
    get {
      return resultMap["content"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }
}

public struct ImageParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment ImageParts on Image {
      __typename
      caption
      credit
      imageID: imageId
      src
      height
      width
    }
    """

  public static let possibleTypes: [String] = ["Image"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("caption", type: .scalar(String.self)),
      GraphQLField("credit", type: .scalar(String.self)),
      GraphQLField("imageId", alias: "imageID", type: .nonNull(.scalar(Int.self))),
      GraphQLField("src", type: .nonNull(.scalar(String.self))),
      GraphQLField("height", type: .scalar(Int.self)),
      GraphQLField("width", type: .scalar(Int.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(caption: String? = nil, credit: String? = nil, imageId: Int, src: String, height: Int? = nil, width: Int? = nil) {
    self.init(unsafeResultMap: ["__typename": "Image", "caption": caption, "credit": credit, "imageID": imageId, "src": src, "height": height, "width": width])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// A caption or description of the image
  public var caption: String? {
    get {
      return resultMap["caption"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "caption")
    }
  }

  /// A credit for the image, typically who the image belongs to / created by
  public var credit: String? {
    get {
      return resultMap["credit"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "credit")
    }
  }

  /// The id for placing within an Article View. {articleView.article} will have placeholders of <div id='RIL_IMG_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
  public var imageId: Int {
    get {
      return resultMap["imageID"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "imageID")
    }
  }

  /// Absolute url to the image
  public var src: String {
    get {
      return resultMap["src"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "src")
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
}

public struct MarticleDividerParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleDividerParts on MarticleDivider {
      __typename
      content
    }
    """

  public static let possibleTypes: [String] = ["MarticleDivider"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("content", type: .nonNull(.scalar(String.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(content: String) {
    self.init(unsafeResultMap: ["__typename": "MarticleDivider", "content": content])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Always '---'; provided for convenience if building a markdown string
  public var content: String {
    get {
      return resultMap["content"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }
}

public struct MarticleTableParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleTableParts on MarticleTable {
      __typename
      html
    }
    """

  public static let possibleTypes: [String] = ["MarticleTable"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("html", type: .nonNull(.scalar(String.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(html: String) {
    self.init(unsafeResultMap: ["__typename": "MarticleTable", "html": html])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Raw HTML representation of the table.
  public var html: String {
    get {
      return resultMap["html"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "html")
    }
  }
}

public struct MarticleHeadingParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleHeadingParts on MarticleHeading {
      __typename
      content
      level
    }
    """

  public static let possibleTypes: [String] = ["MarticleHeading"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("content", type: .nonNull(.scalar(String.self))),
      GraphQLField("level", type: .nonNull(.scalar(Int.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(content: String, level: Int) {
    self.init(unsafeResultMap: ["__typename": "MarticleHeading", "content": content, "level": level])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Heading text, in markdown.
  public var content: String {
    get {
      return resultMap["content"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }

  /// Heading level. Restricted to values 1-6.
  public var level: Int {
    get {
      return resultMap["level"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "level")
    }
  }
}

public struct MarticleCodeBlockParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleCodeBlockParts on MarticleCodeBlock {
      __typename
      text
      language
    }
    """

  public static let possibleTypes: [String] = ["MarticleCodeBlock"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("text", type: .nonNull(.scalar(String.self))),
      GraphQLField("language", type: .scalar(Int.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(text: String, language: Int? = nil) {
    self.init(unsafeResultMap: ["__typename": "MarticleCodeBlock", "text": text, "language": language])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Content of a pre tag
  public var text: String {
    get {
      return resultMap["text"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "text")
    }
  }

  /// Assuming the codeblock was a programming language, this field is used to identify it.
  public var language: Int? {
    get {
      return resultMap["language"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "language")
    }
  }
}

public struct VideoParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment VideoParts on Video {
      __typename
      height
      src
      type
      vid
      videoID: videoId
      width
      length
    }
    """

  public static let possibleTypes: [String] = ["Video"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("height", type: .scalar(Int.self)),
      GraphQLField("src", type: .nonNull(.scalar(String.self))),
      GraphQLField("type", type: .nonNull(.scalar(VideoType.self))),
      GraphQLField("vid", type: .scalar(String.self)),
      GraphQLField("videoId", alias: "videoID", type: .nonNull(.scalar(Int.self))),
      GraphQLField("width", type: .scalar(Int.self)),
      GraphQLField("length", type: .scalar(Int.self)),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(height: Int? = nil, src: String, type: VideoType, vid: String? = nil, videoId: Int, width: Int? = nil, length: Int? = nil) {
    self.init(unsafeResultMap: ["__typename": "Video", "height": height, "src": src, "type": type, "vid": vid, "videoID": videoId, "width": width, "length": length])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// If known, the height of the video in px
  public var height: Int? {
    get {
      return resultMap["height"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "height")
    }
  }

  /// Absolute url to the video
  public var src: String {
    get {
      return resultMap["src"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "src")
    }
  }

  /// The type of video
  public var type: VideoType {
    get {
      return resultMap["type"]! as! VideoType
    }
    set {
      resultMap.updateValue(newValue, forKey: "type")
    }
  }

  /// The video's id within the service defined by type
  public var vid: String? {
    get {
      return resultMap["vid"] as? String
    }
    set {
      resultMap.updateValue(newValue, forKey: "vid")
    }
  }

  /// The id of the video within Article View. {articleView.article} will have placeholders of <div id='RIL_VID_X' /> where X is this id. Apps can download those images as needed and populate them in their article view.
  public var videoId: Int {
    get {
      return resultMap["videoID"]! as! Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "videoID")
    }
  }

  /// If known, the width of the video in px
  public var width: Int? {
    get {
      return resultMap["width"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "width")
    }
  }

  /// If known, the length of the video in seconds
  public var length: Int? {
    get {
      return resultMap["length"] as? Int
    }
    set {
      resultMap.updateValue(newValue, forKey: "length")
    }
  }
}

public struct MarticleBulletedListParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleBulletedListParts on MarticleBulletedList {
      __typename
      rows {
        __typename
        content
        level
      }
    }
    """

  public static let possibleTypes: [String] = ["MarticleBulletedList"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(rows: [Row]) {
    self.init(unsafeResultMap: ["__typename": "MarticleBulletedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var rows: [Row] {
    get {
      return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
    }
  }

  public struct Row: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["BulletedListElement"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("content", type: .nonNull(.scalar(String.self))),
        GraphQLField("level", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(content: String, level: Int) {
      self.init(unsafeResultMap: ["__typename": "BulletedListElement", "content": content, "level": level])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Row in a list.
    public var content: String {
      get {
        return resultMap["content"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "content")
      }
    }

    /// Zero-indexed level, for handling nested lists.
    public var level: Int {
      get {
        return resultMap["level"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "level")
      }
    }
  }
}

public struct MarticleNumberedListParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleNumberedListParts on MarticleNumberedList {
      __typename
      rows {
        __typename
        content
        level
        index
      }
    }
    """

  public static let possibleTypes: [String] = ["MarticleNumberedList"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("rows", type: .nonNull(.list(.nonNull(.object(Row.selections))))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(rows: [Row]) {
    self.init(unsafeResultMap: ["__typename": "MarticleNumberedList", "rows": rows.map { (value: Row) -> ResultMap in value.resultMap }])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  public var rows: [Row] {
    get {
      return (resultMap["rows"] as! [ResultMap]).map { (value: ResultMap) -> Row in Row(unsafeResultMap: value) }
    }
    set {
      resultMap.updateValue(newValue.map { (value: Row) -> ResultMap in value.resultMap }, forKey: "rows")
    }
  }

  public struct Row: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["NumberedListElement"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
        GraphQLField("content", type: .nonNull(.scalar(String.self))),
        GraphQLField("level", type: .nonNull(.scalar(Int.self))),
        GraphQLField("index", type: .nonNull(.scalar(Int.self))),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(content: String, level: Int, index: Int) {
      self.init(unsafeResultMap: ["__typename": "NumberedListElement", "content": content, "level": level, "index": index])
    }

    public var __typename: String {
      get {
        return resultMap["__typename"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "__typename")
      }
    }

    /// Row in a list
    public var content: String {
      get {
        return resultMap["content"]! as! String
      }
      set {
        resultMap.updateValue(newValue, forKey: "content")
      }
    }

    /// Zero-indexed level, for handling nexted lists.
    public var level: Int {
      get {
        return resultMap["level"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "level")
      }
    }

    /// Numeric index. If a nested item, the index is zero-indexed from the first child.
    public var index: Int {
      get {
        return resultMap["index"]! as! Int
      }
      set {
        resultMap.updateValue(newValue, forKey: "index")
      }
    }
  }
}

public struct MarticleBlockquoteParts: GraphQLFragment {
  /// The raw GraphQL definition of this fragment.
  public static let fragmentDefinition: String =
    """
    fragment MarticleBlockquoteParts on MarticleBlockquote {
      __typename
      content
    }
    """

  public static let possibleTypes: [String] = ["MarticleBlockquote"]

  public static var selections: [GraphQLSelection] {
    return [
      GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
      GraphQLField("content", type: .nonNull(.scalar(String.self))),
    ]
  }

  public private(set) var resultMap: ResultMap

  public init(unsafeResultMap: ResultMap) {
    self.resultMap = unsafeResultMap
  }

  public init(content: String) {
    self.init(unsafeResultMap: ["__typename": "MarticleBlockquote", "content": content])
  }

  public var __typename: String {
    get {
      return resultMap["__typename"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "__typename")
    }
  }

  /// Markdown text content.
  public var content: String {
    get {
      return resultMap["content"]! as! String
    }
    set {
      resultMap.updateValue(newValue, forKey: "content")
    }
  }
}
