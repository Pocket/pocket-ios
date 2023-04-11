//
//  PKTListenSettingsVoiceSelectionSection.h
//  Listen
//
//  Created by David Skuza on 2/8/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PKTListenSettingCell.h"

#import "IGListKit/IGListKit.h"

@protocol PKTListenStore;

NS_ASSUME_NONNULL_BEGIN

/**
 Defines the sections for a settings screen allowing a user to select a voice for speech synthesis.
 */
@interface PKTListenSettingsVoiceSelectionSection : IGListBindingSectionController <IGListBindingSectionControllerDataSource>

- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a new section with a store.

 @param store An object conforming to PKTListenStore that is used to return user settings.
 @return A new PKTListenSettingsVoiceSelectionSection used with PKTListenSettingsViewController.
 */
- (instancetype)initWithStore:(id<PKTListenStore>)store NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
