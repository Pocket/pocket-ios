//
//  PKTListenSettingViewModel+AVSpeechSynthesisVoice.h
//  PKTListen
//
//  Created by David Skuza on 2/10/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import "PKTListenSettingViewModel.h"

@class AVSpeechSynthesisVoice;
@class PKTListenSettings;

NS_ASSUME_NONNULL_BEGIN

/**
 A PKTListenSettingViewModel category that exposes helper functions for generating view models
 based on an AVSpeechSynthesisVoice. These view models can then be rendered by a PKTListenSettingCell.
 */
@interface PKTListenSettingViewModel (AVSpeechSynthesisVoice)

/**
 Generates a view model representing an AVSpeechSynthesisVoice.
 The view model's main text will be the voice name,
 and the detail text will be the voice locale.
 Based on settings, the view model will represent that the voice is selected, if applicable.

 @param voice The voice to generate a view model for.
 @param settings The user's settings, used for aiding in representing a selected voice.
 @return A PKTListenSettingViewModel to bind to a PKTListenSettingCell.
 */
+ (nullable instancetype)viewModelForVoice:(AVSpeechSynthesisVoice *)voice settings:(PKTListenSettings *)settings;

@end

NS_ASSUME_NONNULL_END
