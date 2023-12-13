// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct SearchFilterInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    isFavorite: GraphQLNullable<Bool> = nil,
    onlyTitleAndURL: GraphQLNullable<Bool> = nil,
    contentType: GraphQLNullable<GraphQLEnum<SearchItemsContentType>> = nil,
    status: GraphQLNullable<GraphQLEnum<SearchItemsStatusFilter>> = nil,
    domain: GraphQLNullable<String> = nil
  ) {
    __data = InputDict([
      "isFavorite": isFavorite,
      "onlyTitleAndURL": onlyTitleAndURL,
      "contentType": contentType,
      "status": status,
      "domain": domain
    ])
  }

  /// Optional, filter to get user items that have been favorited
  public var isFavorite: GraphQLNullable<Bool> {
    get { __data["isFavorite"] }
    set { __data["isFavorite"] = newValue }
  }

  /// Optional, filter to get user items only based on title and url, ie Free Search
  /// Note, though that if this is selected and the user is premium, they will not get search highligthing.
  public var onlyTitleAndURL: GraphQLNullable<Bool> {
    get { __data["onlyTitleAndURL"] }
    set { __data["onlyTitleAndURL"] = newValue }
  }

  /// Optional, filter to get SavedItems based on content type
  public var contentType: GraphQLNullable<GraphQLEnum<SearchItemsContentType>> {
    get { __data["contentType"] }
    set { __data["contentType"] = newValue }
  }

  /// Optional, filter to get user items based on status.
  public var status: GraphQLNullable<GraphQLEnum<SearchItemsStatusFilter>> {
    get { __data["status"] }
    set { __data["status"] = newValue }
  }

  /// Optional filter to get items that matches the domain
  /// domain should be in the url format, e.g getpocket.com (or) list.getpocket.com
  public var domain: GraphQLNullable<String> {
    get { __data["domain"] }
    set { __data["domain"] = newValue }
  }
}
