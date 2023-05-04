//
//  ExtendString.h
//  ReadItLater
//
//  Created by Nathan Weiner on 2/20/09.
//  Copyright 2009 Idea Shower. All rights reserved.
//

@import Foundation;

@class PKTItem;

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PocketAdditions)

@property (nonatomic, readonly) NSString * (^join)(NSString *__nullable);

@property (readonly) long longValue;

/// Returns a new string made by removing whitespaces from both ends of the receiver
- (NSString *)trim;

/// Returns a new string made by removing " ," from both ends of the receiver
- (NSString *)trimTag;

/// Truncate string to a specific number of characters
- (NSString *)trunicateTo:(NSInteger)characters;

/// Truncate string to a specific number of characters and add ellipsis if wanted
- (NSString *)trunicateTo:(NSInteger)characters ellipsis:(BOOL)ellipsis;

/// Returns a new string by adding percent escapes using NSUTF8StringEncoding encoding
- (NSString *)stringByAddingPercentEscapes;

/// Returns a new string by adding percent escapes using NSUTF8StringEncoding encoding except for hash
- (NSString *)stringByAddingPercentEscapesExceptForHash;

/// Returns a new string for usage in urls based on the receiver
- (NSString *)urlEncoded;

/// Returns a new string for usage in urls based on the receiver. If wanted the receiver can be percent escaped before
- (NSString *)urlEncoded:(BOOL)decodeFirst;

/// Returns a new string for that are used in urls based on the receiver
- (NSString *)urlDecoded;

/// Collapse multiple white spaces into one. Example: "Hello     World" => "Hello World"
- (NSString *)cleanDisplayString;

/// New string with all line breaks removed from the receiver
- (NSString *)stringByRemovingLineBreaks;

/// New string by replacing all occurences of a given regex expression with a given string
- (NSString *)stringByReplacingOccurrencesOfRegex:(NSString *)expression withString:(NSString *)string;

/// Check if receiver has a match for the given regex
- (BOOL)isMatchedByRegex:(NSString *)expression;

/// Determines if the receiver is an email address
- (BOOL)isEmailAddress;

/// Returns all matches from the receiver for a given regex
- (NSArray *)matchesForRegex:(NSString *)expression;
//- (NSString *)stringBySlashingApostrophes;

/// Returns a new string escaped for usage within sqlite
- (NSString *)stringByEscapingForSQLite;

/// Returns the sha1 hash of the receiver
- (NSString *)SHA1Hash;

/// Returns the receiver as Base64 encoded string
- (NSString *)stringByBase64EncodingString;

/// Expect that the receiver is a Base64 Encoded string and decodes the receiver
- (NSString *)stringByBase64DecodingString;

/// Expect that the receiver is a Base64 Encoded data object and decodes the receiver
- (NSData   *_Nullable)dataByBase64DecodingString;

/// Returns the string as data with NSUTF8StringEncoding encoding
- (NSData *)UTF8Data;

/// Creates a random ascii string for a given length
+ (NSString *)randomASCIIStringWithLength:(NSUInteger)length;

/// Determines if the receiver string contains the substring
- (BOOL)containsString:(NSString *)substring;

/**
 @return The first URL parsed from the string's contents.
 @note Implementation wraps NSDataDetector link parsing.
 */

- (NSURL *__nullable)PKTFirstURLMatch;

/**
 Check to see if this string equates with any string in the array.
 @return The index of the matching string; otherwise, NSNotFound.
 @param strings NSArray of NSString values.
 */

- (NSInteger)PKTIndexOfAny:(nonnull NSArray<NSString*>*)strings;

/// Returns a underscore version of the string
- (NSString *)snakeCaseFromCamelCase;

// Returns a camel case version of the string
- (NSString *)camelCaseFromSnakeCase;

// Return NSString representation of all English consonsants in the string, in the order encountered.
- (NSString *_Nullable)consonants;

@end



@interface NSMutableString (PocketAdditions)

@property (nonatomic, readonly) NSMutableString * (^join)(NSString *__nullable);

@property (readonly) long longValue;

/// Replaces all occurens of a string within the receiver with a given string
- (NSInteger)replaceOccurrencesOfRegexString:(NSString *)pattern withString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
