//
//  PKTListenAudibleItemQueue+PKTPlaybackControlEvent.h
//  PKTListen
//
//  Created by Nicholas Zeltzer on 8/29/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenAudibleItemQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAudibleItemQueue (PKTPlaybackControlEvent) <PKTAudibleQueue>

- (void)play:(NSString *_Nullable)context;

- (void)pause:(NSString *_Nullable)context;

- (void)scanForwards:(NSString *_Nullable)context;

- (void)scanBackwards:(NSString *_Nullable)context;

- (void)stagePrevious:(NSString *_Nullable)context;

- (void)stageNext:(NSString *_Nullable)context;

- (void)archive:(NSString *_Nullable)context;

- (void)restartIdleTimer;

@end

NS_ASSUME_NONNULL_END
