//
//  UIButton+ExtensionMethods.h
//  StudioShop
//
//  Created by 李代棚 on 15/3/26.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ExtensionMethods)

/**
 *  初始化按钮
 *
 *  @param frame  按钮frame
 *  @param target 按钮在哪个类执行方法
 *  @param action 执行的方法
 *
 *  @return UIButton
 */
+ (id)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

@end
