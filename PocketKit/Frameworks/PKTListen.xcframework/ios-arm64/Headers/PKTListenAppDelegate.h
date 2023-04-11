//
//  PKTListenAppDelegate.h
//  Listen
//
//  Created by Nicholas Zeltzer on 7/27/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTListen.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTLocalRuntime : PKTAbstractRuntime<PKTFutureRuntime>

+ (instancetype)sharedRuntime;

@end

@interface PKTListenAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

NS_ASSUME_NONNULL_END

