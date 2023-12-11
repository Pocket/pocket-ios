// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleTable: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.MarticleTable
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleTable>>

  public struct MockFields {
    @Field<String>("html") public var html
  }
}

public extension Mock where O == MarticleTable {
  convenience init(
    html: String? = nil
  ) {
    self.init()
    _setScalar(html, for: \.html)
  }
}
