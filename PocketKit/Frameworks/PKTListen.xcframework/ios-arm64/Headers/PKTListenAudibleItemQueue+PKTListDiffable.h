//
//  PKTListenAudibleItemQueue+PKTListDiffable.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenAudibleItemQueue.h"
#import "PKTKusari.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAudibleItemQueue (PKTListDiffable) <PKTListDiffable>

- (id<NSObject>)diffIdentifier;

- (BOOL)isEqualToDiffableObject:(id<PKTListDiffable>)object;

@end

NS_ASSUME_NONNULL_END
