//
//  PhotoPreviewController.h
//  TalkToWorld
//
//  Created by lidp on 2016/11/2.
//  Copyright © 2016年 对话世界. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoMultiselectViewController.h"

@protocol PhotoPreviewItemDelegate <NSObject>

@optional
/**
 单击scrollview回调
 */
- (void)singleTapScrollView;

@end

@interface PhotoPreviewItem : UICollectionViewCell

@property (weak, nonatomic  ) PhotoMultiselectModel *model;
@property (assign, nonatomic) id<PhotoPreviewItemDelegate> delegate;

@end

/**
 图片多选预览控制器
 */
@interface PhotoPreviewController : UIViewController

@property (weak, nonatomic  ) NSMutableArray *dataSource;   /**< 数据源 */
@property (assign, nonatomic) NSInteger currentIndex;       /**< 当前显示第几张照片 */
@property (assign, nonatomic) NSInteger maxCount;           /**< 最多选择图片张数 */
@property (strong, nonatomic) NSMutableArray *selectedModelList;/**< 已选中的图片model列表 */
@property (copy, nonatomic  ) void (^onClickBackCallback)(NSMutableArray *selectedModelList);   /**< 点击返回回调 */
@property (copy, nonatomic  ) void (^onClickSendCallback)(NSMutableArray *selectedModelList);   /**< 点击发送回调 */

@end
