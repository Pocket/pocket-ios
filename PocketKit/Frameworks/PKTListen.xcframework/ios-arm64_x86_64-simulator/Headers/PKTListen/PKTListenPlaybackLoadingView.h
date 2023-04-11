//
//  PKTListenPlaybackLoadingView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/8/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTAudibleQueue.h"

@interface PKTListenPlaybackLoadingView : UIView

@property (nonatomic, readonly, strong, nullable) id<PKTAudibleQueue> audibleQueue;
@property(nonatomic, readwrite, assign, getter=isEnabled) BOOL enabled;

- (nonnull instancetype)initWithQueue:(nonnull id<PKTAudibleQueue>)audibleQueue NS_DESIGNATED_INITIALIZER;

- (void)destroy;

@end
