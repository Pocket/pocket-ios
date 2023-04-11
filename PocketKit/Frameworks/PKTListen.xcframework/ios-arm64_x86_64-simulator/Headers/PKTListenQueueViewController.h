//
//  PKTListenQueueViewController.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/5/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTListenItem.h"
#import "PKTListenAudibleQueuePresentationContext.h"
#import "PKTDrawerAnimatedTransitioningDelegate.h"
#import "PKTListenDataSource.h"
#import "PKTListenContainerViewController.h"

@class PKTListenSpeedControl;
@class PKTListenPlayerViewController;
@class PKTDrawerHostViewController;

@protocol PKTAudibleQueue;

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenQueueViewController : UIViewController

@property (nonnull, nonatomic, readonly, strong) UICollectionView *collectionView;
@property (nonnull, nonatomic, readonly, strong) PKTListenPlayerViewController *player;
@property (nonnull, nonatomic, readonly, strong) PKTListenSpeedControl *speed;
@property (nonatomic, readonly, strong, nullable) id<PKTAudibleQueue> audibleQueue;
@property (nonatomic, readwrite, assign, class) BOOL controlExpansionEnabled;
@property (nullable, nonatomic, readonly, strong) NSDictionary<NSString*, id> *context;
@property (nonnull, nonatomic, readonly) NSArray<PKTKusari<id<PKTListenItem>>*> *visibleKusari;
@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

- (instancetype)initWithAudibleQueue:(id<PKTAudibleQueue>)audibleQueue;

- (void)updateAppearance;

- (PKTDrawerHostViewController *_Nullable)host;

@end

@interface PKTListenQueueViewController (PKTListenContainerViewPresentationDelegate) <PKTListenContainerViewPresentationDelegate>

@end

NS_ASSUME_NONNULL_END
