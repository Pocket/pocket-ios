//
//  PKTListenSettings.h
//  Listen
//
//  Created by David Skuza on 2/7/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A persistent data structure representing the available Listen settings for a user.
 By default, these settings are not persisted across application launches.
 */
@interface PKTListenSettings : NSObject <NSCopying, NSCoding>

/**
 Represents whether or not Listen should always use offline TTS.
 */
@property (nonatomic, readonly) BOOL alwaysUseOffline;

/**
 Represents the identifier of the voice Listen should use for offline TTS.
 */
@property (nonatomic, readonly, nullable) NSString *selectedVoiceIdentifier;

/**
 Returns a copy of the current user settings with an updated 'alwaysUseOffline' value, if applicable.
 */
@property (nonatomic, readonly, copy) PKTListenSettings * (^updateAlwaysUseOffline)(BOOL);

/**
 Returns a copy of the current user settings with an updated 'selectedVoiceIdentifier' value, if applicable.
 */
@property (nonatomic, readonly, copy) PKTListenSettings * (^updateSelectedVoiceIdentifier)(NSString *);

/**
 Returns an array of strings representing the selectors of properties that differ between the
 current and input settings. For example, comparing against a setting with a different 'alwaysUseOffline'
 value will return an array containing an object matching NSStringFromSelector(@selector(alwaysUseOffline)).
 */
@property (nonatomic, readonly, copy) NSArray<NSString *> * (^delta)(PKTListenSettings *);

@end

NS_ASSUME_NONNULL_END
