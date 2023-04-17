//
//  AVSpeechSynthesisVoice+Listen.h
//  Listen
//
//  Created by David Skuza on 2/8/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import AVFoundation;

NS_ASSUME_NONNULL_BEGIN

/**
 An AVSpeechSynthesisVoice caterogy that contains helper methods for tasks related to Listen settings.
 */
@interface AVSpeechSynthesisVoice (Listen)

/**
 @return An array of all available system voices sorted alphabetically (ascending).
 */
+ (NSArray<AVSpeechSynthesisVoice *> *)sortedVoices;

/**
 The first voice matching the user's current system language after being sorted alphabetically (ascending).
 @return An AVSpeechSynthesisVoice for the user's current language.
 */
+ (AVSpeechSynthesisVoice *)firstVoiceForCurrentLanguage;

@end

NS_ASSUME_NONNULL_END
