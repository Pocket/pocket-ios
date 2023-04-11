//
//  PKTModelCodable.h
//  RIL
//
//  Created by Larry Tran on 8/12/18.
//

NS_ASSUME_NONNULL_BEGIN

@protocol PKTModelCodable <NSObject, NSCopying>

- (void)updateModel:(id)model;
- (NSDictionary *)dictionaryRepresentation;
- (NSDictionary *)diffingRepresentation;

@end

NS_ASSUME_NONNULL_END
