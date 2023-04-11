//
//  UIGestureRecognizer+PKTAdditions.h
//  RIL
//
//  Created by Nicholas Zeltzer on 7/11/17.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^PKTGestureRecognizerAction)(UIGestureRecognizer *recognizer, UIGestureRecognizerState state);

@interface UIGestureRecognizer (PKTAdditions)

@property (nullable, nonatomic, readonly, copy) PKTGestureRecognizerAction action;

- (instancetype)initWithAction:(PKTGestureRecognizerAction)action;

- (void)cancel;

@end

NS_ASSUME_NONNULL_END
