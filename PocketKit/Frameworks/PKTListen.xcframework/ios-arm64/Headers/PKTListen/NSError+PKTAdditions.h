//
//  NSError+PKTAdditions.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 3/5/18.
//  Copyright © 2018 Pocket. All rights reserved.
//



@interface NSError (PKTAdditions)

/** Add linked list-like behavior to NSError to allow returning a list of common errors */

@property (nonnull, nonatomic, readonly, strong) NSError *head;
@property (nullable, nonatomic, readonly, strong) NSError *next;
@property (nullable, nonatomic, readonly, strong) NSError *parent;

/** Adds the error to the end of the list.
 @return The last error in the list.
 @note This block property is suitable for chaining.
 */

@property (nonnull, nonatomic, readonly) NSError *_Nullable (^link)(NSError *_Nullable error);

@end