//
//  GetListOperation.h
//  RIL
//
//  Created by Nate Weiner on 10/19/11.
//  Copyright (c) 2011 Pocket All rights reserved.
//

#import "DataOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface GetListOperation : DataOperation

- (NSMutableDictionary *)getListWithParameters:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END
