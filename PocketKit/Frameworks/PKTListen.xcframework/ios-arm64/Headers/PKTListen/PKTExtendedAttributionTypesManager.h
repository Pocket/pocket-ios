//
//  PKTExtendedAttributionTypesManager.h
//  RIL
//
//  Created by Michael Schneider on 12/10/14.
//
//

@import UIKit;

#import "PKTSharedEnums.h"

#pragma mark - PKTExtendedAttributionTypeAction

@interface PKTExtendedAttributionTypeAction : NSObject
@property (copy, nonatomic, readonly) NSString *localizedName;
@property (copy, nonatomic, readonly) NSString *unlocalizedName;
@property (copy, nonatomic, readonly) NSDictionary *iconPaths;
@property (copy, nonatomic, readonly) NSString *schemeAction;
@property (copy, nonatomic, readonly) NSArray *requiredVars;
@property (strong, nonatomic, readonly) UIImage *icon;

@end


#pragma mark - PKTExtendedAttributionType

@interface PKTExtendedAttributionType : NSObject
@property (strong, nonatomic, readonly) NSNumber *attributionTypeId;
@property (copy, nonatomic, readonly) NSString *name;
@property (copy, nonatomic, readonly) NSDictionary *ovalLogoPaths;

/// Logo action for attribution type
@property (strong, nonatomic, readonly) PKTExtendedAttributionTypeAction *logoAction;

/// Array of PKTExtendedAttributionTypeAction that should show up in the extended attribution
@property (copy, nonatomic, readonly) NSArray *actions;

@property (strong, nonatomic, readonly) UIImage *ovalLogo;

@end


#pragma mark - PKTExtendedAttributionTypesManager

@interface PKTExtendedAttributionTypesManager : NSObject

+ (instancetype)sharedManager;
- (void)update:(NSDictionary *)attributionTypes;
- (PKTExtendedAttributionType *)attributionTypeForId:(NSNumber *)attributionTypeId;

@end


