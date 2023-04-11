//
//  PKTTextUnit.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 1/28/19.
//  Copyright © 2019 PKT. All rights reserved.
//

@import Foundation;

#import "PKTKusari.h"

@class ONOXMLElement;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, PKTTagMatchType) {
    PKTTagMatchTypeNone,
    PKTTagMatchTypeHeader,
    PKTTagMatchTypeText,
    PKTTagMatchTypeOrderedList,
    PKTTagMatchTypeUnorderedList,
    PKTTagMatchTypeDescriptionList,
    PKTTagMatchTypePreformattedText,
    PKTTagMatchTypeTable,
    PKTTagMatchTypeBlockQuote,
    PKTTagMatchTypeImage,
    PKTTagMatchTypeUnknown,
};

/** PKTTextUnit is a model object that describes a block of HTML text. */

@interface PKTTextUnit : NSObject <PKTListDiffable>

/// @return the index of the text unit within its original context
@property (nonatomic, readonly, assign) NSUInteger index;
/// @return the tag type that this text unit represents
@property (nonatomic, readonly, assign) PKTTagMatchType type;
/// @return the backing XMLValue that this text unit represents
@property (nonatomic, readonly, strong, nullable) NSString *XMLValue;
/// @return the string interpretation of the XMLValue
@property (nonatomic, readonly, strong, nullable) NSString *stringValue;
/// @return the XML tag associated with the XMLValue
@property (nonatomic, readonly, strong, nullable) NSString *tagValue;
/// @return NSAttributedString representation of the string value
@property (nonatomic, readonly, strong, nullable) NSAttributedString *attributedStringValue;
/// @return the ONOXMLElement from which this text unit was generated
/// @note This element is only valid for as long as its parent document lives
@property (nonatomic, readonly, strong, nonnull) ONOXMLElement *element;

+ (instancetype)unitWithType:(PKTTagMatchType)type element:(ONOXMLElement *)element index:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
