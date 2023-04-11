//
//  PKTAudioStreamPlayer+Tracking.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/5/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTAudioStreamPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTAudioStreamPlayer (Updates)

- (void)startTracking;

- (void)stopTracking;

@end

NS_ASSUME_NONNULL_END
