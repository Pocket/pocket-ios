//
//  PKTListenContainerViewController.h
//  Listen
//
//  Created by David Skuza on 11/14/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKTDrawerAnimatedTransitioningDelegate.h"
#import "PKTListenAudibleItemQueue.h"
#import "PKTListenDataSource.h"

NS_ASSUME_NONNULL_BEGIN

// A constant defining an action to perform if the container state is empty
UIKIT_EXTERN NSString * const PKTListenContainerStateEmptyAction;
// A constant defining an action to perform if the container state becomes empty
UIKIT_EXTERN NSString * const PKTListenContainerStateDidEmptyAction;

@protocol PKTListenFeedSource;
@protocol PKTDrawerDismissalDelegate;
@protocol PKTListenConfiguration;

typedef NS_ENUM(NSInteger, PKTListenContainerState) {
    PKTListenContainerStateEmpty,
    PKTListenContainerStateLoaded
};

@interface PKTListenContainerViewController : UIViewController <PKTDrawerDismissalDelegate>

@property (nonatomic, readonly) PKTListenContainerState state;

- (instancetype)initWithConfiguration:(id<PKTListenConfiguration>)configuration NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

@end

@protocol PKTListenContainerViewPresentationDelegate
- (void)dismissedByContainer:(PKTListenContainerViewController *)container;
- (void)presentedByContainer:(PKTListenContainerViewController *)container;
@end

NS_ASSUME_NONNULL_END
