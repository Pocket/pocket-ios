// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class MarticleText: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.MarticleText
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<MarticleText>>

  public struct MockFields {
    @Field<PocketGraph.Markdown>("content") public var content
  }
}

public extension Mock where O == MarticleText {
  convenience init(
    content: PocketGraph.Markdown? = nil
  ) {
    self.init()
    _setScalar(content, for: \.content)
  }
}
