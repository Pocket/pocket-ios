//
//  NSCountedSet+PKTAdditions.h
//  PKTRuntime
//
//  Created by Nicholas Zeltzer on 2/16/19.
//  Copyright © 2019 Pocket. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface NSCountedSet (PKTAdditions)

@property (nonatomic, readonly, strong, nonnull) NSDictionary<id, NSNumber*> *dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
