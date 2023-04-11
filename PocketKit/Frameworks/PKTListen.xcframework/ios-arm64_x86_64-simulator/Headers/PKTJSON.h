//
//  PKTJSON.h
//  RIL
//
//  Created by Michael Schneider on 12/15/13.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData(PKTJSON)

- (id)JSONObject;
- (id)mutableJSONObject;
+ (NSData *_Nullable)JSONData:(id)object;
+ (NSData *_Nullable)prettyJSONData:(id)object;

@end


@interface NSString (PKTJSON)

- (id)JSONObject;
- (id)mutableJSONObject;
+ (NSString *)JSONString:(id)object;
+ (NSString *)prettyJSONString:(id)object;

@end


@interface NSDictionary(PKTJSON)

- (NSString *)JSONString;
- (NSString *)prettyJSONString;

@end


@interface NSArray(PKTJSON)

- (NSString *)JSONString;
- (NSString *)prettyJSONString;

@end

NS_ASSUME_NONNULL_END
