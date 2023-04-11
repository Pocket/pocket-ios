//
//  PKTListenEmptyView.h
//  Listen
//
//  Created by David Skuza on 11/12/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenEmptyView : UIView

- (instancetype)initWithTitle:(NSString *)title
                         body:(NSString *)body
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(void (^)(void))buttonAction NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
