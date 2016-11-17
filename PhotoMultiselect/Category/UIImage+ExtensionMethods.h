//
//  UIImage+ExtensionMethods.h
//  XiaoZhuang
//
//  Created by lidp on 15/9/16.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ExtensionMethods)

/**
 *  根据颜色创建一个image
 *
 *  @param color 颜色对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  压缩图片
 *
 *  @param image 原图
 *  @param asize 设置的图片大小
 */
+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize;

/**
 *  按高/宽比例裁剪图片，以图片中心点向边缘裁剪
 *
 *  @param ratio        高/宽的比例，要裁剪正方形比例传1
 *  @param sourceImage  原图片
 */
+ (UIImage *)imageWithRatio:(CGFloat)ratio sourceImage:(UIImage *)sourceImage;

/**
 压缩图片
 */
+ (void)compressMessageImage:(UIImage *)image callback:(void (^)(UIImage *result, NSData *data))callback;

@end
