//
//  PKTAudioStreamPrivate.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 7/31/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "PKTListen.h"
#import "PKTAudibleQueue.h"
#import "PKTAudioStream.h"
#import "PKTAVAssetResourceLoader.h"
#import "PKTAudioStream+PKTSeeking.h"

#if PKTAudioStreamLoggingEnabled
#define PKTAudioStreamLog(...) PKTLog(PKTLogZoneDynamic, LISTEN_CONTEXT, LOG_FLAG_INFO, __VA_ARGS__)
#else
#define PKTAudioStreamLog(...) PKTLog(PKTLogZoneDisk, LISTEN_CONTEXT, LOG_FLAG_INFO, __VA_ARGS__)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface PKTAudioStream () <PKTAVAssetResourceLoaderDelegate> {
    BOOL _didMessageLoad;
    BOOL _didMessageFail;
    BOOL _didMessageCancel;
    BOOL _didMessageDownload;
    BOOL _didMessageFinish;
    BOOL _isSeekingRestore;
    BOOL _shouldRestorePlaybackPosition;
    CGFloat _seekPosition;
    CMTime _seekTime;
    BOOL _isDestroyed;
}

@property (atomic, readonly, assign)                                BOOL hasLoaded;
@property (nonatomic, readwrite, assign, getter=isStalled)          BOOL stalled;
@property (nonatomic, readwrite, assign, getter=isFinished)         BOOL finished; // KVO Observable
@property (nonatomic, readwrite, assign)                            BOOL didForceDurationToLoad;
@property (nonatomic, readwrite, strong, nullable)                  NSError *error;
@property (nonatomic, readwrite, strong, nullable)                  NSTimer *healthCheckTimer;
@property (nonatomic, readonly, strong, nonnull)                    id<NSObject> didReachEnd;
@property (nonatomic, readonly, strong, nonnull)                    id<NSObject> didStall;
@property (nonatomic, readonly, strong, nonnull)                    id<NSObject> durationDidChange;
@property (nonatomic, readwrite, strong, nullable)                  id<NSObject> timeDidUpdate;
/// Instance debug timer for tracking state changes
@property (nonatomic, readonly, strong, nonnull)                    PKTDebugTimer *timer;
@property (nonatomic, readwrite, assign)                            BOOL isReadyToPlay;
@property (nonatomic, readwrite, assign)                            CMTime seekTime;
@property (nonatomic, readwrite, strong, nullable)                  PKTAVAssetResourceLoader *loader;
@property (nonatomic, readwrite, assign, getter=isDownloading)      BOOL downloading;
@property (nonatomic, readwrite, assign)                            CGFloat downloadProgress;

- (CMTime)maxSeekTime;

- (CGFloat)maxSeekPercentage;

- (void)assetDidFailToLoad:(AVAsset *)duration error:(NSError *_Nullable)error;

- (void)assetDidCancelLoading:(AVAsset *)duration;

- (void)assetDidLoad:(AVAsset *)duration;

- (void)assetDidDownload:(AVAsset *)duration;

- (void)assetCanPlay:(AVAsset *)duration;

- (void)assetDidStall:(AVAsset *)duration;

- (void)assetDidFinishPlayback:(AVAsset *)duration;

- (void)assetDidUpdate:(AVAsset *)duration;

+ (nullable instancetype)stream:(PKTAudioStreamInfo *)streamInfo kusari:(PKTKusari<id<PKTListenItem>> *)kusari;

+ (PKTAudioStreamInfo *)preferredStream:(NSArray<PKTAudioStreamInfo*> *)streams;

@end

NS_ASSUME_NONNULL_END
