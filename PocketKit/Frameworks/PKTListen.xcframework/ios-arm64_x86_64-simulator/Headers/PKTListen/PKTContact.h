//
//  PKTContact.h
//  RIL
//
//  Created by Steve Streza on 10/11/12.
//
//

@import Foundation;
@import AddressBook;

#import "PKTPerson.h"

NS_ASSUME_NONNULL_BEGIN

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"

@interface PKTContact : NSObject<PKTPerson>

@property (nonatomic, assign) ABRecordRef record;

+ (id)contactWithRecord:(ABRecordRef)record indexOfEmail:(NSUInteger)index;
- (id)initWithRecord:(ABRecordRef)record indexOfEmail:(NSUInteger)index;

@property (nonatomic, readonly, copy) NSArray *allEmails;

#pragma mark <PKTPerson>

@property (nonatomic, copy, readonly, nullable) NSString *avatarSrc;
@property (nonatomic, copy, readonly, nullable) NSString *fullName;
@property (nonatomic, copy, readonly, nullable) NSString *email;

@end

@interface PKTContact (AddressBook)

+ (BOOL)isAddressBookUseAuthorized;
+ (BOOL)canPromptForAddressBookUse;

/// Asks for address book authorization if needed
+ (void)requestAddressBookAuthorizationWithHandler:(void (^)(bool granted))handler;

/// Tries to get addressbook authorization before fetching all contacts. If address book authorization was denied in past returns an empty array
+ (void)fetchAllContactsWithHandler:(void (^)(NSArray *contacts))handler;

+ (NSArray *)allContacts;
+ (NSArray *)contactsWithRecord:(ABRecordRef)record;

@end

@interface PKTContact (Recents)

+ (NSArray *)recentPeople;
+ (NSDictionary *)recentPeopleByDate;
+ (void)addRecentPerson:(id<PKTPerson>)person;
+ (void)resetRecentPeople;
+ (void)replaceRecentPeople:(NSDictionary *)recents mostRecentID:(NSInteger)mostRecentID;

@end

@interface PKTManualContact : NSObject <PKTPerson>

- (instancetype)initWithFullName:(NSString *)fullName email:(NSString *)email avatarSrc:(NSString *)avatarSrc;

#pragma mark <PKTPerson>

@property (nonatomic, copy, readwrite, nullable) NSString *avatarSrc;
@property (nonatomic, copy, readwrite, nullable) NSString *fullName;
@property (nonatomic, copy, readwrite, nullable) NSString *email;

@end

#pragma clang diagnostic pop


NS_ASSUME_NONNULL_END
