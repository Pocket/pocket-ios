//
//  PKTRecentPeopleManager.h
//  RIL
//
//  Created by Michael Schneider on 8/19/15.
//
//

#import <Foundation/Foundation.h>

@protocol PKTPerson;

@interface PKTRecentPeopleManager : NSObject

/// Insert person at the beginning of the recent people
+ (void)addRecentPerson:(id<PKTPerson>)person;

/// Removes person from the recent people
+ (void)removeRecentPerson:(id<PKTPerson>)person;

/// Replaces all recent people with given NSArray of objects that confirm to the PKTPerson protocol
+ (void)replaceRecentPeople:(NSArray *)recents;

/// Update all recent people with a given NSArray of NSDictionary objects
+ (void)updateRecentPeople:(NSArray *)recents;

/// Return recent people as NSArray of objects that confirm to the PKTPerson protocol
+ (NSArray *)recentPeople;

/// Reset recent people
+ (void)resetRecentPeople;

@end
