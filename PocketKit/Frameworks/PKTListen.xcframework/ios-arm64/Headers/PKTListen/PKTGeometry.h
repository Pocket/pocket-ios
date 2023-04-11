//
//  PKTGeometry.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 8/19/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKTGeometry : NSObject

CGRect CGRectIntegralScaledEx(CGRect rect, CGFloat scale);
CGRect CGRectIntegralScaled(CGRect rect);
CGRect CGRectIntegralMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height);
CGRect CGRectCenteredInRect(CGRect rect, CGRect containerRect);
CGRect CGRectFittingCircleAtPoint(CGPoint center, CGFloat radius);
CGRect CGRRectCenteredAtPoint(CGRect rect, CGPoint center);
CGRect CGRectAspectFitWithinRect(CGRect rectToFit, CGRect rectToFitWithin);
CGRect CGRectAspectFillWithinRect(CGRect rectToFit, CGRect rectToFitWithin);
CGRect CGRectConstrainedToRect(CGRect rectToFit, CGRect rectToFitWithin);
CGRect CGRectFillFitRect(CGRect rect, CGRect rectToFill);

CGFloat CGFloatRadian(CGFloat degrees);
CGFloat PKTPrecisionValueBetween(CGFloat min, CGFloat max, CGFloat percentage);
CGFloat PKTValueBetween(CGFloat min, CGFloat max, CGFloat percentage);
CGFloat PKTPrecisionPercentageBetween(CGFloat min, CGFloat max, CGFloat value);
CGFloat PKTPercentageBetween(CGFloat min, CGFloat max, CGFloat value);

#pragma mark - Core Graphics

CGPathRef createPathForRoundedRect(CGRect rect, CGFloat radius);
void CGContextAddRoundedRect(CGContextRef context, CGRect rect, CGFloat radius);
void CGContextAspectFillImage(CGContextRef ctx, CGRect rect, CGImageRef image);
void CGContextAspectFitImage(CGContextRef ctx, CGRect rect, CGImageRef image);

@end

NS_ASSUME_NONNULL_END
