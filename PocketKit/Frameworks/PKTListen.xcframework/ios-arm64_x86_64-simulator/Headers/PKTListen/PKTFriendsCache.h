//
//  PKTFriendsCache.h
//  RIL
//
//  Created by Nate Weiner on 8/16/12.
//  Copyright (c) 2012 Read It Later. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKTFriend;
@class ListDataOperation;

@interface PKTFriendsCache : NSObject

@property (nonatomic, retain) NSMutableDictionary *indexByFriendId;
@property (nonatomic, retain) NSMutableDictionary *indexByLocalId;
@property (nonatomic, retain) NSMutableDictionary *indexByAutoCompleteEmail;
@property (nonatomic, assign) ListDataOperation *operation;
@property (nonatomic, assign) BOOL isReady;

- (id)initWithListDataOperation:(ListDataOperation *)op;
- (void)makeReady;

#pragma mark - Lookups

- (NSNumber *)localIdForFriendId:(NSNumber *)friendId;
- (PKTFriend *)friendForFriendId:(NSNumber *)friendId;
- (NSNumber *)friendIdForLocalId:(NSNumber *)localId;
- (PKTFriend *)friendForLocalId:(NSNumber *)localId;
- (NSNumber *)localIdForAutoCompleteEmail:(NSString *)email;
- (PKTFriend *)friendForAutoCompleteEmail:(NSString *)email;
- (NSMutableArray *)allFriends;

#pragma mark - Cache Management

- (void)addFriendToCache:(PKTFriend *)friend;
- (void)removeLocalFriend:(NSNumber *)localFriendId;
- (void)updateLocalIdForAutoCompleteEmail:(NSString *)email newLocalFriendId:(NSNumber *)newLocalFriendId oldLocalFriendId:(NSNumber *)oldLocalFriendId;
- (void)updateLocalIdForAutoCompleteEmailsWithLocalId:(NSNumber *)oldLocalFriendId newLocalFriendId:(NSNumber *)newLocalFriendId;
- (void)addAutoCompleteEmailToCache:(NSString *)email forLocalFriendId:(NSNumber *)localFriendId;
- (void)clear;

#pragma mark - Local Storage Changes

- (void)updateFriendForLocalId:(NSNumber *)localId newFriend:(PKTFriend *)newFriend;
- (void)updateFriendForFriendId:(NSNumber *)friendId newFriend:(PKTFriend *)newFriend;
- (void)updateFriend:(PKTFriend *)existingFriend newFriend:(PKTFriend *)newFriend;
- (void)updateFriendIfChanged:(NSDictionary *)friendDict;

- (void)updateAutoCompleteEmails:(NSArray *)emails;
- (NSNumber *)addAutoCompleteEmail:(NSString *)email;
- (void)addAutoCompleteEmail:(NSString *)email forFriendID:(NSNumber *)friendID;
- (void)addAutoCompleteEmail:(NSString *)email forLocalFriendID:(NSNumber *)localFriendId;

- (void)updateRecents;

@end
