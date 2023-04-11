//
//  PKTAudioStreamPlayer+Seeking.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/5/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTAudioStreamPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTAudioStreamPlayer (Seeking)

@property (atomic, readonly, assign, getter=isSeeking) BOOL seeking;

- (void)seekToPosition:(CGFloat)position completion:(void(^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
