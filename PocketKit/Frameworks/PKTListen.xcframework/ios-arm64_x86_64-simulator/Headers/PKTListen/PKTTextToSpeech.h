//
//  PKTTextToSpeech.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 1/30/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import Foundation;

#import "PKTListenPlayer.h"
#import "PKTListenItem.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTSpeechUnit;

#pragma mark - PKTTextToSpeech

/**
 PKTTextToSpeech is a speech synthesizer capable of emitting a synthesized representation of listen item.
 */

@interface PKTTextToSpeech : NSObject <PKTListenPlayer>

@property (nonatomic, readwrite, strong, nullable) PKTKusari<id<PKTListenItem>> *kusari;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

/// @return a new PKTTextToSpeech object configured in accordance with the provided configuration.
- (instancetype)initWithConfiguration:(id<PKTListenPlayerConfiguration>)configuration NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
