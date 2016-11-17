//
//  UILabel+ExtensionMethods.h
//  StudioShop
//
//  Created by 李代棚 on 15/3/26.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (ExtensionMethods)

/**
 *  快速创建一个自适应label,line为0时自适应高度，line为1时自适应宽度
 *
 *  @param frame    label frame
 *  @param text     label文字
 *  @param size     字号
 *  @param color    字体颜色
 *  @param line     行数
 *
 *  @return UILabel
 */
+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString*)text fontSize:(CGFloat)size textColor:(UIColor *)color line:(NSInteger)line;

+ (UILabel *)labelWithNoSizeFitFrame:(CGRect)frame text:(NSString*)text fontSize:(CGFloat)size textColor:(UIColor *)color line:(NSInteger)line;

/**
 *  设置每一行文字之间的间距
 *
 *  @param spacingValue 间距值
 */
- (void)setLineSpacing:(CGFloat)spacingValue;

/**
 *  设置行间距和字间距
 *
 *  @param lineSpacing      行间距
 *  @param characterSpacing 字间距
 */
- (void)setLineSpacing:(CGFloat)lineSpacing characterSpacing:(CGFloat)characterSpacing;

/**
 *  设置字间距
 *
 *  @param spacing 
 */
- (void)setCharacterSpacing:(CGFloat)spacing;

/**
 *  根据范围设置label的跨度文字颜色
 *
 *  @param range 范围
 */
- (void)setSpanColorByRange:(NSRange)range textColor:(UIColor*)color;

@end
