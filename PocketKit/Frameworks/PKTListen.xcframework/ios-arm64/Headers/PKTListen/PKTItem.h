//
//  Item.h
//  RIL
//
//  Created by Nathan Weiner on 10/23/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

@import UIKit;

#import "PKTSharedEnums.h"
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTPosition;
@class PKTFriend;
@class PKTShare;
@class PKTHighlightAnnotation;
@class PKTDomainMetadata;

extern NSString * const ItemHighlightingFullTextKey;
extern NSString * const ItemHighlightingTitleKey;
extern NSString * const ItemHighlightingTagsKey;
extern NSString * const ItemHighlightingUrlKey;

@interface PKTItem : NSObject <PKTModelCodable> {
@protected NSDictionary *_userInfo;
}

// PKTItem Attributes
@property (nonatomic, strong) NSNumber *uniqueId;
@property (nonatomic, strong) NSNumber *itemId;
@property (nonatomic, strong) NSNumber *resolvedId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *ampUrl;
@property (nonatomic, strong) NSURL *givenURL;
@property (nonatomic, copy) NSString *domain;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, copy) NSString *encoding;
@property (nonatomic, strong) NSNumber *wordCount;
@property (nonatomic, copy) NSString *timeAdded;
@property (nonatomic, copy) NSString *timeFavorited;
@property (nonatomic, copy) NSString *timeRead;
@property (nonatomic, copy) NSString *excerpt;
@property (nonatomic, copy) NSString *topImageURL;
@property (nonatomic, copy, readonly, nullable) NSString *languageCode;
@property (nonatomic, assign, readonly) NSTimeInterval estimatedListenDuration;
@property (nonatomic, strong) NSURL *thumbnailURL;
@property (nullable, nonatomic, strong) NSNumber *badgeGroupId;

@property (nonatomic, readonly) BOOL hasExcerpt;
@property (nonatomic, readonly) BOOL hasShares;
@property (nonatomic, readonly) BOOL hasTweet;
@property (nonatomic, readonly) BOOL hasAttributions;
@property (nonatomic, readonly) BOOL hasAnnotations;
@property (nonatomic, strong, readonly) NSArray<PKTHighlightAnnotation*> *annotations;
@property (nonatomic, assign) ItemStatus status;
@property (nonatomic, assign) BOOL favorite;

// Offline Attributes
@property (nonatomic, assign) ItemOfflineStatus offlineWeb;
@property (nonatomic, assign) ItemOfflineStatus offlineText;
@property (nonatomic, assign) ItemArticleStatus isArticle;
@property (nonatomic, assign) ItemVideoStatus isVideo;
@property (nonatomic, assign) ItemImageStatus isImage;
@property (nonatomic, assign) BOOL hasImage;
@property (nonatomic, assign) BOOL hasVideo;

// Additional Data
@property (nonatomic, strong) NSDictionary *image;
@property (nonatomic, strong) NSDictionary *images;
@property (nonatomic, strong) NSDictionary *videos;
@property (nonatomic, copy) NSDictionary *attributions;
@property (nonatomic, copy) NSArray *posts;
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableDictionary *positions;
@property (nonatomic, strong) NSMutableDictionary *meta;
@property (nonatomic, strong) NSMutableDictionary <NSString *, PKTShare *>*shares;

/// Search highlights information for this item. Keys can be: full_text, title, tags, url
@property (nonatomic, strong) NSDictionary *highlights;

/**
 @return the NSDictionary object used to create or update the receiver. 
 */
@property (nonatomic, readonly, strong) NSDictionary *userInfo;

@property (atomic, readonly, strong, nullable) NSString *displayAuthors;

@property (nonatomic, readonly, strong, nullable) PKTDomainMetadata *domainMetadata;

- (instancetype)initWithDictionary:(NSDictionary *)itemDictionary NS_DESIGNATED_INITIALIZER;

- (instancetype)init __unavailable;

- (void)updateWithItem:(PKTItem *)item;
- (void)updateItemAttributes:(PKTItem *)item;

- (BOOL)hasValidUniqueId;
- (NSNumber *)uniqueIdIfSet;
- (NSNumber *)uniqueIdIfValidOrItemId;

#pragma mark -

- (NSURL *)bestUrl;
- (NSString *)bestDomain;
- (NSString *)bestTitle;

///
- (NSString *)displayTitle __deprecated;

///
- (NSString *)displayExcerpt __deprecated;

///
- (NSString *)displayDomain __deprecated;

- (NSString *_Nullable)imageURLString;


#pragma mark - 

/// Returns highlighted tags within an array and without any highlight tags
- (NSArray<NSString*> *_Nullable)highlightedTags __deprecated;

#pragma mark -

- (BOOL)isSavedOffline;

- (id)getMeta:(MetaId)metaId;
- (void)setMeta:(id _Nullable)value forMetaId:(MetaId)metaId;

#pragma mark -

- (NSDictionary *_Nullable)thumbImageDictionary;

- (PKTPosition *_Nullable)position:(RILViewType)view;

#pragma mark -

- (PKTFriend *)avatarFriend;
- (NSArray *_Nullable)sharesOrderedByMostRecent;
- (void)removeShare:(PKTShare *)share;

@end

NS_ASSUME_NONNULL_END;
