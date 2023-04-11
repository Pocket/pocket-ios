//
//  NSDate+PocketAdditions.h
//  Pocket
//
//  Created by Nate Weiner on 10/4/12.
//  Copyright (c) 2012 mischneider. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (PocketAdditions)

/// Returns a timestamp the time interval since 1970 date already casted to int
+ (int)timestamp;

/// Returns a timestamp the time interval since 1970 date as NSNumber and casted to int before
+ (NSNumber *)timestampNumber;

/// Returns time value to handle the download time of an app. This value is be used to save the last time a download happened and the item was added to device
+ (NSInteger)downloadTimeValue;

/// Returns relative date string representation of the receiver
- (NSString *)relativeDateString;

/// Returns the minutes between two given dates
+ (NSInteger)minutesBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime;

/// Returns the hours between two given dates
+ (NSInteger)hoursBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime;

/// Returns the days between two given dates
+ (NSInteger)daysBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime;

/// Returns the date components between two given dates
+ (NSDateComponents *)dateComponentsBetweenDate:(NSDate *)fromDateTime andDate:(NSDate *)toDateTime;

@end
