//
//  PKTAudioStream+PKTSeeking.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 10/10/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTAudioStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTAudioStream (PKTSeeking)

- (CMTime)timeForPosition:(CGFloat)position;

- (BOOL)timeAvailable:(CMTime)time;

- (BOOL)positionAvailable:(CGFloat)position;

- (void)seekToPosition:(CGFloat)position completion:(void(^)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
