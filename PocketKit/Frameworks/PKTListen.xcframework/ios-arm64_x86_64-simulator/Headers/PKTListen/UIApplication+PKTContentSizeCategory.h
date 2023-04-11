//
//  UIApplication+PKTContentSizeCategory.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 10/16/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTContentSizeCategoryValue) {
    PKTContentSizeCategoryValueExtraSmall = -2,
    PKTContentSizeCategoryValueSmall,
    PKTContentSizeCategoryValueMedium,
    PKTContentSizeCategoryValueLarge,
    PKTContentSizeCategoryValueExtraLarge,
    PKTContentSizeCategoryValueExtraExtraLarge,
    PKTContentSizeCategoryValueExtraExtraExtraLarge,
    PKTContentSizeCategoryValueAccessibilityMedium,
    PKTContentSizeCategoryValueAccessibilityLarge,
    PKTContentSizeCategoryValueAccessibilityExtraLarge,
    PKTContentSizeCategoryValueAccessibilityExtraExtraLarge,
    PKTContentSizeCategoryValueAccessibilityExtraExtraExtraLarge,
};

@interface UIApplication (PKTContentSizeCategory)

- (PKTContentSizeCategoryValue)currentContentSizeCategoryValue;

+ (BOOL)accessibilityContentSizeEnabled;

@end

NS_ASSUME_NONNULL_END
