//
//  UIImage+ExtensionMethods.m
//  XiaoZhuang
//
//  Created by lidp on 15/9/16.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import "UIImage+ExtensionMethods.h"

@implementation UIImage (ExtensionMethods)

+ (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+ (UIImage *)thumbnailWithImage:(UIImage *)image size:(CGSize)asize{
    UIImage *newimage;
    if (nil == image) {
        newimage = nil;
    }else{
        UIGraphicsBeginImageContext(asize);
        [image drawInRect:CGRectMake(0, 0, asize.width, asize.height)];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}

+ (UIImage *)imageWithRatio:(CGFloat)ratio sourceImage:(UIImage *)sourceImage{
    CGSize imageSize = sourceImage.size;
    
    //计算宽高
    CGFloat croppedWidth = MIN(imageSize.width, imageSize.height);
    CGFloat croppedHeight = croppedWidth * ratio;
    
    //计算x,y值
    CGFloat croppedX = (imageSize.width - croppedWidth) / 2;
    CGFloat croppedY = (imageSize.height - croppedHeight) / 2;
    
    //得到缩放后的图片并裁剪
    CGRect rect = CGRectMake(croppedX, croppedY ,croppedWidth, croppedHeight);
    CGImageRef imageRef = CGImageCreateWithImageInRect([sourceImage CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}

+ (void)compressMessageImage:(UIImage *)image callback:(void (^)(UIImage *, NSData *))callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        __block UIImage *resultImage = nil;
        __block NSData *data = nil;
        @autoreleasepool {
            data = UIImageJPEGRepresentation(image, 0.6);
            //大于2MB，压缩图片
            if (data.length > 2048 * 1024) {
                float scale = data.length / (2048 * 1024.0f);
                resultImage = [UIImage thumbnailWithImage:image size:CGSizeMake(image.size.width / scale, image.size.height / scale)];
                data = UIImageJPEGRepresentation(resultImage, 0.6);
            }else{
                resultImage = image;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (resultImage && data && callback) {
                callback(resultImage, data);
            }
        });
    });
}

@end
