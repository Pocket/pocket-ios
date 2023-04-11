//
//  PKTSpeechUnit.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 11/26/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTHTMLParser.h"
#import "PKTListenItem.h"
#import "PKTListenPlayer.h"

/**
 PKTSpeechUnit is a model object representing a unit of speech.
 */

NS_ASSUME_NONNULL_BEGIN

@class AVSpeechUtterance;

@interface PKTSpeechUnit : NSObject <PKTListDiffable> {
    // Backing speech utterance
@public AVSpeechUtterance *_utterance;
}

/// The rate at which the unit will be spoken
@property (nonatomic, readonly, assign) double rate;
/// @return The text unit describing the text that this speech unit represents the spoken variation of
@property (nonatomic, readonly, strong, nonnull) PKTTextUnit *text;
/// @return The backing speech utterance that will be processed by the synthesizer
@property (nonatomic, readonly, strong, nonnull) AVSpeechUtterance *utterance;
/// @return A copy of the speech unit with the provided rate applied.
@property (nonatomic, readonly, strong, nonnull) PKTSpeechUnit *_Nonnull (^withRate)(double rate);

+ (instancetype)withTextUnit:(PKTTextUnit *_Nonnull)text rate:(double)rate;

@end

NS_ASSUME_NONNULL_END
