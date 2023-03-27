//
//  ExtendDictionary.h
//  RIL
//
//  Created by Nathan Weiner on 11/6/09.
//  Copyright 2009 Idea Shower, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/* Search values for a given search key in nested dictionaries. E.g. if you want to search for all values with the "tag" key in the following nested dictionary:
 
    NSDictionary *tags = @{
        @"politics" : @{
            @"tag" : @"politics",
            @"unique_id" : @750
        },
        @"apple": @{
            @"tech" : @{
                @"tag" : @"apple.tech",
                @"unique_id" : @100
            }
        }
    };
 */
void pkt_searchForValueInNestedDictionary(NSString *searchKey, NSDictionary *dictionary, NSMutableArray *result);


@interface NSDictionary (PocketAdditions)

/// Returns an long long for a NSNumber or NSString of the given key
- (long long)longValueForKey:(id)key;

/// Returns an int for the value (should be an NSNumber) of the given key
- (int)intForKey:(id)key;

/// Returns an int for the value of the given key or retusn 0 if the value for the given key is nil or of kind NSNull
- (int)intForForKeyHandleNull:(id)key;

/// Returns a NSNumber object for the value of the given key
- (NSNumber *)PKTNumberForKey:(NSString *)key;

/// Returns a NSNumber object for the value of the given key or returns 0 if the value for the given key is nil or of kind NSNull
- (NSNumber *)numberForKeyHandleNull:(NSString *)key;

/// Returns a encoded NSURL object for the value of the given key
- (NSURL *)urlForKey:(NSString *)key;

/// Returns a NSDate object for the int value for the given key
- (NSDate *)dateForKey:(NSString *)key;

/// Returns a NSString object for the value for the given key
- (NSString *)stringForKey:(NSString *)key;

/// Returns a bool for the given key
- (BOOL)boolForKey:(NSString *)key;

/// Returns an empty string if the value for the given key is nil
- (id)sin:(NSString *)key;

/// Returns a 0 as NSNumber number if the value for the given key is nil
- (id)nin:(NSString *)key;

/// Retursn the SHA1Hash for the receiver
- (NSString *)SHA1Hash;

/// Returns a new dictionary by merging the receiver with the given dictionary
- (NSDictionary *)dictionaryByMergingDictionary:(NSDictionary *)dictionary __deprecated;

/// Because a NSString and NSNumber of the same value (ex "1") are technically different keys, this takes either strings or numbers and looks up in an index created by numbers
- (id)objectForAnyTypeOfKeyOnNumberIndex:(id)aKey;

/// Grab the first key of the receiver and return the value for that
- (id _Nullable)aValue;

/// Returns the URL encoded string for usage as path component of an URL.
- (NSString *)URLEncodedString;

@property (nullable, nonatomic, readonly) NSDictionary *JSONObject;

@property (nullable, nonatomic, readonly) NSData *JSONData;

@property (nonnull, nonatomic, readonly, copy) NSString *_Nullable (^JSONStringWithEncoding)(NSStringEncoding);

/**
 @return A NSDictionary that contains only keys and values that pass the validation block.
 */

@property (nonnull, nonatomic, readonly) NSDictionary * (^filtered)(BOOL(^)(id<NSCopying, NSObject> key, id value));

/**
 @return NSDictionary the contains the keys and values of both the receiver, and the provided dictionary.
 @discussion Where both dictionaries contain valid values for the same key, the provided dictionary's values will trump the values of the receiver.
 @note Passing a nil value will remove the key/value pair for a preexisting key.
 */

@property (nonnull, nonatomic, readonly) NSDictionary * (^merged)(NSDictionary *_Nullable dictionary);

/**
 @return NSDictionary that represents a copy of the receiver, with all [NSNull null] key-value pairs removed.
 */

@property (nonnull, nonatomic, readonly) NSDictionary * (^normalized)(void);

/**
 @return a copy of the receive that has added the provided key/value pair.
 @note The utility of this method is that it defends itself against nil and NSNull values.
 */

@property (nonnull, nonatomic, readonly) NSDictionary * (^added)(id<NSObject, NSCopying> _Nullable key, id _Nullable value);

/**
 @return a copy receiver after having removed the the provided key and its associated value.
 @note The utility of this method is that it defends itself against nil and NSNull values.
 */

@property (nonnull, nonatomic, readonly) NSDictionary * (^removed)(id<NSObject, NSCopying> _Nullable key);

/**
 @return a block that will transform the dictionary into a parameterized URL string, suitable for use in an HTTP request.
 @param leadingCharacter optional string that will be used as a prefix to the parameterized string returnd from the block
 @param escaped if YES, the string returned from the block will be escaped using the URLQueryAllowedCharacterSet
 */

@property (nonnull, nonatomic, readonly, copy) NSString * (^parameterizedString)(NSString *leadingCharacter, BOOL escaped);

@end


@interface NSMutableDictionary (PocketAdditions)

/// Set the object value for the key if the key or object is not nil
- (void)safe_setObject:(id)obj forKey:(NSString *)key;

/// Returns a new mutable dictionary by merging the receiver with the given dictionary
- (NSMutableDictionary *)dictionaryByMergingDictionary:(NSDictionary *)dictionary;

- (void)setValueAndFillToPath:(id)value forKeyPath:(NSString *)keyPath;
- (void)fillWithDictionariesToKeyPath:(NSString *)keyPath;

/**
 Remove alls keys-value pairs that do not pass the provided filter block.
 @return The receiver
 */

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^filter)(BOOL(^)(id<NSCopying, NSObject> key, id value));

/**
 Merge the keys and values of the receiver and the provided dictionary.
 @discussion Where both dictionaries contain valid values for the same key, the provided dictionary's values will trump the values of the receiver.
 @return The receiver
 @note Passing a nil value will remove the key/value pair for a preexisting key.
 */

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^merge)(NSDictionary *_Nullable dictionary);

/**
 @return the receiver after having removed all [NSNull null] key-value pairs removed.
 */

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^normalize)(void);

/**
 @return the receiver after having added set the provided value for the provide key.
 @note The utility of this method is that it defends itself against nil and NSNull values. 
 */

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^add)(id<NSObject, NSCopying> _Nullable key, id _Nullable value);

/**
 @return the receiver after having removed the the provided key and its associated value.
 @note The utility of this method is that it defends itself against nil and NSNull values.
 */

@property (nonnull, nonatomic, readonly) NSMutableDictionary * (^remove)(id<NSObject, NSCopying> _Nullable key);

@end

NS_ASSUME_NONNULL_END
