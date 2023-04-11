//
//  PKTRenderView.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/11/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface PKTRenderView : UIView

@property (nonnull, nonatomic, readonly) UIImage *_Nonnull (^image)(CGSize size);

+ (instancetype)viewWithBlock:(void(^)(UIView *view, CGContextRef ctx, CGRect rect))block;

@end

NS_ASSUME_NONNULL_END
