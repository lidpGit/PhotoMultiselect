//
//  PhotoGroupListViewController.h
//  PhotoMultiselect
//
//  Created by lidp on 2016/11/17.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface PhotoGroupModel : NSObject

@property (assign, nonatomic) NSInteger count;      /**< 图片张数 */
@property (strong, nonatomic) PHAsset *lastAsset;   /**< 相册最后一张图片资源 */
@property (strong, nonatomic) UIImage *image;       /**< 解析资源后的图片 */
@property (strong, nonatomic) PHAssetCollection *assetCollection;   /**< 相册 */

@end

@interface PhotoGroupCell : UITableViewCell

@property (strong, nonatomic) PhotoGroupModel *model;

@end

@interface PhotoGroupListViewController : UIViewController

@property (assign, nonatomic) NSInteger maxCount; /**< 最多选择图片张数 */
@property (copy, nonatomic  ) void (^clickFinishCallback)(NSMutableArray *imageList); /**< 选择完照片回调 */

/**
 显示图片多选控制器

 @param fromVC   从哪个控制器跳转
 @param count    选择图片张数
 @param callback 选择完图片回调
 */
+ (void)showPhotoPhotoMultiselectVCWithFromVC:(UIViewController *)fromVC
                                        count:(NSInteger)count
                        selectedImageCallback:(void (^)(NSMutableArray *imageList))callback;

@end
