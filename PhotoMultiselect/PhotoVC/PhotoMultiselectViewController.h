//
//  PhotoMultiselectViewController.h
//  TalkToWorld
//
//  Created by lidp on 2016/11/2.
//  Copyright © 2016年 对话世界. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

/**
 选中图片动画
 */
void photoMultiselectStartAnimation(UIView *view);

@interface PhotoMultiselectModel : NSObject

@property (strong, nonatomic) PHAsset   *asset;     /**< 资源 */
@property (assign, nonatomic) CGSize    thumbSize;  /**< 缩放大小 */
@property (strong, nonatomic) UIImage   *image;     /**< 解析资源后的图片 */
@property (assign, nonatomic) BOOL      isSelected; /**< 是否已选中 */

@end

@protocol PhotoMultiselectItemDelegate <NSObject>

@optional

/**
 选中照片回调
 */
- (void)selectedPhoto:(PhotoMultiselectModel *)model;

/**
 是否能选中图片（超过图片最多选择张数不能选中）
 */
- (BOOL)canSelectPhoto;

@end

@interface PhotoMultiselectItem : UICollectionViewCell

@property (assign, nonatomic) PhotoMultiselectModel *model;
@property (assign, nonatomic) id<PhotoMultiselectItemDelegate> delegate;

@end

/**
 图片多选控制器,默认选择9张
 */
@interface PhotoMultiselectViewController : UIViewController

@property (weak, nonatomic  ) PHAssetCollection *assetCollection;   /**< 相册 */
@property (assign, nonatomic) NSInteger         maxCount;           /**< 最多选择图片张数 */

@end
