//
//  CBAugmentedScene.m
//  CambrianAR
//
//  Created by Joel Teply on 3/3/17.
//  Copyright © 2017 Joel Teply. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CBAugmentedTypes.h"
#import "CBAugmentedAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBAugmentedScene : NSObject

@property (readonly, nonatomic, nonnull) NSString *sceneID;
@property (readonly, nonatomic, nonnull) NSDictionary<NSString *, CBAugmentedAsset *> *assets;
@property (readonly, nonatomic, nonnull) NSMutableDictionary<NSString *, NSString *> *userData;

@property (strong, nonatomic, nullable) CBAugmentedAsset *selectedAsset;
@property (strong, nonatomic, nullable) NSString *selectedAssetID;
@property (nonatomic, assign) CBLightingType lightingAdjustment;


- (nullable CBAugmentedScene *) initWithSceneID:(nonnull NSString*)sceneID;

- (nullable CBAugmentedScene *) initWithUIImage:(nonnull UIImage *)image;
- (nullable CBAugmentedScene *) initWithUIImage:(nonnull UIImage *)image sceneID:(nonnull NSString*)sceneID;

- (nullable CBAugmentedScene *) initWithPath:(nonnull NSString *)path;

+ (nullable UIImage *)getOriginal:(NSString *)path;
+ (nullable UIImage *)getPreview:(NSString *)path;
+ (nullable UIImage *)getThumbnail:(NSString *)path;
+ (nullable UIImage *)getBeforeAfter:(NSString *)imagePath isHorizontal:(BOOL)isHorizontal;

- (NSDictionary<NSString *, CBAugmentedAsset *>*)getAssets:(CBAssetType)type;

- (NSString *) saveToDirectory:(nonnull NSString *)path compressed:(BOOL)compress;

- (BOOL) appendAsset:(nonnull CBAugmentedAsset *)asset;

- (BOOL) removeAsset:(nonnull NSString *)assetID;

@end

NS_ASSUME_NONNULL_END
