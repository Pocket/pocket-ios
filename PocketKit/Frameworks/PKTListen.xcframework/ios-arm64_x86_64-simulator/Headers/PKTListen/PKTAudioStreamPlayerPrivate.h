//
//  PKTAudioStreamPlayerPrivate.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/5/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#ifndef PKTAudioStreamPlayerPrivate_h
#define PKTAudioStreamPlayerPrivate_h

@import AVFoundation;

#import "PKTListen.h"
#import "PKTAudioStreamPlayer.h"
#import "PKTListenAudibleItemQueuePrivate.h"
#import "PKTAudioStreamPlayer+Seeking.h"
#import "PKTAudioStreamPlayer+PKTAudioStreamDelegate.h"
#import "PKTAudioStreamPlayer+Tracking.h"
#import "PKTAudioStreamPlayer+Commitment.h"

#if PKTAudioStreamPlayerLoggingEnabled
#define PKTAudioStreamPlayerLog(...) PKTLog(PKTLogZoneDynamic, LISTEN_CONTEXT, LOG_FLAG_INFO, __VA_ARGS__)
#else
#define PKTAudioStreamPlayerLog(...) PKTLog(PKTLogZoneDisk, LISTEN_CONTEXT, LOG_FLAG_INFO, __VA_ARGS__)
#endif

@interface PKTAudioStreamPlayer() {
    BOOL _isDestroyed;
}

@property (atomic, readwrite, strong, nonnull) id<PKTListenPlaybackStateUpdate> state;
@property (atomic, readonly, strong, nullable) PKTAudioStream *stream;
@property (nullable, nonatomic, readwrite, strong) id<NSObject> timeDidUpdate;
@property (nullable, nonatomic, readwrite, strong) id<NSObject> audioSessionWasInterrupted;
@property (nullable, nonatomic, readwrite, strong) id<NSObject> audioSessionRouteChanged;

- (void)resumePlayback;
- (void)stopPlayback;

@end

#endif /* PKTAudioStreamPlayerPrivate_h */
