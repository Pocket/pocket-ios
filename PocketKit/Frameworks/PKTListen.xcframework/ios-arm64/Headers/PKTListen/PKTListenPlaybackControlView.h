//
//  PKTListenPlaybackControlView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/7/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "Item+PKTListDiffable.h"
#import "PKTAudibleQueue.h"
#import "PKTListenAudibleQueuePresentationContext.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTListenPlaybackLoadingView;
@class PKTListenPlaybackControlView;

typedef NS_OPTIONS(NSInteger, PKTListenPlaybackControlViewState) {
    PKTListenPlaybackControlViewStateSkipping = 0,
    PKTListenPlaybackControlViewStateScanning = 1,
};

@interface PKTListenPlaybackControlView : UIView <PKTListenAudibleQueuePresentationContext>

@property (nullable, nonatomic, readonly, strong) id<PKTAudibleQueue>audibleQueue;
@property (nonnull, nonatomic, readonly, strong) PKTListenPlaybackLoadingView *loading;
@property (nonnull, nonatomic, readonly, strong) UIButton *forwards;
@property (nonnull, nonatomic, readonly, strong) UIButton *backwards;
@property (nonnull, nonatomic, readonly, strong) UIButton *action;
/// @return A layoutGuide describing the bounds of the speed control
/// @note The speed control is not a child of this view.
@property (nonnull, nonatomic, readonly, strong) UILayoutGuide *speedGuide;
@property(null_resettable, nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithQueue:(id<PKTAudibleQueue>)audibleQueue NS_DESIGNATED_INITIALIZER;

- (void)updateAppearance;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
