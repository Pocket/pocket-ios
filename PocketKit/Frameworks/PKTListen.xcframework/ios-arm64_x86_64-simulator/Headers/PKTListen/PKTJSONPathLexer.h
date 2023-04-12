//
//  PKTJSONPathLexer.h
//  RIL
//
//  Created by Nicholas Zeltzer on 4/13/17.
//
//

/* Adopted from JSON-GLib.
 * Original license, infra, applies.
 */

/* This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library. If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *   Emmanuele Bassi  <ebassi@linux.intel.com>
 */

#import <Foundation/Foundation.h>
#import "PKTJSONPathTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface PKTJSONPathLexer : NSObject

BOOL PKTJSONPathCompile(PKTJSONPath *path, const char *expression, NSError **error);
NSString * PKTJSONPathDescription(PKTLList * list);

@end

NS_ASSUME_NONNULL_END
