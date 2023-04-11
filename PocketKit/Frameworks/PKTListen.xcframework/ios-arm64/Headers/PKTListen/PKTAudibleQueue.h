//
//  PKTAudibleQueue.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/9/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import Foundation;
@import AVKit;
@import MediaPlayer;

#import "PKTListenItem.h"
#import "PKTFeedSource.h"
#import "PKTListenDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTAudioStream;
@class PKTListenItemSession;
@class PKTListenPlaybackState;

@protocol PKTListenConfiguration;

typedef NS_ENUM(NSInteger, PKTPlaybackControlEvent) {
    PKTPlaybackControlEventPlay,
    PKTPlaybackControlEventPause,
    PKTPlaybackControlEventSkipForwards,
    PKTPlaybackControlEventSkipBackwards,
    PKTPlaybackControlEventScanForwards,
    PKTPlaybackControlEventScanBackwards,
    PKTPlaybackControlEventArchive,
    PKTPlaybackControlEventAdd
};

@protocol PKTAudibleQueue <NSObject>

@optional

@property (nonatomic, readonly, strong, nonnull) id<PKTListenConfiguration> configuration;
@property (atomic, readonly, strong, nullable) PKTKusari<id<PKTListenItem>> *staged;
@property (atomic, readonly, strong, nonnull) PKTListenDataSource<id<PKTListenItem>> *source;
@property (atomic, readonly, strong, nullable) PKTListenItemSession *session;
@property (atomic, readonly, strong, nonnull) PKTListenPlaybackState *state;
@property (atomic, readwrite, assign) NSInteger speedFactor;

#pragma mark Kusari

- (void)stageKusari:(PKTKusari<id<PKTListenItem>> *)kusari force:(BOOL)force;

- (void)stageKusari:(PKTKusari<id<PKTListenItem>> *)kusari;

- (void)playKusari:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;

- (void)autoplayKusari:(nonnull PKTKusari<id<PKTListenItem>> *)kusari
                 force:(BOOL)forcePlayback
                 after:(NSTimeInterval)delay
               context:(NSDictionary *)context;

- (void)removeKusari:(nonnull PKTKusari<id<PKTListenItem>> *)kusari;

- (void)seekToPosition:(CGFloat)position completion:(void(^)(BOOL finished))completion;

#pragma mark State

- (void)invalidateAutoplay;

- (void)destroyQueue;

#pragma mark Controls

- (void)control:(id)control didSendEvent:(PKTPlaybackControlEvent)event;

- (void)play:(NSString *_Nullable)context;

- (void)pause:(NSString *_Nullable)context;

- (void)scanForwards:(NSString *_Nullable)context;

- (void)scanBackwards:(NSString *_Nullable)context;

- (void)stagePrevious:(NSString *_Nullable)context;

- (void)stageNext:(NSString *_Nullable)context;

- (void)archive:(NSString *_Nullable)context;

@end

NS_ASSUME_NONNULL_END
