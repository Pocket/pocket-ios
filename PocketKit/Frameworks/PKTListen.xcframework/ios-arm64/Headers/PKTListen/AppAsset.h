//
//  AppAsset.h
//  RIL
//
//  Created by Nate Weiner on 10/14/11.
//  Copyright (c) 2011 Pocket All rights reserved.
//

#import "Asset.h"

NS_ASSUME_NONNULL_BEGIN

@interface AppAsset : Asset

+ (instancetype)assetForLiteral:(NSString *)literal;
+ (NSURL *)preloadedURLForLiteral:(NSString *)literal;
+ (NSURL *)preloadedBaseURL;
+ (NSString *)localPathForLiteral:(NSString *)literal;
+ (NSString *)localPathHeadForLiteral:(NSString *)literal;

@end

NS_ASSUME_NONNULL_END
