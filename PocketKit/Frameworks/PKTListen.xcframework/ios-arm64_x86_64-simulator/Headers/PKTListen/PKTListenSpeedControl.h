//
//  PKTListenSpeedControl.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/21/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@protocol PKTAudibleQueue;

typedef NS_ENUM(NSInteger, PKTListenSpeedControlState) {
    PKTListenSpeedControlStepperViewStateCollapsed = 0,
    PKTListenSpeedControlStepperViewStateExpanded = 1,
};



@interface PKTListenSpeedControl : UIView

@property (nullable, nonatomic, readonly, strong) id<PKTAudibleQueue> audibleQueue;

/// KVO Observable
@property (nonatomic, readwrite, assign) enum PKTListenSpeedControlState viewState;

@property (nonatomic, readwrite, assign) CGSize minimumCollapsedSize;
@property (nonatomic, readwrite, assign) CGSize minimumExpandedSize;
@property (nonatomic, readwrite, assign) NSInteger maximumSpeedFactor;
@property (nonatomic, readwrite, assign) NSInteger minimumSpeedFactor;
@property (nonatomic, readwrite, assign) NSInteger incrementStep;
/// Amount of time after which the control will automatically collpase if no interaction
@property (nonatomic, readwrite, assign) NSTimeInterval automaticCloseDuration;
@property(nonatomic,getter=isEnabled) BOOL enabled;    

@property (nonatomic, readonly, strong, nullable) UITapGestureRecognizer *tapToCloseGestureRecognizer;

@property (nonnull, nonatomic, readwrite, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR;

- (instancetype)initWithQueue:(nonnull id<PKTAudibleQueue>)audibleQueue NS_DESIGNATED_INITIALIZER;

- (void)setTextColor:(UIColor *)color forState:(enum PKTListenSpeedControlState)state UI_APPEARANCE_SELECTOR;

- (void)setViewState:(enum PKTListenSpeedControlState)state animated:(BOOL)animated;

- (void)destroy;

@end

NS_ASSUME_NONNULL_END
