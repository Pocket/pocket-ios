//
//  PKTPocketHitsParser.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 10/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

@import Foundation;

/**
 PKTPocketHitsParser is an XML parser capable of parsing the Pocket Hits RSS feed.
 
 The parsed result takes the form of a list of dictionaries, matching the following signature:
 
 {
     category = (NSString)
     guid = (NSURL)
     link = (NSURL)
     pubDate = (NSString)
     title = (NSString)
 }
 
 */

NS_ASSUME_NONNULL_BEGIN

/// Default URI. Will be used if the URL initialization parameter is nil.
FOUNDATION_EXTERN NSString * const PKTPocketHitsURI;

@interface PKTPocketHitsParser : NSObject

/// @param feedURL The URL of the feed to parse.
- (instancetype)initWithURL:(NSURL *_Nullable)feedURL;

/// @param completion A completion block to manage the response. Required.
- (void)start:(void(^)(NSArray<NSDictionary<NSString*, id>*>*items, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
