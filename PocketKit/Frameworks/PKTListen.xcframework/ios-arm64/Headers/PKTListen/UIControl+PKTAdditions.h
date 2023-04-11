//
//  UIControl+PKTAdditions.h
//  RIL
//
//  Created by Nik Zeltzer on 9/30/16.
//
//

#import <UIKit/UIKit.h>

@interface UIControl (PKTAdditions)

/**
 Registers an action block with a given UIControlEvents mask.
 @param events UIControlEvents mask that should trigger this action.
 @param action The callback block that will be triggered when the UIControlEvents is realized.
 @notes You can add multiple action blocks for the same events, and the same events to multiple actions, just like the core API. Additionally, use of this method will _not_ break the stock behavior: you can use both blocks and target/action pairs on the same UIButton instance, without breaking the behavior of either.
 */

- (void)PKTAddEvent:(UIControlEvents)events
             action:(nonnull void(^)(UIControl *__nonnull control, UIControlEvents events))action;

/**
 Removes all action blocks for a given UIControlEvents mask.
 @param events UIControlEvents mask from which all actions should be removed.
 */
- (void)PKTRemoveEvent:(UIControlEvents)events;

/**
 Alternative API for method, supra.
 */

- (void)forControlEvents:(UIControlEvents)events
               addAction:(nonnull void(^)(UIControl *__nonnull control, UIControlEvents events))action;


@end
