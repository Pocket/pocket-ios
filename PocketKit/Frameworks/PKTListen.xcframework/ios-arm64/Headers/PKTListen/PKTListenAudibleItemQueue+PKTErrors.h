//
//  PKTListenAudibleItemQueue+PKTErrors
//  PKTListen
//
//  Created by Nicholas Zeltzer on 9/23/18.
//  Copyright © 2018 PKT. All rights reserved.
//

#import "PKTListenAudibleItemQueue.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTListenAudibleItemQueue (PKTErrors)

- (void)stream:(PKTAudioStream *)stream
       didFail:(NSError *)error
    shouldStop:(inout BOOL *_Nullable)shouldStop;

- (void)synthesisDidFail:(NSError *)error
              shouldStop:(inout BOOL *_Nullable)shouldStop;

@end

NS_ASSUME_NONNULL_END
