// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Extended properties that Unleash can use to assign users through a toggle's strategies.
public struct UnleashProperties: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    locale: GraphQLNullable<String> = nil,
    accountCreatedAt: GraphQLNullable<String> = nil,
    recItUserProfile: GraphQLNullable<RecItUserProfile> = nil
  ) {
    __data = InputDict([
      "locale": locale,
      "accountCreatedAt": accountCreatedAt,
      "recItUserProfile": recItUserProfile
    ])
  }

  /// If omitted, inferred from request header `accept-langauge`.
  public var locale: GraphQLNullable<String> {
    get { __data["locale"] }
    set { __data["locale"] = newValue }
  }

  /// Only required on activation strategies that are based on account age
  public var accountCreatedAt: GraphQLNullable<String> {
    get { __data["accountCreatedAt"] }
    set { __data["accountCreatedAt"] = newValue }
  }

  /// Only required on activation strategies that are based whether a user model exists
  public var recItUserProfile: GraphQLNullable<RecItUserProfile> {
    get { __data["recItUserProfile"] }
    set { __data["recItUserProfile"] = newValue }
  }
}
