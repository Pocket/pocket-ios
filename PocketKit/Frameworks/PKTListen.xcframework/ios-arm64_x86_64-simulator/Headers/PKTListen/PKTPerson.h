//
//  PKTPerson.h
//  RIL
//
//  Created by Steve Streza on 10/18/12.
//
//

@import UIKit;

#import "PKTSharedEnums.h"

@protocol PKTPerson <NSObject, NSCoding>
@property (nonatomic, copy, readonly, nullable) NSString *avatarSrc;
@property (nonatomic, copy, readonly, nullable) NSString *fullName;
@property (nonatomic, copy, readonly, nullable) NSString *email;
@end
