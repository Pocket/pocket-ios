//
//  ExtendColor.h
//  RIL
//
//  Created by Nathan Weiner on 10/25/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (PKTAdditions)

@property (nullable, nonatomic, readonly) NSString *hexValue;

/// New UIColor based on gray value
+ (UIColor *)gray:(int)gray;

/// New UIColor based on red, green and blue value
+ (UIColor *)r:(int)r g:(int)g b:(int)b;

/// New UIColor based on red, green, blue and alpha value
+ (UIColor *)r:(int)r g:(int)g b:(int)b a:(CGFloat)a;

/// New UIColor based on one value for red, green and blue
+ (UIColor *)rgb:(int)rgb;

/// New UIColor based on one value for red, green and blue as well as an extra alpha value
+ (UIColor *)rgb:(int)rgb a:(CGFloat)a;

/// Check if two colors are the same
+ (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance;

// New way to support colors from hex value. colorFromWebString returns UIColor with wrong color values. We still let
// it in the category to not break code from within the WebApp that calls colorFromWebString

/// New UIColor from web string e.g. '#FFF', '#F1F1F1'
+ (UIColor *)colorWithHexValue:(NSString * _Nullable)hexValue;

- (UIColor *)inverseColor;

/// New UIColor from web string e.g. '#FFF', '#F1F1F1', or 'rgb(241, 241, 241)'
+ (UIColor *)colorFromWebString:(NSString *)string __deprecated;

- (BOOL)isEqualToColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
