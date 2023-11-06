// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class DomainMetadata: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.DomainMetadata
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<DomainMetadata>>

  public struct MockFields {
    @Field<PocketGraph.Url>("logo") public var logo
    @Field<String>("name") public var name
  }
}

public extension Mock where O == DomainMetadata {
  convenience init(
    logo: PocketGraph.Url? = nil,
    name: String? = nil
  ) {
    self.init()
    _setScalar(logo, for: \.logo)
    _setScalar(name, for: \.name)
  }
}
