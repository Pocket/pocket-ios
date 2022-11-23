// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

public struct RecItUserProfile: InputObject {
  public private(set) var __data: InputDict

  public init(_ data: InputDict) {
    __data = data
  }

  public init(
    userModels: [String]
  ) {
    __data = InputDict([
      "userModels": userModels
    ])
  }

  public var userModels: [String] {
    get { __data["userModels"] }
    set { __data["userModels"] = newValue }
  }
}
