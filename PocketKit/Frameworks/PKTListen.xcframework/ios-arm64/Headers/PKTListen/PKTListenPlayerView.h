//
//  PKTListenPlayerView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/8/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTListenItem.h"
#import "PKTAudibleQueue.h"
#import "PKTListenAudibleQueuePresentationContext.h"

@class PKTListenPlaybackControlView;
@class PKTDrawerHandleView;

@interface PKTListenPlayerView : UIView <PKTListenAudibleQueuePresentationContext>

@property (nonatomic, readwrite, assign) CGFloat compression;
@property (nullable, nonatomic, readonly, strong) PKTKusari<id<PKTListenItem>> *kusari;
@property (nonnull, nonatomic, readonly, strong) PKTDrawerHandleView *divider;
@property (nonnull, nonatomic, readonly, strong) UISlider *playbackProgress;
@property (nonnull, nonatomic, readonly, strong) UIProgressView *downloadProgress;
@property (nonnull, nonatomic, readonly, strong) PKTListenPlaybackControlView *controls;
@property (nonnull, nonatomic, readwrite, strong) UIColor *titleColor UI_APPEARANCE_SELECTOR;
@property (nonnull, nonatomic, readwrite, strong) UIColor *detailColor UI_APPEARANCE_SELECTOR;
@property (nonnull, nonatomic, readwrite, strong) UIColor *timeColor UI_APPEARANCE_SELECTOR;

- (nonnull instancetype)initWithQueue:(nonnull id<PKTAudibleQueue>)audibleQueue NS_DESIGNATED_INITIALIZER;

- (void)updateAppearance;

- (void)destroy;

@end
