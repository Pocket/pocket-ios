//
//  PKTJSONParser.h
//  RIL
//
//  Created by Nicholas Zeltzer on 3/6/17.
//
//

@import Foundation;

#import "PKTJSONPathLexer.h"

/**
 PKTJSONParser is a bottom-up parser for JSON objects that conforms to the JSONPath query syntax.
 
 To parse a JSON object, create a new parser instance, and apply PKTTransformation blocks using object subscripting.
 
 The subscript syntax should take the form of a valid JSONPath query. 
 
 Once all transformation blocks have been assigned, a JSON blob that can be parsed by calling parse:error: on the 
 newly created parser instance. 
 
    PKTJSONParser *parser = [PKTJSONParser new];

    // Parse all list items into PKTListItem instances.
    parser[@"$..list['*']"] = ^(PKTLList *path, id<NSObject>) {
        return [[PKTListItem alloc] initWithUserInfo:PKTDynamicCast(rawValue, NSDictionary)];
    };
 
    // Parse all list item destinationURL and icons into NSURLs
    parser[@"$.layouts..list['*']['destinationUrl', 'icon']"] = ^(PKTLList *path, id<NSObject> rawValue) {
        return [NSURL URLWithString:PKTDynamicCast(rawValue, NSString)];
    };
 
    // Parse all layout display attribute colors into UIColors.
    parser[@"$.layouts..displayAttributes['backgroundColor', 'fontColor'][*]"] = ^(PKTLList *path, id<NSObject> rawValue) {
        return [UIColor colorWithHexValue:PKTDynamicCast(rawValue, NSString)];
    };
 
    // Parse all backgroundColor and fontColor values into UIColors.
    parser[@"$..['backgroundColor', 'fontColor']['*']"] = ^(PKTLList *path, id<NSObject> rawValue) {
        return [UIColor colorWithHexValue:PKTDynamicCast(rawValue, NSString)];
    };
 
 Because PKTJSONParser is recursive, the second transformation, supra, will be applied before the first: when the 
 PKTListItem initializer is called, the dictionary provided will already have had its URL string values transformed
 to NSURL instances. 
 
 The last two expressions both affect identical key names: backgroundColor, and fontColor. 
 
 Once support for the JSONPath recursive descent operator (..) has been added, it will be possible to combine both of 
 these expressions into a single path: ..[backgroundColor, fontColor].
 
 */

NS_ASSUME_NONNULL_BEGIN;

@class PKTJSONPathContainer;
@class PKTJSONParser;

typedef id<NSObject>_Nonnull (^PKTJSONPathTransformation)(PKTLList *path, id<NSObject> value);

typedef NSDictionary<NSString *, PKTJSONPathContainer*> PKTJSONPathTransformationStore;

@interface PKTJSONParser : NSObject

/**
 Recursively parse a JSON structure by applying the transformation blocks to the keypaths that match the expressions
 they have been registered with.
 @param data The JSON data to parse.
 @param error An optional pointer to an NSError object to reference an underlying parse error.
 @return A parsed JSON structure, or nil, if the parsing fails.
 */

- (id<NSObject> _Nullable)parse:(NSData *)data
                          error:(NSError *__autoreleasing _Nullable *_Nullable)error;

- (id<NSObject> _Nullable)parseObject:(id _Nonnull)object
                                error:(NSError *__autoreleasing _Nullable *_Nullable)error;

/**
 Evaluate a JSONPath expression.
 @param JSONData The JSON data.
 @param expression The JSONPath expression to evaluate against the JSON blob.
 @param error If provided, the pointer to an NSError object describing a failure to parse, if any.
 @return NSArray containing the results of the expression as evaluated against the JSON contents, if any.
 */

+ (NSArray<id<NSObject>>*_Nullable)evaluate:(NSData *_Nonnull)JSONData
                        expression:(NSString *_Nonnull)expression
                             error:(NSError *__autoreleasing _Nullable *_Nullable)error;


+ (NSArray<id<NSObject>>*_Nullable)evaluateObject:(id _Nonnull)JSONObject
                              expression:(NSString *_Nonnull)expression
                                   error:(NSError *__autoreleasing _Nullable *_Nullable)error;

+ (NSArray<id<NSObject>>*_Nullable )evaluateURL:(NSURL *_Nonnull)fileURL
                                     expression:(NSString *_Nonnull)expression
                                          error:(NSError *__autoreleasing _Nullable *_Nullable)error;

#define PKTJSONEvaluateFirst(o, p, c) ({ PKTDynamicCast([PKTJSONParser evaluateObject:o expression:p error:nil].firstObject, c); })

@end

#pragma mark - PKTJSONParser+ObjectSubscripting

@interface PKTJSONParser (ObjectSubscripting)

- (id _Nullable)objectForKeyedSubscript:(NSString *_Nonnull)key;

- (void)setObject:(id _Nullable)obj forKeyedSubscript:(NSString *_Nonnull)key;

@end

#pragma mark - PKTJSONPathContainer

@interface PKTJSONPathContainer : NSObject {
@public PKTJSONPath **paths;
@public NSInteger path_count;
}

@property (nullable, nonatomic, readwrite, copy) PKTJSONPathTransformation transformation;

- (BOOL)addPath:(NSString *)aPath error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END;
