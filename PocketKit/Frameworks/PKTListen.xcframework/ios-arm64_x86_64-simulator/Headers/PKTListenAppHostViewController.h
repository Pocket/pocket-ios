//
//  PKTListenAppHostViewController.h
//  Listen
//
//  Created by Nicholas Zeltzer on 7/27/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

#import "PKTListen.h"
#import "PKTListenAppTheme.h"

#define PKTListenAppAlwaysUseRemoteSource 0
#if PKTListenAppAlwaysUseRemoteSource
#warning PKTListenAppAlwaysUseRemoteSource is true
#endif

NS_ASSUME_NONNULL_BEGIN

#pragma mark - PKTListenAppLoginViewController

@interface PKTListenAppLoginViewController : UIViewController <UITextFieldDelegate>

@property (nonnull, nonatomic, readonly, strong) UIView *container;
@property (nonnull, nonatomic, readonly, strong) UITextField *username;
@property (nonnull, nonatomic, readonly, strong) UITextField *password;
@property (nonnull, nonatomic, readonly, strong) UIButton *button;

@end


#pragma mark - PKTListenAppLoginTextField

@interface PKTListenAppLoginTextField : UITextField

@end

#pragma mark - PKTListenAppHostViewController

@interface PKTListenAppHostViewController : PKTListenAppLoginViewController

@end


NS_ASSUME_NONNULL_END
