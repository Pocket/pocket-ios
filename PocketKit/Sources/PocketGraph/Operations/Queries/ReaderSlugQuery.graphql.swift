// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class ReaderSlugQuery: GraphQLQuery {
  public static let operationName: String = "ReaderSlug"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query ReaderSlug($readerSlugSlug: ID!) { readerSlug(slug: $readerSlugSlug) { __typename fallbackPage { __typename ... on ReaderInterstitial { itemCard { __typename item { __typename givenUrl } } } } savedItem { __typename id url } } }"#
    ))

  public var readerSlugSlug: ID

  public init(readerSlugSlug: ID) {
    self.readerSlugSlug = readerSlugSlug
  }

  public var __variables: Variables? { ["readerSlugSlug": readerSlugSlug] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("readerSlug", ReaderSlug.self, arguments: ["slug": .variable("readerSlugSlug")]),
    ] }

    /// Resolve Reader View links which might point to SavedItems that do not
    /// exist, aren't in the Pocket User's list, or are requested by a logged-out
    /// user (or user without a Pocket Account).
    /// Fetches data to create an interstitial page/modal so the visitor can click
    /// through to the shared site.
    public var readerSlug: ReaderSlug { __data["readerSlug"] }

    /// ReaderSlug
    ///
    /// Parent Type: `ReaderViewResult`
    public struct ReaderSlug: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.ReaderViewResult }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("fallbackPage", FallbackPage?.self),
        .field("savedItem", SavedItem?.self),
      ] }

      public var fallbackPage: FallbackPage? { __data["fallbackPage"] }
      /// The SavedItem referenced by this reader view slug, if it
      /// is in the Pocket User's list.
      public var savedItem: SavedItem? { __data["savedItem"] }

      /// ReaderSlug.FallbackPage
      ///
      /// Parent Type: `ReaderFallback`
      public struct FallbackPage: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.ReaderFallback }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .inlineFragment(AsReaderInterstitial.self),
        ] }

        public var asReaderInterstitial: AsReaderInterstitial? { _asInlineFragment() }

        /// ReaderSlug.FallbackPage.AsReaderInterstitial
        ///
        /// Parent Type: `ReaderInterstitial`
        public struct AsReaderInterstitial: PocketGraph.InlineFragment {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public typealias RootEntityType = ReaderSlugQuery.Data.ReaderSlug.FallbackPage
          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.ReaderInterstitial }
          public static var __selections: [ApolloAPI.Selection] { [
            .field("itemCard", ItemCard?.self),
          ] }

          public var itemCard: ItemCard? { __data["itemCard"] }

          /// ReaderSlug.FallbackPage.AsReaderInterstitial.ItemCard
          ///
          /// Parent Type: `PocketMetadata`
          public struct ItemCard: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { PocketGraph.Interfaces.PocketMetadata }
            public static var __selections: [ApolloAPI.Selection] { [
              .field("__typename", String.self),
              .field("item", Item?.self),
            ] }

            public var item: Item? { __data["item"] }

            /// ReaderSlug.FallbackPage.AsReaderInterstitial.ItemCard.Item
            ///
            /// Parent Type: `Item`
            public struct Item: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Item }
              public static var __selections: [ApolloAPI.Selection] { [
                .field("__typename", String.self),
                .field("givenUrl", PocketGraph.Url.self),
              ] }

              /// key field to identify the Item entity in the Parser service
              public var givenUrl: PocketGraph.Url { __data["givenUrl"] }
            }
          }
        }
      }

      /// ReaderSlug.SavedItem
      ///
      /// Parent Type: `SavedItem`
      public struct SavedItem: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SavedItem }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", PocketGraph.ID.self),
          .field("url", String.self),
        ] }

        /// Surrogate primary key. This is usually generated by clients, but will be generated by the server if not passed through creation
        public var id: PocketGraph.ID { __data["id"] }
        /// The url the user saved to their list
        public var url: String { __data["url"] }
      }
    }
  }
}
