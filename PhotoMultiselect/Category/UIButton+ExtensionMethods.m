//
//  UIButton+ExtensionMethods.m
//  StudioShop
//
//  Created by 李代棚 on 15/3/26.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import "UIButton+ExtensionMethods.h"
@implementation UIButton (ExtensionMethods)

+ (id)buttonWithFrame:(CGRect)frame target:(id)target action:(SEL)action{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor clearColor];
    btn.frame = frame;
    //不可同时点击两个按钮
    [btn setExclusiveTouch:YES];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

@end
