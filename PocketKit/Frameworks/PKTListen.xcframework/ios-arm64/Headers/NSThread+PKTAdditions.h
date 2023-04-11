//
//  NSThread+PKTAdditions.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 4/16/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSThread (PKTAdditions)

+ (NSArray<NSDictionary<NSString*,NSString*>*> *)callStackElements;

+ (NSArray<NSDictionary*>*)pocketStackElements;

+ (NSArray<NSString*>*)pocketStackSymbols;

+ (NSString *)pocketStackPath;

@end

NS_ASSUME_NONNULL_END
