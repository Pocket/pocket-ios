//
//  NSNumber+PKTAdditions.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 11/11/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (PKTAdditions)

- (NSString *_Nonnull)localizedPrice:(NSLocale *_Nonnull)locale;

@end

NS_ASSUME_NONNULL_END
