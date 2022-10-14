// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Pagination request. To determine which edges to return, the connection
/// evaluates the `before` and `after` cursors (if given) to filter the
/// edges, then evaluates `first`/`last` to slice the edges (only include a
/// value for either `first` or `last`, not both). If all fields are null,
/// by default will return a page with the first 30 elements.
public struct PaginationInput: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    after: GraphQLNullable<String> = nil,
    before: GraphQLNullable<String> = nil,
    first: GraphQLNullable<Int> = nil,
    last: GraphQLNullable<Int> = nil
  ) {
    __data = InputDict([
      "after": after,
      "before": before,
      "first": first,
      "last": last
    ])
  }

  /// Returns the elements in the list that come after the specified cursor.
  /// The specified cursor is not included in the result.
  public var after: GraphQLNullable<String> {
    get { __data.after }
    set { __data.after = newValue }
  }

  /// Returns the elements in the list that come before the specified cursor.
  /// The specified cursor is not included in the result.
  public var before: GraphQLNullable<String> {
    get { __data.before }
    set { __data.before = newValue }
  }

  /// Returns the first _n_ elements from the list. Must be a non-negative integer.
  /// If `first` contains a value, `last` should be null/omitted in the input.
  public var first: GraphQLNullable<Int> {
    get { __data.first }
    set { __data.first = newValue }
  }

  /// Returns the last _n_ elements from the list. Must be a non-negative integer.
  /// If `last` contains a value, `first` should be null/omitted in the input.
  public var last: GraphQLNullable<Int> {
    get { __data.last }
    set { __data.last = newValue }
  }
}
