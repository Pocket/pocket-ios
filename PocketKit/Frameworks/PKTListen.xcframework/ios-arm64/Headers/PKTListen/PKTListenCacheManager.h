//
//  PKTListenCacheManager.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/28/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import UIKit;

@import AVFoundation;

#import "PKTAudibleItemCache.h"

#define PKTAudibleItemCacheManagerSimulateDeletions TARGET_OS_SIMULATOR
#define PKTAudibleItemCacheManagerValidateFiles TARGET_OS_SIMULATOR

NS_ASSUME_NONNULL_BEGIN

@protocol PKTListenItem;

@class PKTAudioStream;

UIKIT_EXTERN NSString * const kPKTListenCollectionAudioURL;
UIKIT_EXTERN NSString * const kPKTListenCollectionListeningPosition;
UIKIT_EXTERN NSString * const kPKTListenCollectionAPIResponse;
UIKIT_EXTERN NSString * const kPKTListenCollectionAudioStream;
UIKIT_EXTERN NSString * const PKTAudioStreamStateDidChangeNotification;

@interface PKTListenCacheManager : NSObject <PKTAudibleItemCache>

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
