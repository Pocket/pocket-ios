// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct PaginationInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - after: Returns the elements in the list that come after the specified cursor.
  ///   - before: Returns the elements in the list that come before the specified cursor.
  ///   - first: Returns the first _n_ elements from the list.
  ///   - last: Returns the last _n_ elements from the list.
  public init(after: Swift.Optional<GraphQLID?> = nil, before: Swift.Optional<GraphQLID?> = nil, first: Swift.Optional<Int?> = nil, last: Swift.Optional<Int?> = nil) {
    graphQLMap = ["after": after, "before": before, "first": first, "last": last]
  }

  /// Returns the elements in the list that come after the specified cursor.
  public var after: Swift.Optional<GraphQLID?> {
    get {
      return graphQLMap["after"] as? Swift.Optional<GraphQLID?> ?? Swift.Optional<GraphQLID?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "after")
    }
  }

  /// Returns the elements in the list that come before the specified cursor.
  public var before: Swift.Optional<GraphQLID?> {
    get {
      return graphQLMap["before"] as? Swift.Optional<GraphQLID?> ?? Swift.Optional<GraphQLID?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "before")
    }
  }

  /// Returns the first _n_ elements from the list.
  public var first: Swift.Optional<Int?> {
    get {
      return graphQLMap["first"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "first")
    }
  }

  /// Returns the last _n_ elements from the list.
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
        userItems(pagination: $pagination) {
          __typename
          nodes {
            __typename
            url
            asyncItem {
              __typename
              item {
                __typename
                title
                domain
                timeToRead
                topImageUrl
                givenUrl
                userItem {
                  __typename
                  _createdAt
                }
                domainMetadata {
                  __typename
                  name
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
          GraphQLField("userItems", arguments: ["pagination": GraphQLVariable("pagination")], type: .object(UserItem.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(userItems: UserItem? = nil) {
        self.init(unsafeResultMap: ["__typename": "User", "userItems": userItems.flatMap { (value: UserItem) -> ResultMap in value.resultMap }])
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
      public var userItems: UserItem? {
        get {
          return (resultMap["userItems"] as? ResultMap).flatMap { UserItem(unsafeResultMap: $0) }
        }
        set {
          resultMap.updateValue(newValue?.resultMap, forKey: "userItems")
        }
      }

      public struct UserItem: GraphQLSelectionSet {
        public static let possibleTypes: [String] = ["UserItemConnection"]

        public static var selections: [GraphQLSelection] {
          return [
            GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
            GraphQLField("nodes", type: .list(.object(Node.selections))),
          ]
        }

        public private(set) var resultMap: ResultMap

        public init(unsafeResultMap: ResultMap) {
          self.resultMap = unsafeResultMap
        }

        public init(nodes: [Node?]? = nil) {
          self.init(unsafeResultMap: ["__typename": "UserItemConnection", "nodes": nodes.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }])
        }

        public var __typename: String {
          get {
            return resultMap["__typename"]! as! String
          }
          set {
            resultMap.updateValue(newValue, forKey: "__typename")
          }
        }

        /// A list of nodes.
        public var nodes: [Node?]? {
          get {
            return (resultMap["nodes"] as? [ResultMap?]).flatMap { (value: [ResultMap?]) -> [Node?] in value.map { (value: ResultMap?) -> Node? in value.flatMap { (value: ResultMap) -> Node in Node(unsafeResultMap: value) } } }
          }
          set {
            resultMap.updateValue(newValue.flatMap { (value: [Node?]) -> [ResultMap?] in value.map { (value: Node?) -> ResultMap? in value.flatMap { (value: Node) -> ResultMap in value.resultMap } } }, forKey: "nodes")
          }
        }

        public struct Node: GraphQLSelectionSet {
          public static let possibleTypes: [String] = ["UserItem"]

          public static var selections: [GraphQLSelection] {
            return [
              GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
              GraphQLField("url", type: .nonNull(.scalar(String.self))),
              GraphQLField("asyncItem", type: .nonNull(.object(AsyncItem.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(url: String, asyncItem: AsyncItem) {
            self.init(unsafeResultMap: ["__typename": "UserItem", "url": url, "asyncItem": asyncItem.resultMap])
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

          /// Link to the underlying Pocket Item for the URL
          public var asyncItem: AsyncItem {
            get {
              return AsyncItem(unsafeResultMap: resultMap["asyncItem"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "asyncItem")
            }
          }

          public struct AsyncItem: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["AsyncItem"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("item", type: .object(Item.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(item: Item? = nil) {
              self.init(unsafeResultMap: ["__typename": "AsyncItem", "item": item.flatMap { (value: Item) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var item: Item? {
              get {
                return (resultMap["item"] as? ResultMap).flatMap { Item(unsafeResultMap: $0) }
              }
              set {
                resultMap.updateValue(newValue?.resultMap, forKey: "item")
              }
            }

            public struct Item: GraphQLSelectionSet {
              public static let possibleTypes: [String] = ["Item"]

              public static var selections: [GraphQLSelection] {
                return [
                  GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                  GraphQLField("title", type: .scalar(String.self)),
                  GraphQLField("domain", type: .scalar(String.self)),
                  GraphQLField("timeToRead", type: .scalar(Int.self)),
                  GraphQLField("topImageUrl", type: .scalar(String.self)),
                  GraphQLField("givenUrl", type: .nonNull(.scalar(String.self))),
                  GraphQLField("userItem", type: .object(UserItem.selections)),
                  GraphQLField("domainMetadata", type: .object(DomainMetadatum.selections)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(title: String? = nil, domain: String? = nil, timeToRead: Int? = nil, topImageUrl: String? = nil, givenUrl: String, userItem: UserItem? = nil, domainMetadata: DomainMetadatum? = nil) {
                self.init(unsafeResultMap: ["__typename": "Item", "title": title, "domain": domain, "timeToRead": timeToRead, "topImageUrl": topImageUrl, "givenUrl": givenUrl, "userItem": userItem.flatMap { (value: UserItem) -> ResultMap in value.resultMap }, "domainMetadata": domainMetadata.flatMap { (value: DomainMetadatum) -> ResultMap in value.resultMap }])
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

              /// The domain, such as 'getpocket.com' of the {.resolved_url}
              public var domain: String? {
                get {
                  return resultMap["domain"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "domain")
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

              /// The page's / publisher's preferred thumbnail image
              public var topImageUrl: String? {
                get {
                  return resultMap["topImageUrl"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "topImageUrl")
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

              /// Helper property to identify if the given item is in the user's list
              public var userItem: UserItem? {
                get {
                  return (resultMap["userItem"] as? ResultMap).flatMap { UserItem(unsafeResultMap: $0) }
                }
                set {
                  resultMap.updateValue(newValue?.resultMap, forKey: "userItem")
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

              public struct UserItem: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["UserItem"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("_createdAt", type: .nonNull(.scalar(String.self))),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(_createdAt: String) {
                  self.init(unsafeResultMap: ["__typename": "UserItem", "_createdAt": _createdAt])
                }

                public var __typename: String {
                  get {
                    return resultMap["__typename"]! as! String
                  }
                  set {
                    resultMap.updateValue(newValue, forKey: "__typename")
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
              }

              public struct DomainMetadatum: GraphQLSelectionSet {
                public static let possibleTypes: [String] = ["DomainMetadata"]

                public static var selections: [GraphQLSelection] {
                  return [
                    GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                    GraphQLField("name", type: .scalar(String.self)),
                  ]
                }

                public private(set) var resultMap: ResultMap

                public init(unsafeResultMap: ResultMap) {
                  self.resultMap = unsafeResultMap
                }

                public init(name: String? = nil) {
                  self.init(unsafeResultMap: ["__typename": "DomainMetadata", "name": name])
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
              }
            }
          }
        }
      }
    }
  }
}
