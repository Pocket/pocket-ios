//
//  PKTImageCacheManagement
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 9/22/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;

#import "PKTImageResource.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, PKTRemoteImageDeleteOptions) {
    PKTRemoteImageDeleteOptionsDeleteNone               = 0,
    PKTRemoteImageDeleteOptionsDeleteRaw                = 1 << 0,
    PKTRemoteImageDeleteOptionsDeleteThumbnails         = 1 << 1,
    PKTRemoteImageDeleteOptionsDeleteMetadata           = 1 << 2,
    PKTRemoteImageDeleteOptionsDeleteEverything         = (PKTRemoteImageDeleteOptionsDeleteRaw
                                                           |PKTRemoteImageDeleteOptionsDeleteThumbnails
                                                           |PKTRemoteImageDeleteOptionsDeleteMetadata)
};

@protocol PKTImageCacheManagement <NSObject>

@property (nonatomic, readwrite, assign, getter=isDisabled) BOOL disabled;
@property (nonatomic, readonly, assign, getter=isCleaning) BOOL cleaning;
@property (nonatomic, readonly) unsigned long long imageCacheBytes;
@property (nonatomic, readonly) float imageCacheMegabytes;

+ (id<PKTImageCacheManagement>)sharedManager;

- (void)deleteResource:(id<PKTImageResource>)resource options:(PKTRemoteImageDeleteOptions)options;

- (void)cleanCache:(unsigned long long)limit strategy:(PKTRemoteImageDeleteOptions)strategy;

- (BOOL)isAvailableOffline:(id<PKTImageResource>)resource;

- (NSDictionary *_Nullable)readImageInfo:(id<PKTImageResource>)resource;

- (void)writeImageInfo:(NSDictionary *_Nullable)imageInfo resource:(id<PKTImageResource> _Nonnull)resource;

- (void)deleteEphemeralImages;

@end

NS_ASSUME_NONNULL_END
