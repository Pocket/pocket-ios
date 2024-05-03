// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class OEmbed: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.OEmbed
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<OEmbed>>

  public struct MockFields {
    @Field<PocketGraph.ID>("id") public var id
    @Field<Item>("item") public var item
    @Field<PocketGraph.Url>("url") public var url
  }
}

public extension Mock where O == OEmbed {
  convenience init(
    id: PocketGraph.ID? = nil,
    item: Mock<Item>? = nil,
    url: PocketGraph.Url? = nil
  ) {
    self.init()
    _setScalar(id, for: \.id)
    _setEntity(item, for: \.item)
    _setScalar(url, for: \.url)
  }
}
