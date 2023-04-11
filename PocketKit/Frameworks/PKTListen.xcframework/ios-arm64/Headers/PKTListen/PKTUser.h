//
//  PKTUser.h
//  RIL
//
//  Created by Steve Streza on 8/13/12.
//
//

#import "PKTUserProfileProtocol.h"
#import "PKTModelCodable.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    PKTUserPremiumAllTimeStatusNever = 0,
    PKTUserPremiumAllTimeStatusActive = 1,
    PKTUserPremiumAllTimeStatusExpired = 2,
} PKTUserPremiumAllTimeStatus;

typedef enum : NSUInteger {
    PKTUserPremiumOnTrialStatusNo = 0,
    PKTUserPremiumOnTrialStatusYes = 1,
} PKTUserPremiumOnTrialStatus;

extern NSString * const PKTUserUIDKey;
extern NSString * const PKTUserUsernameKey;
extern NSString * const PKTUserFirstNameKey;
extern NSString * const PKTUserLastNameKey;
extern NSString * const PKTUserEmailAddressKey;
extern NSString * const PKTUserAvatarURLKey;
extern NSString * const PKTUserUnconfirmedSharesKey;
extern NSString * const PKTUserHasSetAvatarKey;
extern NSString * const PKTUserHasPremiumKey;
extern NSString * const PKTUserPremiumAllTimeStatusKey;
extern NSString * const PKTUserPremiumOnTrialStatusKey;
extern NSString * const PKTUserHighlightsEnabledKey;
extern NSString * const PKTUserConnectedAccountsKey;
extern NSString * const PKTConnectedAccountsTwitter;
extern NSString * const PKTUserBirthDate;
extern NSString * const PKTUserAccount;

@interface PKTUser : NSObject <PKTUserProfileProtocol, PKTModelCodable>

/// Returns the app's ; logged in PKTUser object
+ (instancetype)loggedInUser;

/// Returns the current access token key for the logged in user
+ (NSString *)userKeychainAccessTokenKey __deprecated;

- (void)updateWithDictionary:(NSDictionary *)dictionary;

/// Returns username for the current logged in user
@property (nonatomic, copy, nullable) NSString *username;

/// Returns the birthday (createdAt) date
@property (nonatomic, copy) NSDate *birthDate;

/// Determine if the user is currently logged in
@property (nonatomic, readonly, assign, getter=isLoggedIn) BOOL loggedIn;

/// Returns userId for the current logged in user
- (NSString *)uid;

/// Reset all saved data related tok the current logged in user
- (void)logout;

// Check if the current username is a NSNull username. If the user has an NSNull username, their account got screwed up, so blow it away and start over
- (BOOL)hasNSNullUsername;

/// Returns the first name for the current logged in user
@property (nonatomic, copy, nullable) NSString *firstName;

/// Returns the last name for the current logged in user
@property (nonatomic, copy, nullable) NSString *lastName;

/// Returns the email address for the current logged in user
@property (nonatomic, copy, nullable) NSString *emailAddress;

/// Returns the avatar url for the current logged in user
@property (nonatomic, copy) NSURL *avatarURL;

/// Returns all unconfirmed shares for the current logged in user
@property (nonatomic, copy) NSArray *unconfirmedShares;

/// Determine if the currently logged in user has set an avatar within Pocket
@property (nonatomic, assign) BOOL hasSetAvatar;

/// Declares the current premium status of the user
@property (nonatomic, assign) BOOL hasPremium;

/// Declares if the user has premium and is NOT on a trial
@property (nonatomic, assign, readonly) BOOL hasPremiumAndPaid;

/// Declares if the user at any time had premium in the past
@property (nonatomic, assign) PKTUserPremiumAllTimeStatus premiumAllTimeStatus;

/// Declares if the premium is on trial
@property (nonatomic, assign) PKTUserPremiumOnTrialStatus premiumOnTrialStatus;

/// Declares if highlights UI should show up for user
@property (nonatomic, assign, readonly) BOOL hasHighlightsEnabled;
@property (nonatomic, strong) NSNumber *highlightsEnabled;

/// Returns the connected services for the user
@property (nonatomic, copy) NSArray *connectedAccounts;

/// Either first name and last name, first name, last name, username if not start's with *, email
@property (readonly, nonatomic) NSString *displayName;

/// User Identifier is either username if not starting with *, email
@property (readonly, nonatomic) NSString *userIdentifier;

/// Returns if the current user has a username that is not a username that starts with * (a temporary username), e.g. that we use for signups via Google.
@property (readonly, nonatomic) BOOL hasDisplayableUsername;

/// Profile URL for user opening it in app. For a shareable profile url see: shareableProfileURL
@property (readonly, nonatomic) NSURL *profileURL;

/// Returns the bio for the user
@property (nonatomic, copy, nullable) NSString *bio;

/// Returns the following count for the user
@property (nonatomic, strong) NSNumber *followingCount;

/// Returns the follower count for the user
@property (nonatomic, strong) NSNumber *followerCount;

/// Returns the following for the user
@property (nonatomic, strong) NSNumber *postCount;

@property (nonatomic, assign, getter=hasSignedUp) BOOL signedUp;

/// Returns a list of available list of premium features 
@property (nonatomic, strong) NSArray *premiumFeatures;

@end

NS_ASSUME_NONNULL_END
