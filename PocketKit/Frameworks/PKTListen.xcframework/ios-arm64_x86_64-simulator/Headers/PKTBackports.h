//
//  PKTBackports.h
//  RIL
//
//  Created by Nicholas Zeltzer on 9/20/17.
//

@import UIKit;

@interface PKTBackports : NSObject

+ (instancetype)sharedInstance;

- (void)install;

@end
