//
//  PKTListenAppAuthentication.h
//  Listen
//
//  Created by Nicholas Zeltzer on 7/27/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAppAuthentication : NSObject

+ (instancetype)sharedInstance;

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(void(^)(NSDictionary *info, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
