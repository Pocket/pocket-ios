// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import PocketGraph

public class SavedItemAnnotations: MockObject {
  public static let objectType: ApolloAPI.Object = PocketGraph.Objects.SavedItemAnnotations
  public static let _mockFields = MockFields()
  public typealias MockValueCollectionType = Array<Mock<SavedItemAnnotations>>

  public struct MockFields {
    @Field<[Highlight?]>("highlights") public var highlights
  }
}

public extension Mock where O == SavedItemAnnotations {
  convenience init(
    highlights: [Mock<Highlight>?]? = nil
  ) {
    self.init()
    _setList(highlights, for: \.highlights)
  }
}
