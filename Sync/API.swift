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

public final class UserByTokenQuery: GraphQLQuery {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    query UserByToken($token: String!, $pagination: PaginationInput) {
      userByToken(token: $token) {
        __typename
        savedItems(pagination: $pagination) {
          __typename
          edges {
            __typename
            cursor
            node {
              __typename
              url
              _createdAt
              item {
                __typename
                title
                topImageUrl
                timeToRead
                domain
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
            }
          }
        }
      }
    }
    """

  public let operationName: String = "UserByToken"

  public var token: String
  public var pagination: PaginationInput?

  public init(token: String, pagination: PaginationInput? = nil) {
    self.token = token
    self.pagination = pagination
  }

  public var variables: GraphQLMap? {
    return ["token": token, "pagination": pagination]
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
          GraphQLField("savedItems", arguments: ["pagination": GraphQLVariable("pagination")], type: .object(SavedItem.selections)),
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

      /// Get a general paginated listing of all user items for the user
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
            GraphQLField("edges", type: .list(.object(Edge.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(edges: [Edge?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "SavedItemConnection", "edges": edges.flatMap { (value: [Edge?]) -> [ResultMap?] in value.map { (value: Edge?) -> ResultMap? in value.flatMap { (value: Edge) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
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

          /// The item at the end of the edge.
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
                GraphQLField("url", type: .nonNull(.scalar(String.self))),
                GraphQLField("_createdAt", type: .nonNull(.scalar(String.self))),
                GraphQLField("item", type: .nonNull(.object(Item.selections))),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(url: String, _createdAt: String, item: Item) {
              self.init(unsafeResultMap: ["__typename": "SavedItem", "url": url, "_createdAt": _createdAt, "item": item.resultMap])
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

            /// Unix timestamp of when the entity was created
            public var _createdAt: String {
              get {
                return resultMap["_createdAt"]! as! String
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
              public static let possibleTypes: [String] = ["Item"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("title", type: .scalar(String.self)),
                  GraphQLField("topImageUrl", type: .scalar(String.self)),
                  GraphQLField("timeToRead", type: .scalar(Int.self)),
                  GraphQLField("domain", type: .scalar(String.self)),
                  GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
                  GraphQLField("images", type: .list(.object(Image.selections))),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(title: String? = nil, topImageUrl: String? = nil, timeToRead: Int? = nil, domain: String? = nil, domainMetadata: DomainMetadatum? = nil, images: [Image?]? = nil) {
                self.init(unsafeResultMap: ["__typename": "Item", "title": title, "topImageUrl": topImageUrl, "timeToRead": timeToRead, "domain": domain, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }, "images": images.flatMap { (value: [Image?]) -> [ResultMap?] in value.map { (value: Image?) -> ResultMap? in value.flatMap { (value: Image) -> ResultMap in value.resultMap } } }])
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
          }
        }
      }
    }
  }
}
