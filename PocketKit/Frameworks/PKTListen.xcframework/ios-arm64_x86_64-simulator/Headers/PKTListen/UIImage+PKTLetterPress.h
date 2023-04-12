//
//  UIImage+PKTLetterPress.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 9/22/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (PKTLetterPress)

+ (nullable instancetype)imageWithAttributedString:(NSAttributedString *)string;

+ (nullable instancetype)imageWithAttributedString:(NSAttributedString *)string constrainedToSize:(CGSize)size;

+ (nullable instancetype)imageWithAttributedString:(NSAttributedString *)string fillingSize:(CGSize)size;

@end


NS_ASSUME_NONNULL_END
