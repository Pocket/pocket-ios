//
//  PKTListenPlaybackState.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 1/31/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import AVFoundation;
@import MediaPlayer;

#import "Reachability.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTAudibleLoadingState) {
    PKTAudibleLoadingStateInactive,
    PKTAudibleLoadingStateActive,
};

typedef NS_OPTIONS(NSInteger, PKTAudibleQueuingState) {
    PKTAudibleQueuingStateNotQueuing,
    PKTAudibleQueuingStateQueuing,
};

typedef NS_ENUM(NSInteger, PKTListenPlaybackType) {
    PKTListenPlaybackTypeUnavailable                  = 0,
    PKTListenPlaybackTypeOfflineTTS,
    PKTListenPlaybackTypeOnlineStream,
    PKTListenPlaybackTypeOfflineStream,
};

/**
 PKTListenPlaybackStateState is a persistent data structure representing the state of the playback system. As it is persistent,
 it is immutable, which makes it safe for use across threads.
 */

@protocol PKTListenPlayerState <NSObject>

/// @return CMTime representation of the currrently staged item's playback position between 0 and N.
/// @note will be zero for synthesized items
@property (nonatomic, readonly, assign) CMTime currentTime;
/// @return CMTime representation of the duration of the staged listen item
/// @note will be zero for synthesized items
@property (nonatomic, readonly, assign) CMTime duration;
/// @return download progress of the item as represented as value between 0.0f and 1.0f
/// @note may be zero for synthesized items
@property (nonatomic, readonly, assign) CGFloat downloadProgress;
/// @return playback progress of the item as represented as value between 0.0f and 1.0f
@property (nonatomic, readonly, assign) CGFloat playbackProgress;
/// @return PKTAudibleLoadingState representation of loading state
/// @note represents whether or not the playback system is attempting to load the listen item for playback
@property (nonatomic, readonly, assign) PKTAudibleLoadingState loadingState;
/// @return MPMusicPlaybackState representation of playback state
@property (nonatomic, readonly, assign) MPMusicPlaybackState playbackState;
/// @return AVPlayerTimeControlStatus representation of playback state
@property (nonatomic, readonly, assign) AVPlayerTimeControlStatus timeControlStatus;
/// @return YES, if the player is playing, or attempting to play; NO, if the player has been intentionally paused
/// @note this value reflects the system's playback _intent_, as opposed to its actual state
/// @note the YES state maps directly with a playback UI in a play state; NO, with the UI in a pause state.
@property (nonatomic, readonly, assign) BOOL wantsToPlay;
/// @return rate of playback
/// @note clamped value somewhere between 0.8 and 4.0
@property (nonatomic, readonly, assign) float rate;
/// @return the unplayed time remaining of the item staged for playback
/// @note may be zero, where the item's stream metadata hasn't been loaded, or is synthesized
@property (nonatomic, readonly, assign) CMTime remainingTime;
/// @return NSInteger representation of the rate of playback multiplied by 10
@property (nonatomic, readwrite, assign) NSInteger speedFactor;

@property (nonatomic, readonly, strong, nonnull) NSDictionary <NSString*, id<NSObject>> *dictionaryRepresentation;
@property (nonatomic, readonly, strong, nonnull) NSArray<NSString*> * (^delta)(id<PKTListenPlayerState> state);
@property (nonatomic, readonly, strong, nonnull) BOOL (^includesChange)(id<PKTListenPlayerState> state, SEL aSelector);

@end

@protocol PKTListenPlaybackState <PKTListenPlayerState>

/// @return the network connection type as perceived by the playback system
@property (nonatomic, readonly, assign) PKTNetworkConnectionType connection;
/// @return The available playback type for the current item
@property (nonatomic, readonly, assign) PKTListenPlaybackType playbackType;
/// @return PKTAudibleQueingState representation of queue state
/// @note the queuing state is used to signal when playback system is attempting to stage an item for playback. The
/// queueing process involves intentionally delaying playback of items in order to provide the user an opportunity to
/// interact with the system in between playback of consecutive items
@property (nonatomic, readonly, assign) PKTAudibleQueuingState queuingState;

@property (nonatomic, readonly, strong, nonnull) NSArray<NSString*> * (^delta)(id<PKTListenPlaybackState> state);
@property (nonatomic, readonly, strong, nonnull) BOOL (^includesChange)(id<PKTListenPlaybackState> state, SEL aSelector);


@end

@interface PKTListenPlaybackState : NSObject <PKTListenPlaybackState, NSCopying>

@end

@protocol PKTListenPlayerStateUpdate;

@protocol PKTListenPlayerStateUpdate <PKTListenPlayerState>

@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateCurrentTime)(CMTime);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateDuration)(CMTime);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateDownloadProgress)(CGFloat);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updatePlaybackProgress)(CGFloat);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateLoadingState)(PKTAudibleLoadingState);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updatePlaybackState)(MPMusicPlaybackState);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateTimeControlStatus)(AVPlayerTimeControlStatus);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateWantsToPlay)(BOOL);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateRemainingTime)(CMTime time);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updateSpeedFactor)(NSInteger factor);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlayerStateUpdate> (^updatePlaybackRate)(float);

@end

/**
 <PKTListenPlaybackStateUpdate> declares an API for creating an updated copy of the receiver, with the named change
 applied to the copy's state.
 */

@protocol PKTListenPlaybackStateUpdate;

@protocol PKTListenPlaybackStateUpdate <PKTListenPlaybackState, PKTListenPlayerStateUpdate>

@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateQueuingState)(PKTAudibleQueuingState state);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateConnectionType)(PKTNetworkConnectionType type);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updatePlaybackType)(PKTListenPlaybackType type);

#pragma <PKTListenPlayerStateUpdate>

@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateCurrentTime)(CMTime);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateDuration)(CMTime);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateDownloadProgress)(CGFloat);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updatePlaybackProgress)(CGFloat);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateLoadingState)(PKTAudibleLoadingState);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updatePlaybackState)(MPMusicPlaybackState);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateTimeControlStatus)(AVPlayerTimeControlStatus);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateWantsToPlay)(BOOL);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateRemainingTime)(CMTime time);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updateSpeedFactor)(NSInteger factor);
@property (nonatomic, readonly, strong, nonnull) id<PKTListenPlaybackStateUpdate> (^updatePlaybackRate)(float);

@end

NS_ASSUME_NONNULL_END
