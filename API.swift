// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public struct PaginationInput: GraphQLMapConvertible {
  public var graphQLMap: GraphQLMap

  /// - Parameters:
  ///   - after
  ///   - before
  ///   - first
  ///   - last
  public init(after: Swift.Optional<GraphQLID?> = nil, before: Swift.Optional<GraphQLID?> = nil, first: Swift.Optional<Int?> = nil, last: Swift.Optional<Int?> = nil) {
    graphQLMap = ["after": after, "before": before, "first": first, "last": last]
  }

  public var after: Swift.Optional<GraphQLID?> {
    get {
      return graphQLMap["after"] as? Swift.Optional<GraphQLID?> ?? Swift.Optional<GraphQLID?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "after")
    }
  }

  public var before: Swift.Optional<GraphQLID?> {
    get {
      return graphQLMap["before"] as? Swift.Optional<GraphQLID?> ?? Swift.Optional<GraphQLID?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "before")
    }
  }

  public var first: Swift.Optional<Int?> {
    get {
      return graphQLMap["first"] as? Swift.Optional<Int?> ?? Swift.Optional<Int?>.none
    }
    set {
      graphQLMap.updateValue(newValue, forKey: "first")
    }
  }

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
    query UserByToken($userByTokenToken: String!, $userItemsPagination: PaginationInput) {
      userByToken(token: $userByTokenToken) {
        __typename
        id
        userItems(pagination: $userItemsPagination) {
          __typename
          nodes {
            __typename
            url
            item {
              __typename
              url
              item {
                __typename
                resolvedUrl
                resolvedTitle
              }
            }
          }
        }
      }
    }
    """

  public let operationName: String = "UserByToken"

  public var userByTokenToken: String
  public var userItemsPagination: PaginationInput?

  public init(userByTokenToken: String, userItemsPagination: PaginationInput? = nil) {
    self.userByTokenToken = userByTokenToken
    self.userItemsPagination = userItemsPagination
  }

  public var variables: GraphQLMap? {
    return ["userByTokenToken": userByTokenToken, "userItemsPagination": userItemsPagination]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Query"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("userByToken", arguments: ["token": GraphQLVariable("userByTokenToken")], type: .object(UserByToken.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(userByToken: UserByToken? = nil) {
      self.init(unsafeResultMap: ["__typename": "Query", "userByToken": userByToken.flatMap { (value: UserByToken) -> ResultMap in value.resultMap }])
    }

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
          GraphQLField("id", type: .nonNull(.scalar(GraphQLID.self))),
          GraphQLField("userItems", arguments: ["pagination": GraphQLVariable("userItemsPagination")], type: .object(UserItem.selections)),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: GraphQLID, userItems: UserItem? = nil) {
        self.init(unsafeResultMap: ["__typename": "User", "id": id, "userItems": userItems.flatMap { (value: UserItem) -> ResultMap in value.resultMap }])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: GraphQLID {
        get {
          return resultMap["id"]! as! GraphQLID
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

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
              GraphQLField("item", type: .nonNull(.object(Item.selections))),
            ]
          }

          public private(set) var resultMap: ResultMap

          public init(unsafeResultMap: ResultMap) {
            self.resultMap = unsafeResultMap
          }

          public init(url: String, item: Item) {
            self.init(unsafeResultMap: ["__typename": "UserItem", "url": url, "item": item.resultMap])
          }

          public var __typename: String {
            get {
              return resultMap["__typename"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "__typename")
            }
          }

          public var url: String {
            get {
              return resultMap["url"]! as! String
            }
            set {
              resultMap.updateValue(newValue, forKey: "url")
            }
          }

          public var item: Item {
            get {
              return Item(unsafeResultMap: resultMap["item"]! as! ResultMap)
            }
            set {
              resultMap.updateValue(newValue.resultMap, forKey: "item")
            }
          }

          public struct Item: GraphQLSelectionSet {
            public static let possibleTypes: [String] = ["AsyncItem"]

            public static var selections: [GraphQLSelection] {
              return [
                GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
                GraphQLField("url", type: .nonNull(.scalar(String.self))),
                GraphQLField("item", type: .object(Item.selections)),
              ]
            }

            public private(set) var resultMap: ResultMap

            public init(unsafeResultMap: ResultMap) {
              self.resultMap = unsafeResultMap
            }

            public init(url: String, item: Item? = nil) {
              self.init(unsafeResultMap: ["__typename": "AsyncItem", "url": url, "item": item.flatMap { (value: Item) -> ResultMap in value.resultMap }])
            }

            public var __typename: String {
              get {
                return resultMap["__typename"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "__typename")
              }
            }

            public var url: String {
              get {
                return resultMap["url"]! as! String
              }
              set {
                resultMap.updateValue(newValue, forKey: "url")
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
                  GraphQLField("resolvedUrl", type: .scalar(String.self)),
                  GraphQLField("resolvedTitle", type: .scalar(String.self)),
                ]
              }

              public private(set) var resultMap: ResultMap

              public init(unsafeResultMap: ResultMap) {
                self.resultMap = unsafeResultMap
              }

              public init(resolvedUrl: String? = nil, resolvedTitle: String? = nil) {
                self.init(unsafeResultMap: ["__typename": "Item", "resolvedUrl": resolvedUrl, "resolvedTitle": resolvedTitle])
              }

              public var __typename: String {
                get {
                  return resultMap["__typename"]! as! String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "__typename")
                }
              }

              public var resolvedUrl: String? {
                get {
                  return resultMap["resolvedUrl"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "resolvedUrl")
                }
              }

              public var resolvedTitle: String? {
                get {
                  return resultMap["resolvedTitle"] as? String
                }
                set {
                  resultMap.updateValue(newValue, forKey: "resolvedTitle")
                }
              }
            }
          }
        }
      }
    }
  }
}
