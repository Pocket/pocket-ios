//
//  PKTAudibleItemCacheManagerPrivate.h
//  PKTListen
//
//  Created by David Skuza on 2/21/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import "PKTListenCacheManager.h"
#import <YapDatabase/YapDatabase.h>;

UIKIT_EXTERN NSString *_Nonnull const PKTAudioStreamStateDidChangeNotification;
UIKIT_EXTERN NSString *_Nonnull const kPKTListenCollectionAudioURL;
UIKIT_EXTERN NSString *_Nonnull const kPKTListenCollectionListeningPosition;
UIKIT_EXTERN NSString *_Nonnull const kPKTListenCollectionAPIResponse;
UIKIT_EXTERN NSString *_Nonnull const kPKTListenCollectionAudioStream;
UIKIT_EXTERN NSString *_Nonnull const kPKTListenCollectionAudioStreamsInfo;
UIKIT_EXTERN NSString *_Nonnull const kPKTListenClientSettingsCollectionName;

@interface PKTListenCacheManager()

@property (nonnull, nonatomic, readonly, strong) YapDatabase *store;
@property (nonnull, nonatomic, readonly, strong) YapDatabaseConnection *master;

@property (nonnull, nonatomic, readonly, strong) id<NSObject> advance;
@property (nonnull, nonatomic, readonly, strong) YapDatabaseConnection *read;
@property (nonnull, nonatomic, readonly, strong) YapDatabaseConnection *write;

@end
