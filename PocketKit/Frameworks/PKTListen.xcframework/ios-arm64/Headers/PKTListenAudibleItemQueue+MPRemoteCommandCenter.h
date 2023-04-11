//
//  PKTAudibleItemQueue+MPRemoteCommandCenter.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenAudibleItemQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAudibleItemQueue (MPRemoteCommandCenter)

/// Publish listen item metadata in the media center.
/// @note this method populates the static properties of the item (e.g., title, thumbnail, etc.). To update dynamic
/// properties (e.g., time, progress, playback state, etc.), use the updatePublication:state: method.

- (void)publishKusari:(PKTKusari<id<PKTListenItem>>*)kusari;

/// Publish listen item metadata in the media center.
/// @note this method populates the dynamic properties of the item (e.g., progress, playback state, etc.). To update
/// static properties (e.g., album art, title, etc.), use the publishKusari: method.

- (void)updatePublication:(PKTKusari<id<PKTListenItem>> *)kusari;

/// Dctivate media center support.
/// @note should be called when first setting up the listen experience

- (void)startMediaCenter;

/// Deactivate media center support.
/// @note should be called when tearing down the listen experience

- (void)stopMediaCenter;

@end

NS_ASSUME_NONNULL_END
