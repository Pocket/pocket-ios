//
//  ActionStore.h
//  PKTRuntime
//
//  Created by David Skuza on 12/26/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Action;

@protocol ActionStore <NSObject>

/**
 Stores an action for a given key.

 @param action The action to store.
 @param key The key to map the action to.
 */
- (void)setAction:(Action *)action forKey:(NSString *)key;

/**
 Returns a stored action for a given key.

 @param key The key to which an action is mapped.
 @return The stored action, or nil if one does not exist for a given key.
 */
- (Action *_Nullable)actionForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
