//
//  PKTListenButton.h
//  Listen
//
//  Created by David Skuza on 11/12/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PKTListenButtonType) {
    PKTListenButtonTypeBlue
};

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenButton : UIButton

- (instancetype)initWithType:(PKTListenButtonType)type title:(NSString *)title NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

- (void)updateAppearance;

@end

NS_ASSUME_NONNULL_END
