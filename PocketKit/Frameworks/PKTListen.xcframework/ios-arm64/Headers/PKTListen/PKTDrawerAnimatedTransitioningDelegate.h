//
//  PKTDrawerAnimatedTransitioningDelegate.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/4/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol PKTDrawerDismissalDelegate <NSObject>

- (void)drawerDidDismiss:(UIViewController *)drawer;

@end

typedef NS_ENUM(NSInteger, PKTDrawerTransition) {
    PKTDrawerTransitionUndefined = 0,
    PKTDrawerTransitionPush,
    PKTDrawerTransitionPop,
    // PKTDrawerTransitionCollapseToPlayer
};

#pragma mark - PKTListenDrawerAnimator

@interface PKTListenDrawerAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, readonly, assign) PKTDrawerTransition transitionType;

+ (instancetype)push:(UIViewPropertyAnimator *_Nullable)animator;

+ (instancetype)pop:(UIViewPropertyAnimator *_Nullable)animator;

+ (NSTimeInterval)transitionDurationForRect:(CGRect)rect;

@end

#pragma mark - PKTListDrawerInteractiveTransition

typedef id<UITimingCurveProvider> _Nonnull (^PKTDrawerCancellationTiming)(CGFloat progress,
                                                                        CGVector velocity,
                                                                        NSTimeInterval *proposedTimingFactor);

@interface PKTListDrawerInteractiveTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, readonly, assign) UIGestureRecognizerState state;
@property (nullable, nonatomic, readwrite, weak) id<UIGestureRecognizerDelegate> gestureRecognizerDelegate;

- (instancetype)initWithViewController:(UIViewController *_Nonnull)viewController
                                handle:(UIView *_Nullable)handle
                              animator:(UIViewPropertyAnimator *_Nullable)animator
                          cancellation:(PKTDrawerCancellationTiming)cancellation;

- (void)remove;

@end

#pragma mark - PKTDrawerAnimatedTransitioningDelegate

@interface PKTDrawerAnimatedTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@property (nullable, nonatomic, readwrite, weak) UIView *handle;
@property (nullable, nonatomic, readonly, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonnull, nonatomic, readonly, strong) UIViewPropertyAnimator *animator;
@property (nonnull, nonatomic, readonly, copy) PKTDrawerCancellationTiming cancellation;
@property (nullable, nonatomic, readwrite, weak) id<UIGestureRecognizerDelegate> gestureRecognizerDelegate;
@property (nullable, nonatomic, readwrite, weak) id<PKTDrawerDismissalDelegate> dismissalDelegate;

+ (instancetype)drawer:(UIViewController *_Nonnull)viewController
              animator:(UIViewPropertyAnimator *_Nullable)animator
          cancellation:(PKTDrawerCancellationTiming)cancellation;

/**
 Dismiss the drawer non-interactively.
 */

- (void)dismiss:(BOOL)animated duration:(NSTimeInterval)duration completion:( void (^ _Nullable )(void))completion;

@end

#pragma mark - PKTDrawerBackgroundVendor

/**
 <PKTDrawerBackgroundVendor> describes a protocol that either one (but, please not both!) of the view controllers
 involved in drawer presentation can adopt to vend a background view that will be placed behind the drawer during
 animated presentation and dismissal. The view will be faded up from 0.0f to 1.0f alpha during presentation and
 in the opposite direction during dismissal. The vendor must return the same view from this method on each call. */

@protocol PKTDrawerBackgroundVendor <NSObject>

- (UIView *_Nullable)drawerBackgroundView;

@end


NS_ASSUME_NONNULL_END
