//
//  PKTListenDrawerViewController.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/24/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTDrawerHostViewController.h"
#import "PKTKusari+PKTListen.h"
#import "PKTListenDataSource.h"

@class PKTListenQueueViewController;
@protocol PKTListenConfiguration;

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenDrawerViewController : PKTDrawerHostViewController

@property (nonnull, nonatomic, readonly, strong) PKTListenQueueViewController *queueViewController;

+ (instancetype)drawerWithConfiguration:(id<PKTListenConfiguration>)configuration;

+ (instancetype)drawerWithViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
