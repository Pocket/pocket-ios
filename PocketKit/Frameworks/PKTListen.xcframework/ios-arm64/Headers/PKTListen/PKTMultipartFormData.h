//
//  PKTMultipartFormData.h
//  RIL
//
//  Created by Steve Streza on 1/29/13.
//
//

#import <Foundation/Foundation.h>

@interface PKTMultipartFormData : NSObject

@property (nonatomic, strong) NSString *boundary;
@property (nonatomic, readonly, strong) NSData *data;

- (void)setValue:(id)value forKey:(NSString *)key;
- (void)addFileNamed:(NSString *)name withData:(NSData *)data forKey:(NSString *)key;
- (void)addContentsOfURL:(NSURL *)fileURL forKey:(NSString *)key;

@end

@interface PKTMultipartFormFile : NSObject

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, readonly, strong) NSString *MIMEType;

+ (instancetype)fileWithURL:(NSURL *)url;
+ (instancetype)fileWithData:(NSData *)data filename:(NSString *)filename;

@end
