//
//  FMResultSet+PKTAdditions.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 4/28/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import "FMResultSet.h"

@interface FMResultSet (PKTAdditions)

- (NSDictionary *)resultDictAsStrings:(BOOL)useStrings;

@end
