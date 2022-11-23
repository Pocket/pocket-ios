// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// Information about the user and device. Based on https://unleash.github.io/docs/unleash_context
///
/// Used to calculate assignment values.
public struct UnleashContext: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    appName: GraphQLNullable<String> = nil,
    environment: GraphQLNullable<GraphQLEnum<UnleashEnvironment>> = nil,
    userId: GraphQLNullable<String> = nil,
    sessionId: GraphQLNullable<String> = nil,
    remoteAddress: GraphQLNullable<String> = nil,
    properties: GraphQLNullable<UnleashProperties> = nil
  ) {
    __data = InputDict([
      "appName": appName,
      "environment": environment,
      "userId": userId,
      "sessionId": sessionId,
      "remoteAddress": remoteAddress,
      "properties": properties
    ])
  }

  /// A unique name for one of our apps. Can be any string, but here are some known/expected values:
  ///
  /// - `android`
  /// - `ios`
  /// - `web-discover`
  /// - `web-app`
  public var appName: GraphQLNullable<String> {
    get { __data["appName"] }
    set { __data["appName"] = newValue }
  }

  /// The environment the device is running in:
  /// - `prod`
  /// - `beta`
  /// - `alpha`
  public var environment: GraphQLNullable<GraphQLEnum<UnleashEnvironment>> {
    get { __data["environment"] }
    set { __data["environment"] = newValue }
  }

  /// If logged in, the user's encoded user id (uid). The {Account.user_id}.
  public var userId: GraphQLNullable<String> {
    get { __data["userId"] }
    set { __data["userId"] = newValue }
  }

  /// A device specific identifier that will be consistent across sessions, typically the encoded {guid} or some session token.
  public var sessionId: GraphQLNullable<String> {
    get { __data["sessionId"] }
    set { __data["sessionId"] = newValue }
  }

  /// The device's IP address. If omitted, inferred from either request header `x-forwarded-for` or the origin IP of the request.
  public var remoteAddress: GraphQLNullable<String> {
    get { __data["remoteAddress"] }
    set { __data["remoteAddress"] = newValue }
  }

  public var properties: GraphQLNullable<UnleashProperties> {
    get { __data["properties"] }
    set { __data["properties"] = newValue }
  }
}
