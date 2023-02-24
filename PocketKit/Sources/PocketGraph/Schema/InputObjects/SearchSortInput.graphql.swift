// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct SearchSortInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    sortBy: GraphQLEnum<SearchItemsSortBy>,
    sortOrder: GraphQLNullable<GraphQLEnum<SearchItemsSortOrder>> = nil
  ) {
    __data = InputDict([
      "sortBy": sortBy,
      "sortOrder": sortOrder
    ])
  }

  /// The field by which to sort user items
  public var sortBy: GraphQLEnum<SearchItemsSortBy> {
    get { __data["sortBy"] }
    set { __data["sortBy"] = newValue }
  }

  /// The order in which to sort user items
  public var sortOrder: GraphQLNullable<GraphQLEnum<SearchItemsSortOrder>> {
    get { __data["sortOrder"] }
    set { __data["sortOrder"] = newValue }
  }
}
