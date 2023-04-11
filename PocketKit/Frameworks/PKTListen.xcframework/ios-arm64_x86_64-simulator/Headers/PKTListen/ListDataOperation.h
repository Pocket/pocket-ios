//
//  ListDataOperation.h
//  RIL
//
//  Created by Nate Weiner on 10/18/11.
//  Copyright (c) 2011 Pocket All rights reserved.
//

#import "TransactionDataOperation.h"
#import "PKTSharedEnums.h"

NS_ASSUME_NONNULL_BEGIN;

@class Action;
@class PKTFriendsCache;
@class PKTSharesIndex;
@class DataOperationQueue;

@interface ListDataOperation : TransactionDataOperation

- (instancetype)initWithDataOperationQueue:(DataOperationQueue *)dataOperationQueue NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) DataOperationQueue *dataOperationQueue;
@property (nonatomic, assign) BOOL syncWhenFinished;
@property (nonatomic, assign) BOOL refreshListWhenFinished;
@property (nonatomic, assign) BOOL skipAddItemDupeCheck;
@property (nonatomic, assign) BOOL uniqueIdNeedsFlush;
@property (nonatomic, strong) NSMutableArray *syncActions;
@property (nonatomic, strong) NSMutableDictionary *possibleNewTags;

- (PKTFriendsCache *)getFriendsCache;
- (BOOL)action:(Action *)action sync:(BOOL)sync;

#pragma -

- (NSNumber *_Nullable)addItem:(Action *)action;
- (NSNumber *_Nullable)addItemFromDictionary:(NSDictionary *)dictionary;
- (void)saveExtras:(NSNumber *)uniqueId data:(NSDictionary *)data replace:(BOOL)replace;
- (void)saveMeta:(NSNumber *)uniqueId meta:(NSDictionary *)meta replace:(BOOL)replace;
- (void)saveMedia:(NSNumber *)uniqueId data:(NSDictionary *)data replace:(BOOL)replace;

- (void)savePositions:(NSNumber *)uniqueId positions:(NSDictionary *)positions replace:(BOOL)replace;
- (void)savePosition:(NSNumber *)uniqueId positionDictionary:(NSDictionary *)dictionary replace:(BOOL)replace;
- (void)saveShares:(NSNumber *)uniqueId shares:(NSDictionary *)shares;
- (NSNumber *)saveShare:(NSDictionary *)share uniqueId:(NSNumber *)uniqueId;

- (void)saveAttributions:(NSNumber *)uniqueId attributions:(NSDictionary *)attributions;
- (void)saveAttribution:(NSDictionary *)attribution uniqueId:(NSNumber *)uniqueId;
- (void)savePosts:(NSArray *)posts forUniqueId:(NSNumber *)uniqueId;
- (void)savePost:(NSDictionary *)post forUniqueId:(NSNumber *)uniqueId;
- (void)saveHighlights:(NSDictionary *)highlights useUniqueItemIndex:(NSMutableDictionary *)index;
- (void)saveCarousel:(NSArray *)carousel useUniqueItemIndex:(NSMutableDictionary *)index;
- (BOOL)itemHasPendingShare:(NSNumber *)uniqueId;
- (void)updateHasPendingShare:(NSNumber *)uniqueId;
- (void)attemptToRemoveItem:(NSNumber *)uniqueId newStatus:(ItemStatus)newStatus;
- (void)removeItem:(NSNumber *)uniqueId;

- (void)resolveItemId:(NSString *)itemId uniqueId:(NSNumber *)uniqueId;
- (NSMutableDictionary *_Nullable)getUniqueItemIndex;

/// Update extended data is called if an item was added or readded and extended data for the item was added to the item in the database. This method sends a "itemExtendedUpdated" notification in case the frontend needs to update the state
- (void)updateExtendedItem:(NSDictionary *)item uniqueId:(NSNumber *)uniqueId;

/** Safely execute a 'into' table operation with a mapping of keys to values.
 @param tableName the name of the table into which the operation will be executed
 @param command the SQL command (e.g., INSERT)
 @param sqlValueMap a mapping of field names to values
 @param error if the operation fails, a pointer to a valid error object
 */

- (BOOL)into:(NSString *_Nonnull)tableName
     command:(NSString *_Nonnull)command
      values:(NSDictionary<NSString*, id> *_Nonnull)sqlValueMap
       error:(inout NSError *_Nullable *_Nullable)error;

#pragma mark - Sync

- (void)addSyncAction:(Action *)action syncWhenFinished:(BOOL)shouldSync;
- (void)sendCallback;
- (NSNumber *)nextUniqueId;
- (void)flushUniqueId;

@end

NS_ASSUME_NONNULL_END;
