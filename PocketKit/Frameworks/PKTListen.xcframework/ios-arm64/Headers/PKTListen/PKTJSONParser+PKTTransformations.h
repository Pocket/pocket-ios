//
//  PKTJSONParser+PKTJSONTransformations.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 9/17/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "PKTJSONParser.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTJSONParser (PKTJSONTransformations)

@property (nonatomic, readonly, copy, nonnull, class) PKTJSONPathTransformation stringToURL;
@property (nonatomic, readonly, copy, nonnull, class) PKTJSONPathTransformation stringToNumber;
@property (nonatomic, readonly, copy, nonnull, class) PKTJSONPathTransformation hexStringToColor;
@property (nonatomic, readonly, copy, nonnull, class) PKTJSONPathTransformation dictionaryToItem;
@property (nonatomic, readonly, copy, nonnull, class) PKTJSONPathTransformation dictionaryAllValues;
@property (nonatomic, readonly, copy, nonnull, class) PKTJSONPathTransformation mySQLDateStringToDate;

@end

NS_ASSUME_NONNULL_END
