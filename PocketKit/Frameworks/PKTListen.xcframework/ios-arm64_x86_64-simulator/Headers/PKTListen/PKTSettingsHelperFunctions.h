//
//  PKTKeychainFunctions.h
//  RIL
//
//  Created by Michael Schneider on 9/8/14.
//
//

#import <Foundation/Foundation.h>

/// Set a new keychain value for the given key
void setKeychainValueForKey(id value, NSString *key) __deprecated;

/// Get a keychain value for the given key and access group
void setKeychainValueForKeyAccessGroup(id value, NSString *key, NSString *accessGroup) __deprecated;

/// Get a keychain value for the given key
id getKeychainValueForKey(NSString *key) __deprecated;

/// Get a keychain value for the given key and access gropu
id getKeychainValueForKeyInAccessGroup(NSString *key, NSString *accessGroup) __deprecated;

/// Set a new value in the shared key store for a given key
void persistenceSetValue(NSString *key, id value);

/// Set a new value in the shared key store for a given key in and suit name
void persistenceSetValueInSuitName(NSString *key, id value, NSString *suitName);

/// Get a value from the shared key store for a given key
id persistenceGetValue(NSString *key);

/// Get a value from the shared key store for a given key and suit name
id persistenceGetValueInSuitName(NSString *key, NSString *suitName);
