//
//  PKTListenItemPlayer.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 1/18/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import Foundation;
@import AVFoundation;

#import "PKTListenPlaybackState.h"
#import "PKTAudibleQueue.h"

@class PKTAudioStream;
@class PKTAudioStreamPlayer;

@protocol PKTAudibleItemCache;
@protocol PKTAudioStreamPlayerDelegate;
@protocol PKTListenStore;

NS_ASSUME_NONNULL_BEGIN

/**
 PKTListenPlayerConfiguration describes the configuration of an audio playback system.
 */

@protocol PKTListenPlayerConfiguration <NSObject>

@property (nonatomic, readonly, strong, nonnull) id<PKTAudibleItemCache> cache;
@property (nonatomic, readonly, strong, nonnull) id<PKTListenStore> store;

@end

/**
 PKTListenPlayer describes the interface for a generic audio playback system.
 */

@protocol PKTListenPlayer <NSObject>

/// @return the configuration of the player, as provided during instantiation.
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerConfiguration> configuration;

/// @return an observable state object describing the state of the audio playback system
@property (atomic, readonly, strong, nonnull) id<PKTListenPlayerState> state;

/// @return the listen item currently staged in the player for playback
@property (nullable, nonatomic, readwrite, strong) PKTKusari<id<PKTListenItem>> *kusari;

/// an optional delegate for the playback system that will receive updates of player state transitions
@property (nullable, nonatomic, readwrite, weak) id<PKTAudioStreamPlayerDelegate> delegate;

/// integer value representation of playback rate * 10.
@property (nonatomic, readwrite, assign) NSInteger speedFactor;

- (instancetype)initWithConfiguration:(id<PKTListenPlayerConfiguration>)configuration;

- (void)play;

- (void)pause;

- (void)stop;

- (void)destroy;

// Seek forwards in current listen item by some arbitrary, fixed value
- (void)jumpForward;

// Seek backwards in current listen item by some arbitrary, fixed value
- (void)jumpBackward;

@optional

- (void)seekToPosition:(CGFloat)position completion:(void(^)(BOOL finished))completion;

- (void)seekToTime:(CMTime)time;

@end

@protocol PKTAudioStreamPlayerDelegate <NSObject>

/// messaged when the playback system has loaded an item's metadata
/// @note will be sent before playbackIsReadyToPlay
- (void)player:(id<PKTListenPlayer>)player playbackDidLoad:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messages when the playback system has become capable of playing back the loading listen item
- (void)player:(id<PKTListenPlayer>)player playbackIsReadyToPlay:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messaged when the playback system begins playback of the staged listen item
- (void)player:(id<PKTListenPlayer>)player playbackDidPlay:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messaged when the playback system is paused
- (void)player:(id<PKTListenPlayer>)player playbackDidPause:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messaged when playback stalls (e.g., for a streaming player, the playback position exceeds the playback buffer)
- (void)player:(id<PKTListenPlayer>)player playbackDidStall:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messaged when the playback system has played an item to its end
- (void)player:(id<PKTListenPlayer>)player playbackDidFinish:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messaged when the playback system fails to play an item, for any reason
- (void)player:(id<PKTListenPlayer>)player playbackDidFail:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messaged when the player has played an item without interruption for a sufficient amount of time to represent user engagement
- (void)player:(id<PKTListenPlayer>)player playbackDidCommitToPlayback:(PKTKusari<id<PKTListenItem>> *)kusari;
/// messages when playback has been cancelled
- (void)player:(id<PKTListenPlayer>)player playbackDidCancel:(PKTKusari<id<PKTListenItem>> *)kusari;
/// message when the playback system has updated its internal state
/// @note the delegate can use this method to update UI for state such as playback position
- (void)player:(id<PKTListenPlayer>)player playbackDidUpdate:(PKTKusari<id<PKTListenItem>> *)kusari;

@end

NS_ASSUME_NONNULL_END
