//
//  PKTKusari+PKTListen.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/10/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;
@import AVFoundation;

#import "PKTKusari.h"
#import "PKTListenItem.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTRemoteMedia;
@class PKTAudioStream;
@class PKTRemoteImageCache;
@class PKTRemoteImage;

@protocol PKTAudibleItemCache;

#pragma mark - <PKTListenKusariConfiguration>

@protocol PKTListenKusariConfiguration <NSObject>

@property (nonatomic, readonly, strong, nonnull) id<PKTAudibleItemCache> cache;

@end

#pragma mark - PKTKusari+PKTListen

@interface PKTKusari (PKTListen)

@property (nonatomic, readonly, strong, nullable) id<PKTListenItem> album;

@property (nonatomic, readonly, copy, nullable) NSString *albumID;

#pragma mark Audio Streams

@property (nonatomic, readonly, assign) CGFloat position;

@property (nonatomic, readonly, assign) CMTime currentTimeRecord;

@property (nonatomic, readonly, assign) CMTime durationRecord;

@property (nonatomic, readonly, assign) CMTime remainingTimeRecord;

@property (nonatomic, readonly, assign) BOOL isListened;

@property (nonatomic, readonly, assign) BOOL hasDownloaded;

@property (nonatomic, readonly, assign) CGFloat downloadProgress;

@property (nonatomic, readonly, assign) BOOL isPlaying;

#pragma mark Images

@property (nonatomic, readonly, assign) BOOL hasImage;

@property (nonatomic, readonly, assign, class) CGSize thumbnailSize;

@property (nonatomic, readonly, assign, class) CGSize albumSize;

@property (nonatomic, readonly, strong, nullable) PKTAudioStream *stream;

@property (nonatomic, readonly, strong, nullable) PKTRemoteImage *remoteThumbnail;

@property (nonatomic, readonly, strong, nullable) PKTRemoteImage *remoteAlbumArt;

@property (nonatomic, readonly, strong, nullable) PKTRemoteImageCache *remoteImageCache;

@property (nonatomic, readonly, strong, nullable) id<PKTListenKusariConfiguration> configuration;

- (void)warmImage;

- (void)loadStream:(void(^)(NSError *_Nullable error, PKTAudioStream *_Nullable stream))completion;

- (void)updateStreamPlaybackState:(PKTAudioStream *)stream;

- (void)downloadStream;

- (void)destroyStream;

#pragma mark - Letter Press

@property (nonatomic, readonly, strong, nullable) NSDictionary<UIColor*, UIColor*> *letterPressColors;
@property (nonatomic, readonly, strong, nullable) UIColor *letterPressTextColor;
@property (nonatomic, readonly, strong, nullable) UIColor *letterPressBackgroundColor;

@end

#pragma mark - PKTListenKusari

/**
 PKTListenKusari is a concrete PKTKusari subclass that adopts certain Listen-specific behavior.
 
 In particular, a PKTListenKusari can return a "refreshed" instance of itself, in which its stateful properties have
 been replaced by the latest values held by the backing store.
 */

@interface PKTListenKusari : PKTKusari <id<PKTListenItem>>

@property (nonatomic, readonly, assign) BOOL hasLoadedStream;

/// A Kusari instance with the underlying state refreshed from the stores
@property (nonatomic, readonly, copy, nonnull) PKTListenKusari *_Nonnull (^refreshed)(void);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenKusariConfiguration> configuration;

PKTListenKusari * PKTListenKusariCreate(NSString *_Nonnull uniqueID,
                                        NSInteger type,
                                        id<PKTListenItem> album,
                                        id<PKTListenKusariConfiguration> configuration);

@end

NS_ASSUME_NONNULL_END
