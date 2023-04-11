//
//  PKTListenCoverFlowViewController.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/10/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTAudibleQueue.h"
#import "PKTListenItem.h"
#import "PKTListenAudibleQueuePresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTListenCoverFlowViewController;

@protocol PKTListenCoverFlowViewControllerScrollViewDelegate <NSObject>

- (void)coverFlowViewController:(PKTListenCoverFlowViewController *)viewController
    scrollViewWillBeginDragging:(UIScrollView *)scrollView;

@end

@interface PKTListenCoverFlowViewController : UIViewController <PKTListenAudibleQueuePresentationContext>

@property (nonatomic, readonly, strong, nullable) id<PKTAudibleQueue> audibleQueue;
@property (nonnull, nonatomic, readonly, strong) UICollectionView *collectionView;
@property (nonatomic, readwrite, assign) CGFloat compression;
@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property (nonnull, nonatomic, readwrite, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, readwrite, weak, nullable) id<PKTListenCoverFlowViewControllerScrollViewDelegate> scrollViewDelegate;

- (nonnull instancetype)initWithQueue:(nonnull id<PKTAudibleQueue>)audibleQueue NS_DESIGNATED_INITIALIZER;

- (void)scrollToKusari:(PKTKusari<id<PKTListenItem>>*)kusari animated:(BOOL)animated;

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (PKTKusari<id<PKTListenItem>> *_Nullable)kusariAtIndexPath:(NSIndexPath *_Nullable)indexPath;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
