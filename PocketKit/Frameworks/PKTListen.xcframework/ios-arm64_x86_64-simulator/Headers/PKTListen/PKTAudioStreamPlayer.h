//
//  PKTAudioStreamPlayer.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenPlayer.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTAudioStreamPlayer;
@class PKTAudioStream;

@interface PKTAudioStreamPlayer : AVPlayer <PKTListenPlayer>

- (instancetype)initWithConfiguration:(id<PKTListenPlayerConfiguration>)configuration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
