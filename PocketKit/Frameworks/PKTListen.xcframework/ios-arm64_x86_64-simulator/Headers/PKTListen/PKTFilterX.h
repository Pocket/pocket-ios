//
//  PKTFilterX.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 4/14/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - NSSet+PKTFilterX

@interface NSSet (PKTFilterX)

@property (nonnull, nonatomic, readonly) NSSet * (^xfiltered)(BOOL(^filter)(id obj));

@property (nonnull, nonatomic, readonly) NSSet * (^xnormalized)(void);

@property (nonnull, nonatomic, readonly) NSSet * (^xencodified)(void);

@end

#pragma mark - NSMutableSet+PKTFilterX

@interface NSMutableSet (PKTFilterX)

@property (nonnull, nonatomic, readonly) NSMutableSet * (^xfilter)(BOOL(^filter)(id obj));

@property (nonnull, nonatomic, readonly) NSMutableSet * (^xnormalize)(void);

@property (nonnull, nonatomic, readonly) NSMutableSet * (^xencodify)(void);

@end

#pragma mark - NSArray+PKTFilterX

@interface NSArray (PKTFilterX)

@property (nonnull, nonatomic, readonly) NSArray * (^xfiltered)(BOOL(^filter)(id obj));

@property (nonnull, nonatomic, readonly) NSArray * (^xnormalized)(void);

@property (nonnull, nonatomic, readonly) NSArray * (^xencodified)(void);

@end

#pragma mark - NSMutableArray+PKTFilterX

@interface NSMutableArray (PKTFilterX)

@property (nonnull, nonatomic, readonly) NSMutableArray * (^xfilter)(BOOL(^filter)(id obj));

@property (nonnull, nonatomic, readonly) NSMutableArray * (^xnormalize)(void);

@property (nonnull, nonatomic, readonly) NSMutableArray * (^xencodify)(void);

@end

#pragma mark - NSDictionary+PKTFilterX

@interface NSDictionary (PKTFilterX)

@property (nonnull, nonatomic, readonly) NSDictionary * (^xfiltered)(BOOL(^filter)(id obj));

@property (nonnull, nonatomic, readonly) NSDictionary * (^xnormalized)(void);

@property (nonnull, nonatomic, readonly) NSDictionary * (^xencodified)(void);

@end

#pragma mark - NSDictionary+PKTFilterX

@interface NSMutableDictionary (PKTFilterX)

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^xfilter)(BOOL(^filter)(id obj));

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^xnormalize)(void);

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^xencodify)(void);

@end

NS_ASSUME_NONNULL_END
