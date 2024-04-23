// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class ShareNotFound: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.ShareNotFound
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<ShareNotFound>>

  public struct MockFields {
    @Field<String>("message") public var message
  }
}

public extension Mock where O == ShareNotFound {
  convenience init(
    message: String? = nil
  ) {
    self.init()
    _setScalar(message, for: \.message)
  }
}
