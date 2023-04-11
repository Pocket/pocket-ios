//
//  PKTThemeProtocol.h
//  RIL
//
//  Created by Larry Tran on 1/4/17.
//
//

@protocol PKTUITheme;

@protocol PKTThemeProtocol <NSObject>

- (void)updateStyle;
@end

@protocol PKThemeViewStateProtocol <NSObject>

- (void)setSelected:(BOOL)selection;
- (void)setDisabled:(BOOL)disabled;

@end

@protocol PKTThemeAssignmentProtocol <NSObject>

- (void)updateStyle:(id<PKTUITheme>)theme;

@end

@protocol PKTThemeFontEdgeAssignmentProtocol <NSObject>

- (void)updateStyle:(UIColor *)edgeColor font:(UIFont *)font;

@end

@protocol PKTTextThemeProtocol

- (void)updateStyle:(NSInteger)style;

@end
