// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

/// A SavedItem can be one of these content types
public enum SavedItemsContentType: String, EnumType {
  /// Item is a parsed article that contains videos
  ///
  /// **Deprecated**: Use `HAS_VIDEO`.
  case video = "VIDEO"
  /// Item is a parsed page can be opened in reader view
  ///
  /// **Deprecated**: Use `IS_READABLE`.
  case article = "ARTICLE"
  /// Item is an image
  case isImage = "IS_IMAGE"
  /// Item is a video
  case isVideo = "IS_VIDEO"
  /// Item is a parsed article that contains videos
  case hasVideo = "HAS_VIDEO"
  /// Item is a parsed page can be opened in reader view
  case isReadable = "IS_READABLE"
  /// Item is an un-parsable page and will be opened externally
  case isExternal = "IS_EXTERNAL"
}
