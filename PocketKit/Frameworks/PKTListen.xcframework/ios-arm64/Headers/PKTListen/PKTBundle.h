//
//  PKTBundle.h
//  PKTListen
//
//  Created by Daniel Brooks on 3/24/23.
//  Copyright © 2023 PKT. All rights reserved.
//

#ifndef PKTBundle_h
#define PKTBundle_h

// Helpers
#define BUNDLE_NAME       @"PKTListenResources.bundle"
#define BUNDLE_IDENTIFIER @"com.ReadItLaterPro.PKTListenResources"
#define BUNDLE_PATH       [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: BUNDLE_NAME]
#define PKTListenResourceBundle [NSBundle bundleWithPath: BUNDLE_PATH]

#endif /* PKTBundle_h */
