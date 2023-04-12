//
//  PKTExtendedAttribution.h
//  RIL
//
//  Created by Michael Schneider on 12/10/14.
//
//

@import UIKit;

#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

@class PKTExtendedAttributionType;

@interface PKTExtendedAttribution : NSObject <PKTModelCodable>

+ (instancetype)extendedAttributionWithDictionary:(NSDictionary *)dictionary;

@property (strong, nonatomic, readonly) PKTExtendedAttributionType *attributionType;

/// Source Id of extended attribution. Should be a string as it's not only numeric
@property (copy, nonatomic, readonly) NSString *sourceId;

@property (strong, nonatomic, readonly) NSNumber *itemUniqueId;
@property (strong, nonatomic, readonly) NSNumber *attributionId;
@property (strong, nonatomic, readonly) NSNumber *attributionTypeId;
@property (copy, nonatomic, readonly) NSString *profileName;
@property (copy, nonatomic, readonly) NSString *profileContact;
@property (copy, nonatomic, readonly) NSString *profileImageURLString;
@property (copy, nonatomic, readonly) NSString *data;
@property (copy, nonatomic, readonly) NSDictionary *dataDictionary;
@property (strong, nonatomic, readonly) NSNumber *time;

@end

NS_ASSUME_NONNULL_END
