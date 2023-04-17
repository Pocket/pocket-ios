//
//  PKTMigration.h
//  PKTRuntime
//
//  Created by David Skuza on 9/26/19.
//  Copyright © 2019 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PKTMigration : NSObject

@property (nonatomic, assign) NSUserDefaults *userDefaults;

@property (nonatomic, assign, getter=isRequired) BOOL required;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

- (void)perform;

@end

NS_ASSUME_NONNULL_END
