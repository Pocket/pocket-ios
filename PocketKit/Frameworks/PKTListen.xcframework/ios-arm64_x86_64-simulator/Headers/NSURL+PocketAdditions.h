//
//  ExtendURL.h
//  ReadItLater
//
//  Created by Nathan Weiner on 2/20/09.
//  Copyright 2009 Idea Shower. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (PocketAdditions)

@property (nonatomic, readonly, copy, nullable) NSString *uniformTypeIdentifier;

/**
 @return YES, if the URL host is one of the enumerated Pocket domains; otherwise, returns NO.
 */

@property (nonatomic, readonly) BOOL isPocketURL;

/**
 @return YES, if the URL scheme is HTTPS; otherwise, returns NO.
 */

@property (nonatomic, readonly) BOOL isHTTPS;

@property (nonatomic, assign, getter=isExcludedFromBackup) BOOL excludedFromBackup;

// Returns a representation of the receiver using the NSUTF8StringEncoding
+ (NSURL *_Nullable)URLWithStringEncode:(NSString *_Nullable)url;

// Returns a representation of the receiver using the NSUTF8StringEncoding together with the relativeToURL path
+ (NSURL *_Nullable)URLWithStringEncode:(NSString *)url relativeToURL:(NSURL *)baseURL;

/// Returns a new string made by replacing in the receiver all percent escapes with the NSUTF8StringEncoding
- (NSString *_Nullable)decoded;

/// Replace #! with ?_escaped_fragment_=
- (NSURL *_Nullable)unhashbang;

/// Returns true if the path extension conforms to an image type (kUTTypeImage)
- (BOOL)isImageType;

/// Get a dictionary with key value pairs from the query string from the URL. If the receiver does not conform to RFC 1808, returns nil. For example, in the URL http://www.example.com/index.php?key1=value1&key2=value2, the query string is key1=value1&key2=value2
- (NSDictionary *)queryDictionary;

/// Create a dictionary with pieces from the url
- (NSDictionary *)piecesDictionary;

/// Return fileURL pointing to shared container.

NSURL *_Nullable PKTSharedContainerURL(void);

/// Return fileURL pointing to Documents directory.

NSURL *_Nullable PKTDocumentsDirectoryURL(void);

/**
 @return NSURL copy of the receiver with the HTTPS scheme.
 @note If the URL already uses the HTTPS scheme, the receiver will be returned.
 */

- (NSURL *)HTTPSEquivalent;

+ (NSURL *)imageCacheUrl:(NSURL *)url size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
