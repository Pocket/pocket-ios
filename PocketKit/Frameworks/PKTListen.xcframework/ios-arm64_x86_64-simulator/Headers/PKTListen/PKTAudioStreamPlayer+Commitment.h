//
//  PKTAudioStreamPlayer+Commitment.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/5/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTAudioStreamPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTAudioStreamPlayer (Commitment)

@property (nonatomic, readonly, assign) BOOL didCommitToPlayback;
@property (nonatomic, readonly, strong, nullable) NSTimer *commitment;

- (void)resetCommitment;

- (void)invalidateCommitment;

- (void)restartCommitment;

@end

NS_ASSUME_NONNULL_END
