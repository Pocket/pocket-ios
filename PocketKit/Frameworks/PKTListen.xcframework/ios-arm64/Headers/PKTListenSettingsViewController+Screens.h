//
//  PKTListenSettingsViewController+Screens.h
//  PKTListen
//
//  Created by David Skuza on 2/10/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import "PKTListenSettingsViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A PKTListenSettingsViewController category to include class-level helper functions
 for returning a view controller for settings of a certain type.
 */
@interface PKTListenSettingsViewController (Screens)

/**
 @return A PKTListenSettingsViewController that is the "main" settings screen, containing all top-level settings.
 */
+ (instancetype)defaultController;

/**
 @return A PKTListenSettingsViewController that allows for selection of a new voice for speech synthesis.
 */
+ (instancetype)controllerForVoiceSelection;

@end

NS_ASSUME_NONNULL_END
