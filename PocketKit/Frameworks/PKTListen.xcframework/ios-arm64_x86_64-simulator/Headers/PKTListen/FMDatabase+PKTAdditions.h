//
//  FMDatabase+PKTAdditions.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 4/28/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "FMDatabase.h"

@interface FMDatabase (PKTAdditions)

- (void)captureDatabaseErrorEvent;

@end
