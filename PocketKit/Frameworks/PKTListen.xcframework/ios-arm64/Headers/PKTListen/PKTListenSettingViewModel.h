//
//  PKTListenSettingViewModel.h
//  Listen
//
//  Created by David Skuza on 2/7/19.
//  Copyright © 2019 PKT. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PKTListenSettingAccessoryType) {
    PKTListenSettingAccessoryTypeNone = 0,
    PKTListenSettingAccessoryTypeCheckmark,
    PKTListenSettingAccessoryTypeChevron,
    PKTListenSettingAccessoryTypeSliderOff,
    PKTListenSettingAccessoryTypeSliderOn
};

NS_ASSUME_NONNULL_BEGIN

/**
 A data structure representing the content that can be bound to a PKTListenSettingCell.
 It depends on no specific data type, and thus can be built-out to represent various data types.
 */
@interface PKTListenSettingViewModel : NSObject <NSCopying>

/**
 A attributed version of the text the view model was initialized with.
 This text will be presented on the left side of the cell, above the detail text.
 */
@property (nonatomic, readonly) NSAttributedString *text;

/**
 A attributed version of the detail text the view model was initialized with.
 This text will be presented on the left side of the cell, below the main text.
 */
@property (nonatomic, readonly) NSAttributedString *detailText;

/**
 A attributed version of the accessory text the view model was initialized with.
 This text will be presented on the right side of the cell,
 but to the left of any accessory view, above the accessory detail text.
 */
@property (nonatomic, readonly) NSAttributedString *accessoryText;

/**
 A attributed version of the accessory detail text the view model was initialized with.
 This text will be presented on the right side of the cell,
 but to the left of any accessory view, below the main accessory text.
 */
@property (nonatomic, readonly) NSAttributedString *accessoryDetailText;

/**
 The type of accessory view that should be presented, such as checkmark, or chevron.
 */
@property (nonatomic, readonly) PKTListenSettingAccessoryType accessoryType;

/**
 Whether or not the presenting cell should additionally display a separator at the bottom.
 */
@property (nonatomic, readonly) BOOL showsSeparator;

/**
 Initializes a new view model based on some content.

 @param text The main text to present.
 @param detailText The detail text to present.
 @param accessoryText The main accessory text to present.
 @param accessoryDetailText The accessory detail text to present.
 @param accessoryType The type of accessory view to present.
 @param showsSeparator Whether to display an additional separator.
 @return A view model to bind to a PKTListenSettingCell.
 */
- (instancetype)initWithText:(NSString *)text
                  detailText:(nullable NSString *)detailText
               accessoryText:(nullable NSString *)accessoryText
         accessoryDetailText:(nullable NSString *)accessoryDetailText
               accessoryType:(PKTListenSettingAccessoryType)accessoryType
              showsSeparator:(BOOL)showsSeparator;

@end

NS_ASSUME_NONNULL_END
