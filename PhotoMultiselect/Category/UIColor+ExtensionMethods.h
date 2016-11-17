//
//  UIColor+ExtensionMethods.h
//  XiaoZhuang
//
//  Created by lidp on 15/9/16.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ExtensionMethods)

/**
 *  16进制颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;

@end
