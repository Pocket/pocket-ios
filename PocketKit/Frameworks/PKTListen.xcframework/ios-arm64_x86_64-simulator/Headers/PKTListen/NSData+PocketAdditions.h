//
//  NSData+PocketAdditions.h
//  RIL
//
//  Created by Steve Streza on 8/30/12.
//
//

#import <Foundation/Foundation.h>

@interface NSData (PocketAdditions)

/// Create Encoded String from Base64 Decoded Data
- (NSString *)stringByBase64EncodingData;

/// Create Decoded String from Base64 Encoded Data
- (NSString *)stringByBase64DecodingData;

/// Create string with NSUTF8StringEncoding from NSData
- (NSString *)UTF8String;

@end
