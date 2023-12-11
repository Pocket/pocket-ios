// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class HomeSlateLineupQuery: GraphQLQuery {
  public static let operationName: String = "HomeSlateLineup"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query HomeSlateLineup($locale: String!) { homeSlateLineup(locale: $locale) { __typename id slates { __typename ...CorpusSlateParts } } }"#,
      fragments: [CollectionAuthorSummary.self, CollectionSummary.self, CorpusItemParts.self, CorpusRecommendationParts.self, CorpusSlateParts.self, SyndicatedArticleParts.self]
    ))

  public var locale: String

  public init(locale: String) {
    self.locale = locale
  }

  public var __variables: Variables? { ["locale": locale] }

  public struct Data: PocketGraph.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("homeSlateLineup", HomeSlateLineup.self, arguments: ["locale": .variable("locale")]),
    ] }

    /// Get ranked corpus slates and recommendations to deliver a unified Home experience. 
    public var homeSlateLineup: HomeSlateLineup { __data["homeSlateLineup"] }

    /// HomeSlateLineup
    ///
    /// Parent Type: `CorpusSlateLineup`
    public struct HomeSlateLineup: PocketGraph.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusSlateLineup }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", PocketGraph.ID.self),
        .field("slates", [Slate].self),
      ] }

      /// UUID
      public var id: PocketGraph.ID { __data["id"] }
      /// Slates.
      public var slates: [Slate] { __data["slates"] }

      /// HomeSlateLineup.Slate
      ///
      /// Parent Type: `CorpusSlate`
      public struct Slate: PocketGraph.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusSlate }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .fragment(CorpusSlateParts.self),
        ] }

        /// UUID
        public var id: PocketGraph.ID { __data["id"] }
        /// The display headline for the slate. Surface context may be required to render determine what to display. This will depend on if we connect the copy to the Surface, SlateExperiment, or Slate.
        public var headline: String { __data["headline"] }
        /// A smaller, secondary headline that can be displayed to provide additional context on the slate.
        public var subheadline: String? { __data["subheadline"] }
        /// Recommendations for the current request context.
        public var recommendations: [Recommendation] { __data["recommendations"] }

        public struct Fragments: FragmentContainer {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public var corpusSlateParts: CorpusSlateParts { _toFragment() }
        }

        /// HomeSlateLineup.Slate.Recommendation
        ///
        /// Parent Type: `CorpusRecommendation`
        public struct Recommendation: PocketGraph.SelectionSet {
          public let __data: DataDict
          public init(_dataDict: DataDict) { __data = _dataDict }

          public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusRecommendation }

          /// Clients should include this id in the `corpus_recommendation` Snowplow entity for impression, content_open, and engagement events related to this recommendation. This id is different across users, across requests, and across corpus items. The recommendation-api service associates metadata with this id to join and aggregate recommendations in our data warehouse.
          public var id: PocketGraph.ID { __data["id"] }
          /// Content meta data.
          public var corpusItem: CorpusItem { __data["corpusItem"] }

          public struct Fragments: FragmentContainer {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public var corpusRecommendationParts: CorpusRecommendationParts { _toFragment() }
          }

          /// HomeSlateLineup.Slate.Recommendation.CorpusItem
          ///
          /// Parent Type: `CorpusItem`
          public struct CorpusItem: PocketGraph.SelectionSet {
            public let __data: DataDict
            public init(_dataDict: DataDict) { __data = _dataDict }

            public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CorpusItem }

            /// The GUID that is stored on an approved corpus item
            public var id: PocketGraph.ID { __data["id"] }
            /// The URL of the Approved Item.
            public var url: PocketGraph.Url { __data["url"] }
            /// The title of the Approved Item.
            public var title: String { __data["title"] }
            /// The excerpt of the Approved Item.
            public var excerpt: String { __data["excerpt"] }
            /// The image URL for this item's accompanying picture.
            public var imageUrl: PocketGraph.Url { __data["imageUrl"] }
            /// The name of the online publication that published this story.
            public var publisher: String { __data["publisher"] }
            /// If the Corpus Item is pocket owned with a specific type, this is the associated object (Collection or SyndicatedArticle).
            public var target: Target? { __data["target"] }

            public struct Fragments: FragmentContainer {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public var corpusItemParts: CorpusItemParts { _toFragment() }
            }

            /// HomeSlateLineup.Slate.Recommendation.CorpusItem.Target
            ///
            /// Parent Type: `CorpusTarget`
            public struct Target: PocketGraph.SelectionSet {
              public let __data: DataDict
              public init(_dataDict: DataDict) { __data = _dataDict }

              public static var __parentType: ApolloAPI.ParentType { PocketGraph.Unions.CorpusTarget }

              public var asSyndicatedArticle: AsSyndicatedArticle? { _asInlineFragment() }
              public var asCollection: AsCollection? { _asInlineFragment() }

              /// HomeSlateLineup.Slate.Recommendation.CorpusItem.Target.AsSyndicatedArticle
              ///
              /// Parent Type: `SyndicatedArticle`
              public struct AsSyndicatedArticle: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = HomeSlateLineupQuery.Data.HomeSlateLineup.Slate.Recommendation.CorpusItem.Target
                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.SyndicatedArticle }
                public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                  SyndicatedArticleParts.self,
                  CorpusItemParts.Target.AsSyndicatedArticle.self
                ] }

                /// The item id of this Syndicated Article
                public var itemId: PocketGraph.ID? { __data["itemId"] }
                /// Primary image to use in surfacing this content
                public var mainImage: String? { __data["mainImage"] }
                /// Title of syndicated article
                public var title: String { __data["title"] }
                /// Excerpt 
                public var excerpt: String? { __data["excerpt"] }
                /// The manually set publisher information for this article
                public var publisher: SyndicatedArticleParts.Publisher? { __data["publisher"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var syndicatedArticleParts: SyndicatedArticleParts { _toFragment() }
                }
              }

              /// HomeSlateLineup.Slate.Recommendation.CorpusItem.Target.AsCollection
              ///
              /// Parent Type: `Collection`
              public struct AsCollection: PocketGraph.InlineFragment, ApolloAPI.CompositeInlineFragment {
                public let __data: DataDict
                public init(_dataDict: DataDict) { __data = _dataDict }

                public typealias RootEntityType = HomeSlateLineupQuery.Data.HomeSlateLineup.Slate.Recommendation.CorpusItem.Target
                public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.Collection }
                public static var __mergedSources: [any ApolloAPI.SelectionSet.Type] { [
                  CollectionSummary.self,
                  CorpusItemParts.Target.AsCollection.self
                ] }

                public var slug: String { __data["slug"] }
                public var authors: [Author] { __data["authors"] }

                public struct Fragments: FragmentContainer {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public var collectionSummary: CollectionSummary { _toFragment() }
                }

                /// HomeSlateLineup.Slate.Recommendation.CorpusItem.Target.AsCollection.Author
                ///
                /// Parent Type: `CollectionAuthor`
                public struct Author: PocketGraph.SelectionSet {
                  public let __data: DataDict
                  public init(_dataDict: DataDict) { __data = _dataDict }

                  public static var __parentType: ApolloAPI.ParentType { PocketGraph.Objects.CollectionAuthor }

                  public var name: String { __data["name"] }

                  public struct Fragments: FragmentContainer {
                    public let __data: DataDict
                    public init(_dataDict: DataDict) { __data = _dataDict }

                    public var collectionAuthorSummary: CollectionAuthorSummary { _toFragment() }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
