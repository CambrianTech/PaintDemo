//
//  CBRemodelingFloor.h
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import "CBAugmentedAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBRemodelingFloor : CBAugmentedAsset

@property (nonatomic, assign) float scale;
@property (nonatomic, strong, nonnull) NSString* path;

@end


NS_ASSUME_NONNULL_END
