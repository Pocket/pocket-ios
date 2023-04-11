//
//  PKTListenPlayerViewController.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/10/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;
#import "PKTAudibleQueue.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTListenPlayerView;
@class PKTListenCoverFlowViewController;

@interface PKTListenPlayerViewController : UIViewController

@property (nonatomic, readonly, strong, nonnull) id<PKTAudibleQueue> audibleQueue;
@property (nonatomic, readonly, strong, nullable) PKTListenCoverFlowViewController *coverflow;
@property (nonatomic, readonly, strong, nonnull) PKTListenPlayerView *player;
@property (nonatomic, readwrite, assign) CGFloat compression;
@property(nonatomic,getter=isUserInteractionEnabled) BOOL userInteractionEnabled; 

- (nonnull instancetype)initWithQueue:(nonnull id<PKTAudibleQueue>)audibleQueue NS_DESIGNATED_INITIALIZER;

- (void)scrollToKusari:(PKTKusari<id<PKTListenItem>>*)kusari animated:(BOOL)animated;

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated;

- (NSIndexPath *_Nullable)indexPathForKusari:(PKTKusari<id<PKTListenItem>> *)kusari;

- (PKTKusari<id<PKTListenItem>> *_Nullable)kusariForIndexPath:(NSIndexPath *)indexPath;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
