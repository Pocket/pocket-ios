//
//  DataOperationQueue.h
//  RIL
//
//  Created by Nate Weiner on 10/18/11.
//  Copyright (c) 2011 Pocket All rights reserved.
//

@import Foundation;

@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

#define DATABASE_LEAK_MONITORING_ENABLED 1

@interface DataOperationQueue : NSOperationQueue

@property (atomic, readonly, assign) NSInteger connectionCount;

@property (nonatomic, strong, readonly) FMDatabase *db;

+ (instancetype)mainQueue;

/// @return YES if the databaste file was successfully created/opened.

- (BOOL)createDatabase:(BOOL)replace;

/// Register intent to access database. Calling this method increments the datbase connection count. Calls to open must
/// be balanced with calls to close.

+ (void)open:(NSString *_Nullable)name;

/// Register database access has finished. Calling this method decrements the datbase connection count. Calls to close
/// must be balanced with calls to open. When the connection count reaches zero, the database will be closed.

+ (void)close:(NSString *_Nullable)name;

/// Convenience method for balancing open/close calls during database transactions. The finished block allows the
/// consumer to close the database asyncronously. The finished block must be called when database transactions have
/// been completed.

+ (void)transact:(NSString *)name transaction:(void(^)(FMDatabase *store, dispatch_block_t finished))transaction;

@end

NS_ASSUME_NONNULL_END
