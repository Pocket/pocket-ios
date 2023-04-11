//
//  NSLayoutConstraint+PKTAdditions.h
//  RIL
//
//  Created by Nik Zeltzer on 9/28/16.
//
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSArray<NSLayoutConstraint*>*_Nonnull (^PKTVisualConstraintsVendor)(NSString *_Nonnull, NSLayoutFormatOptions);

typedef NSLayoutConstraint*_Nonnull (^PKTMatchedAttributeVendor)(NSLayoutAttribute, CGFloat);

typedef NSLayoutConstraint*_Nonnull (^PKTRelationshipVendor)(NSLayoutAttribute, NSLayoutAttribute, NSLayoutRelation, CGFloat);

typedef NSLayoutConstraint*_Nonnull (^PKTConstraintLiteralVendor)(NSLayoutAttribute attribute, NSLayoutRelation relation, CGFloat constant);

@interface NSLayoutConstraint (PKTAdditions)

/**
 PKTConstraintsVendor is a higher order function that vends a partially bound block for reducing repetition when writing layout constraints.
 */

PKTVisualConstraintsVendor PKTVisualConstraints(NSDictionary *_Nullable views, NSDictionary *_Nullable metrics);

PKTMatchedAttributeVendor PKTConstraintPin(UIView *_Nonnull view1, UIView *_Nonnull view2);

PKTRelationshipVendor PKTConstraint(UIView *_Nonnull view1, UIView *_Nonnull view2);

PKTConstraintLiteralVendor PKTConstraintLiteral(UIView *_Nonnull view);

UIView *_Nonnull PKTVisualizeLayoutGuide(UILayoutGuide *_Nonnull guide, UIColor *_Nonnull color);

@end

@interface UIView (PKTLayoutGuides)

- (NSArray<UILayoutGuide*>*_Nullable)addEqualWidthHorizontalGuides:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
