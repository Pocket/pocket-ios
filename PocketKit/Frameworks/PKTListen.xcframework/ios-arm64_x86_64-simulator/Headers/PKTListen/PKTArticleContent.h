//
//  PKTArticleContent.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 1/28/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import Foundation;

#import "PKTKusari.h"
#import "PKTListenItem.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - PKTArticleContent

@class PKTItem;

typedef NS_ENUM(NSInteger, PKTArticleContentSourceType) {
    PKTArticleContentSourceTypeNone,
    PKTArticleContentSourceTypeWeb,
    PKTArticleContentSourceTypeText,
    PKTArticleContentSourceTypeSampleArticle, // The HTML content from the Pocket test article HTML
};

typedef NS_ENUM(NSInteger, PKTArticleContentErrorCode) {
    PKTArticleContentErrorCodeUndefined = 0,
    PKTArticleContentErrorCodeUndefinedResource,
};

/**
 PKTArticleContext is a data container capable of asynchronously loading an article HTML file.
 */

@interface PKTArticleContent : NSObject

/// @return the content type this object represents
@property (nonatomic, readonly, assign) PKTArticleContentSourceType type;
/// @return the global unique ID for this article
/// @note The unique ID is equivalent to the Pocket item ID
@property (nonatomic, readonly, copy, nonnull) NSString *uniqueID;
/// @return an NSData representation of the loaded article content
@property (nonatomic, readonly, copy, nullable) NSData *data;
/// @return the base URL of HTML content
@property (nonatomic, readonly, copy, nullable) NSURL *baseURL; // KVO Observable
/// @return NSString representation of HTTML content
@property (nonatomic, readonly, copy, nullable) NSString *HTML; // KVO Observable
/// @return YES, if the article content is available locally (offline).
@property (nonatomic, readonly, assign, getter=isAvailable) BOOL available;

/// Load an article content
/// @param kusari A PKTKusari container representing the item for which the content is required
/// @param type the type of content to load.
/// @param completion a completion block. When the block is executed, either a valid content object will be returned, or an error.
/// @note If the article content is available locally, the local cache will be used; otherwise, loading will attempt to download the content from the server
@property (nonatomic, readonly, copy, nonnull, class) void (^load)(PKTKusari<id<PKTListenItem>> * kusari, PKTArticleContentSourceType type, void(^completion)(NSError *_Nullable error, PKTArticleContent *_Nullable content));

/// Instantiate a new content instance for the provided kusari and content type
- (instancetype)initWithKusari:(PKTKusari<id<PKTListenItem>> *)kusari type:(PKTArticleContentSourceType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Loads the content.
/// @note If the article content is available locally, the local cache will be used; otherwise, loading will attempt to download the content from the server.
- (void)load:(nullable void(^)(NSError *_Nullable error, NSString *_Nullable HTML, NSURL *_Nullable baseURL))completion;

/// Reloads the content.
/// @note this method attempts to reload the content by requesting the latest version from the server.
- (void)reload:(nullable void(^)(NSError *_Nullable error, NSString *_Nullable HTML, NSURL *_Nullable baseURL))completion;

/// @return YES if the article content for the provided item and type is available locally (offline).
+ (BOOL)isAvailable:(PKTKusari<id<PKTListenItem>> *)kusari type:(PKTArticleContentSourceType)type;

@end

NS_ASSUME_NONNULL_END
