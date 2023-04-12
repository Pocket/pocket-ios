//
//  PKTListenAudibleItemQueuePrivate.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//


#ifndef PKTListenAudibleItemQueuePrivate_h
#define PKTListenAudibleItemQueuePrivate_h

@import AVFoundation;
@import MediaPlayer;

#import "PKTListen.h"
#import "PKTListenAudibleItemQueue.h"
#import "PKTListenAudibleItemQueue+KVO.h"
#import "PKTListenAudibleItemQueue+PKTPlaybackControlEvent.h"
#import "PKTListenAudibleItemQueue+MPRemoteCommandCenter.h"
#import "PKTListenAudibleItemQueue+PKTListDiffable.h"
#import "PKTListenAudibleItemQueue+Accessors.h"
#import "PKTListenAudibleItemQueue+PKTAudioStreamPlayerDelegate.h"
#import "PKTListenAudibleItemQueue+PKTErrors.h"
#import "PKTListenPlaybackState.h"

#if PKTAudibleQueueLoggingEnabled
#define PKTAudibleQueueLog(...) PKTLog(PKTLogZoneDynamic, LISTEN_CONTEXT, LOG_FLAG_INFO, __VA_ARGS__)
#else
#define PKTAudibleQueueLog(...) PKTLog(PKTLogZoneDisk, LISTEN_CONTEXT, LOG_FLAG_INFO, __VA_ARGS__)
#endif

NS_ASSUME_NONNULL_BEGIN

@class PKTAudioStreamPlayer;

@interface  PKTListenAudibleItemQueue() {
@protected BOOL _isDestroyed;
@protected UIBackgroundTaskIdentifier _backgroundLoading;
@protected PKTListenDataSource<id<PKTListenItem>> *__strong _source;
@protected PKTKusari<id<PKTListenItem>> *__strong _staged;
@protected id<PKTListenPlayer> __strong _player;
@protected NSTimer *__strong _idleTimer;
@protected BOOL _flagAutoPause;
@protected BOOL _isSeekingRestore;
@protected id<PKTListenConfiguration> _configuration;
@protected void * PKTListenAudibleItemQueueKVOContext;
}

@property (atomic, readonly, strong, nullable) NSTimer *idleTimer;
@property (atomic, readonly, strong, nullable) NSTimer *nextTimer;
@property (atomic, readwrite, strong, nullable) id<PKTListenPlayer> player;
@property (atomic, readwrite, strong, nonnull) id<NSObject> timeDidUpdate;
@property (atomic, readwrite, strong, nonnull) id<PKTListenPlaybackStateUpdate> state;
@property (atomic, readwrite, strong, nullable) PKTListenDataSource<id<PKTListenItem>> *source;
@property (nonatomic, readwrite, strong, nullable) id<PKTListenConfiguration> configuration;
@property (nonatomic, readwrite, strong, nonnull) id<NSObject> didBecomeActive;
@property (nonatomic, readwrite, strong, nonnull) id<NSObject> willResignActive;

@property (nonatomic, readwrite, strong, nullable) PKTListenItemSession *session;

- (void)autoplayNextUnlistened:(PKTAudioStreamPlayer *)player
                         stage:(NSTimeInterval)stage
                          play:(NSTimeInterval)play
                       context:(NSString *)contextUI;

- (void)updateKusari:(PKTKusari<id<PKTListenItem>> *)kusari asPlaying:(BOOL)playing;

#pragma mark - PKTListenAudibleItemQueue+MPRemoteCommandCenter

@property (atomic, readwrite, strong, nullable) NSDictionary<NSString*, id> *nowPlayingInfo;

@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidPlay;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidPause;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidScanForwards;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidScanBackwards;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidSkipForwards;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidSkipBackwards;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidScrub;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidLike;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidDislike;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidTogglePlayPause;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidBookmark;
@property (nonatomic, readwrite, strong, nullable) id<NSObject> remoteDidChangeRate;

#pragma mark - PKTListenAudibleItemQueue+PKTAudioStreamPlayerDelegate

@property (atomic, readwrite, strong, nullable) NSTimer *deleteStream;
@property (atomic, readwrite, weak, nullable) PKTAudioStreamInfo *streamToDelete;

@end

NS_ASSUME_NONNULL_END

#endif /* PKTListenAudibleItemQueuePrivate_h */
