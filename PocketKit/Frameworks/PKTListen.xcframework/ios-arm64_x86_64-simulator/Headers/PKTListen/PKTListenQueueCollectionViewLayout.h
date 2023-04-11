//
//  PKTListenQueueCollectionViewLayout.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/7/18.
//  Copyright © 2018 Pocket. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface PKTListenQueueCollectionViewLayout : UICollectionViewFlowLayout

typedef struct _PKTDrawerContentLayoutBoundaries PKTDrawerContentLayoutBoundaries;

struct _PKTDrawerContentLayoutBoundaries {
    CGFloat minimum;
    CGFloat maximum;
};

@end


NS_ASSUME_NONNULL_END
