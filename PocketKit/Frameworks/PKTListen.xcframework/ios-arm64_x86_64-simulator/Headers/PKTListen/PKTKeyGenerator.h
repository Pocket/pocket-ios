//
//  PKTKeyGenerator.h
//  PKTRuntime
//
//  Created by David Skuza on 1/17/19.
//  Copyright © 2019 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PKTKeyGenerator <NSObject>

- (NSString *)generateKey:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
