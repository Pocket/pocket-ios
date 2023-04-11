//
//  PKTListenQueueViewControllerPrivate.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/13/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#ifndef PKTListenQueueViewControllerPrivate_h
#define PKTListenQueueViewControllerPrivate_h

#import "PKTListenQueueViewController.h"
#import "PKTListenExperiencePlaceholderSection.h"
#import "PKTListenAudibleItemSection.h"
#import "PKTListenHeaderSection.h"
#import "PKTListenQueueCollectionViewLayout.h"
#import "PKTDrawerHostViewController.h"
#import "PKTListenPlayerViewController.h"
#import "PKTListenCoverflowViewController.h"
#import "PKTCoreLogging.h"
#import "PKTHandyMacros.h"
#import "PKTListenQueueViewController+UIScrollViewDelegate.h"
#import "PKTListenQueueViewController+PKTKusari.h"
#import "PKTListenQueueViewController+UIGestureRecognizerDelegate.h"
#import "PKTListenItemCollectionViewCell+PKTSizing.h"
#import "PKTListenMessageView.h"
#import "PKTListenQueueViewController+PKTListenAudibleQueuePresentationContext.h"

#import "IGListKit/IGListKit.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kPKTDefaultTintColorName = @"Gray 3";
static NSString * const kPKTCoverFlowQueueIdentifier = @"Cover Flow";
static NSString * const kPKTItemListQueueIdentifier = @"Audible Queue";

@class PKTListenAbstractMessageView;

#define PKTListenQueueViewControllerTimersEnabled 0
#define PKTListQueueViewControllerDebugColorsEnabled 0
#if PKTListQueueViewControllerDebugColorsEnabled
#define PKTListQueueColorAssign(...) PKTDebugColorAssign(__VA_ARGS__)
#else
#define PKTListQueueColorAssign(...) do { } while(0)
#endif

@interface PKTListenQueueViewController () <UICollectionViewDelegate, UIGestureRecognizerDelegate, PKTListenCoverFlowViewControllerScrollViewDelegate> {
@protected BOOL _isDestroyed;
@protected NSInteger _pingCount;
@protected PKTListenWarningMessageView *_warning;
@protected PKTListenAnnouncementMessageView *_announcement;
@protected PKTListenActionMessageView *_actionMessage;
@protected NSSet<NSLayoutConstraint*> *_constraintsNoNetworkVisible;
@protected NSSet<NSLayoutConstraint*> *_constraintsNoNetworkHidden;
}

@property (nonnull, nonatomic, readonly, strong) UICollectionViewFlowLayout *layout;
@property (nonnull, nonatomic, readonly, strong) IGListAdapterUpdater *updater;
@property (nonnull, nonatomic, readonly, strong) IGListAdapter *adapter;
@property (nullable, nonatomic, readonly, weak) PKTDrawerHostViewController *host;
@property (nonnull, nonatomic, readonly, strong) PKTListenExperiencePlaceholderSection *sectionCoverflow;
@property (nonnull, nonatomic, readonly, strong) NSLayoutConstraint *playerTop;
@property (nullable, nonatomic, readonly, strong) UITapGestureRecognizer *tappedHandle;
@property (nullable, nonatomic, readonly, strong) UITapGestureRecognizer *tappedAnywhere;
@property (nonatomic, readwrite, assign) CGPoint lastOffset;
@property (nonatomic, readwrite, assign) CGPoint playerOffset;
@property (nonatomic, readwrite, assign) CGFloat compression;
@property (nonatomic, readwrite, assign) BOOL playerIsLocked;
@property (nonnull, nonatomic, readonly, strong) UIGestureRecognizer *showPlayer;
@property (nonnull, nonatomic, readonly, strong) NSLayoutConstraint *topOfList;
@property (nonnull, nonatomic, readonly, strong) NSLayoutConstraint *topOfListAccessible;
@property (nonnull, nonatomic, readonly, strong) PKTListenWarningMessageView *warning;
@property (nonnull, nonatomic, readonly, strong) PKTListenAnnouncementMessageView *announcement;
@property (nonnull, nonatomic, readonly, strong) PKTListenActionMessageView *actionMessage;
@property (nonnull, nonatomic, readonly, strong) NSSet<NSLayoutConstraint*> *constraintsNoNetworkVisible;
@property (nonnull, nonatomic, readonly, strong) NSSet<NSLayoutConstraint*> *constraintsNoNetworkHidden;

@property (nonnull, nonatomic, readonly, strong) id<NSObject> contentSizeCategoryDidChange;

- (void)collapsePlayer;

- (CGPoint)compressedPlayerOffset;

@end

NS_ASSUME_NONNULL_END

#endif /* PKTListenQueueViewControllerPrivate_h */
