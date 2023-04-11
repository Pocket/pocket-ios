//
//  Action+ScreenSize.h
//  PKTRuntime
//
//  Created by David Skuza on 12/26/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "Action.h"

UIKIT_EXTERN NSString *const PKTLastKnownScreenSizeActionKey;

@interface Action (ScreenSize)

/**
 The action to send for the current screen size, or nil if no new action has to be sent.
 
 @return If the current screen size has not yet been sent, an action will be returned.
 @return If the current screen size has already been sent, nil will be returned.
 @return If the current screen size has been changed, but the session is the same, nil will be returned.
 @return If the current screen size has been changed, and the session is different, an action will be returned.
 */
+ (instancetype)actionForCurrentScreenSize;

@end
