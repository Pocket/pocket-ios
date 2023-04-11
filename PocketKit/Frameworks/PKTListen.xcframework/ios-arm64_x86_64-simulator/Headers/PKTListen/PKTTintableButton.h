//
//  PKTTintableButton.h
//  Listen
//
//  Created by David Skuza on 1/2/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PKTTintableButton : UIButton

- (void)setTintColor:(UIColor *)color forState:(UIControlState)state;
- (UIColor *)tintColorForState:(UIControlState)state;

@end
