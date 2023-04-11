//
//  PKTUITheme.h
//  RIL
//
//  Created by Michael Schneider on 8/18/13.
//
//

#import <Foundation/Foundation.h>

@protocol PKTUITheme <NSObject>

- (UIColor *)white;
- (UIColor *)amber;
- (UIColor *)amberTouch;
- (UIColor *)blue;
- (UIColor *)blueTouch;
- (UIColor *)teal;
- (UIColor *)tealLight;
- (UIColor *)darkTeal;
- (UIColor *)mintGreen;
- (UIColor *)coral;
- (UIColor *)coralTouch;
- (UIColor *)coralLight;
- (UIColor *)darkTealSelection;
- (UIColor *)purle;

- (UIColor *)gray1;
- (UIColor *)gray2;
- (UIColor *)gray3;
- (UIColor *)gray4;
- (UIColor *)gray5;
- (UIColor *)gray6;

- (UIColor *)tileStartFadeColor;
- (UIColor *)tileEndFadeColor;

- (UIColor *)highlightTextColor;
- (UIColor *)highlightBackgroundColor;
- (UIColor *)disabledTextColor;

- (UIColor *)tagSelectedBackgroundColor;

- (UIImage *)inListBigDiamond;

#pragma mark - Deprecated

- (UIStatusBarStyle)statusBarStyle;
- (UIScrollViewIndicatorStyle)scrollViewIndicatorStyle;

@end
