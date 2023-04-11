//
//  PKTDrawerHostViewController.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/4/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@class PKTDrawerHostViewController;

typedef NSArray<NSLayoutConstraint*> *_Nonnull (^PKTDrawerContentLayout)(PKTDrawerHostViewController *_Nonnull host,
                                                                           UIView *_Nonnull view);

typedef void (^PKTDrawerContainerGuide)(PKTDrawerHostViewController *_Nonnull host, UILayoutGuide *_Nonnull guide);

typedef id<UITimingCurveProvider> _Nonnull (^PKTDrawerAnimatedCancellation)(CGFloat progress,
                                                                            CGVector velocity,
                                                                            NSTimeInterval *durationFactor);

#pragma mark - PKTDrawerHandleView

@interface PKTDrawerHandleView : UIView

@end

#pragma mark - PKTListenHostViewController

/**
 PKTDrawerHostViewController is a host view controller that presents itself as a full screen context view with a
 "handle" UI element that can be used to interactively dismiss the view controller by dragging it down towards the
 bottom of the screen. When the drawer has been dragged down >= 50% of it's width, it will be dismissed. If the drag
 event is cancelled before cross this threshold, the drawer will animate back to its open position.
 */

@interface PKTDrawerHostViewController : UIViewController <UIViewControllerTransitioningDelegate>

/**
 @return the UIView representing the drawer's handle.
 @note Drag events are handled by the draggingView, the handle view is purely decorative. */

@property (nonnull, nonatomic, readonly, strong) PKTDrawerHandleView *handle;

/**
 @return The view that describes the handle's touch area.
 */

@property (nonnull, nonatomic, readonly, strong) UIView *dragging;

/**
 @return UILayoutGuide restricted to the content area of the drawer.
 @note The content area describes the area that does not intersect the drawer's handle and dragging view.
 */

@property (nonnull, nonatomic, readonly, strong) UILayoutGuide *contentGuide;

/**
 @return UILayoutGuide restricted to the host area of the drawer.
 @note The content area describes the entire drawer area, and intersects with the drawer handle and dragging view.
 @note The content view controller provided during intialization will be laid out within this guide.
 */

@property (nonnull, nonatomic, readwrite, strong) UILayoutGuide *containerGuide;

/**
 The pan gesture recognizer used to interactively dismiss the view controller.
 */

@property (nullable, nonatomic, readonly, strong) UIPanGestureRecognizer *panGestureRecognizer;

/**
 The tap gesture recognizer used to dismiss the drawer by tapping in the area outside of the content view.
 @note By default, the gesture recognizer's delegate is the view controller itself.
 */

@property (nonnull, nonatomic, readonly, strong) UITapGestureRecognizer *tapToDismiss;

/**
 @return The view controller used to present content within the drawer.
 */
@property (nonnull, nonatomic, readonly, strong) UIViewController *contentViewController;

/**
 Creates a new host view that will present itself as a vertical drawer with a handle by which the view may be dismissed.
 @param viewController The view controller that should be presented within the drawer. By default, this view controller
 will fill the drawer
 @param container An optional block to control the dimensions of the drawer's container view
 @param content An optional block to control layout of the provided view controller within container
 @note The PKTDrawerGuide block will be called before any views or guides have been assigned.
 @note The PKTDrawerLayout block will be called after all other views and guides have been assigned and configured.
 */

- (instancetype)initWithContentViewController:(nonnull UIViewController *)viewController
                                    container:(nullable PKTDrawerContainerGuide)container
                                      content:(nullable PKTDrawerContentLayout)content
                                     animator:(nullable UIViewPropertyAnimator *)animator;

- (instancetype)initWithContentViewController:(nonnull UIViewController *)viewController
                                    container:(nullable PKTDrawerContainerGuide)container
                                      content:(nullable PKTDrawerContentLayout)content
                                     animator:(nullable UIViewPropertyAnimator *)animator
                                 cancellation:(nullable PKTDrawerAnimatedCancellation)cancellation;

/**
 Dismiss the drawer, ignoring the interactive transition state.
 @note: This is a hack – the animator is retaining state from previous interactions, which causes a timing error with
 dismissal via normal methods. Calling this method uses a one-off animator which is free from this state.
 @note The duration parameter is only used if the animated parameter is NO.*/

- (void)dismissDrawerAnimated:(BOOL)animated duration:(NSTimeInterval)duration completion:( void (^ _Nullable )(void))completion;
/**
 @note Use this method to control the dimensions of the drawer by configuring its layout guide
 @note This method is used if a nil PKTDrawerGuide block is provided during initialization for the container guide
 configuration block. Subclasses can override to provide a new default configuration for this guide.
 @note This method is called during viewDidLoad before any views or other guides have been assigned.
 */

- (void)containerViewLayout:(nonnull PKTDrawerHostViewController *)host guide:(nonnull UILayoutGuide *)guide;

/**
 @return NSArray<NSLayoutConstraint*> providing the default layout constraints for the drawer's content view.
 @note Use this block to control the position of the content view controller within the drawer.
 @note These constraints are used if a nil PKTDrawerLayout block is provided during initialization for the content
 layout block. Subclasses can override to provide a new default layout.
 @note This method is called during viewDidLoad before after all views and guides have been assigned and configured.
 */

- (nonnull NSArray<NSLayoutConstraint*>*)contentViewLayout:(nonnull PKTDrawerHostViewController *)host
                                                      view:(nonnull UIView *)view;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
