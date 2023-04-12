//
//  PKTItemViewModel.h
//  PKTRuntime
//
//  Created by Larry Tran on 10/15/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTModelCodable.h"
#import "PKTSharedEnums.h"

@class PKTHighlightAnnotation, PKTShare, PKTDomainMetadata, PKTSearchHighlight, PKTPosition;

NS_ASSUME_NONNULL_BEGIN

@interface PKTItemViewModel : NSObject <PKTModelCodable>

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (instancetype)init __unavailable;

- (void)updateModel:(PKTItemViewModel *)model;

- (BOOL)isSavedOffline;

@property (nonatomic, copy, readonly) NSNumber *uniqueId;
@property (nonatomic, copy, readonly) NSNumber *resolvedId;
@property (nonatomic, copy, readonly) NSNumber *itemId;
@property (nonatomic, copy, readonly, nullable) NSURL *url;
@property (nonatomic, copy, readonly, nullable) NSURL *givenUrl;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *domain;
@property (nonatomic, copy, readonly) NSString *excerpt;
@property (nonatomic, copy, readonly) NSString *timeAdded;
@property (nonatomic, copy, readonly) NSURL *imageUrl;
@property (nonatomic, copy, readonly) NSURL *fallBackImageUrl;
@property (nonatomic, copy, readonly) NSArray <NSString *>*tags;
@property (nonatomic, assign, readonly) BOOL favorite;
@property (nonatomic, assign, readonly) NSInteger isArticle;
@property (nonatomic, assign, readonly) NSInteger isVideo;
@property (nonatomic, assign, readonly) ItemStatus status;
@property (nonatomic, copy, readonly) NSNumber *wordCount;
@property (nonatomic, copy, readonly) NSNumber *badgeGroupId;
@property (nonatomic, copy, readonly) NSArray <PKTHighlightAnnotation *>*annotations;
@property (nonatomic, copy, readonly) NSDictionary <NSString *, PKTShare *>*shares;
@property (nonatomic, copy, readonly, nullable) NSArray *sharesOrderedByMostRecent;
@property (nonatomic, strong, readonly) PKTDomainMetadata *domainMetaData;
@property (nonatomic, copy, readonly) NSDictionary *meta;
@property (nonatomic, strong, readonly) PKTPosition *positions;
@property (nonatomic, strong, readonly) PKTSearchHighlight *searchHighlight;
@property (nonatomic, assign, readonly) ItemOfflineStatus offlineWeb;
@property (nonatomic, assign, readonly) ItemOfflineStatus offlineText;
@end

NS_ASSUME_NONNULL_END
