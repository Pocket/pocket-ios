//
//  PKTUserProfileProtocol.h
//  RIL
//
//  Created by Larry Tran on 10/12/15.
//
//

#import <Foundation/Foundation.h>
#import "PKTActivityShareItem.h"

@protocol PKTUserProfileProtocol <NSObject, PKTActivityShareItem>

- (NSString *)uid;
- (NSURL *)avatarURL;
- (NSString *)bio;
- (NSNumber *)isFollowing;
- (NSString *)name;
- (NSString *)username;
- (BOOL)isLoggedInUser;
- (NSNumber *)followerCount;
- (NSNumber *)followingCount;
- (NSNumber *)postCount;
- (NSURL *)shareableProfileURL;
- (NSDictionary *)dictionaryRepresentation;
- (BOOL)hasPremium;

// TODO: Move to this into a private implementation
- (void)setIsFollowing:(NSNumber *)isFollowing;
- (void)setFollowerCount:(NSNumber *)count;

@end
