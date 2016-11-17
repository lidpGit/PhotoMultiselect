//
//  UIView+ExtensionMethods.h
//  shine
//
//  Created by 李代棚 on 15/4/13.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^Completion)(void);

@interface UIView (ExtensionMethods)

@property (assign, nonatomic) CGFloat viewWidth;    /**< 视图宽度 */
@property (assign, nonatomic) CGFloat viewHeight;   /**< 视图高度 */
@property (assign, nonatomic) CGFloat viewX;        /**< 视图x值 */
@property (assign, nonatomic) CGFloat viewY;        /**< 视图y值 */
@property (assign, nonatomic) CGFloat centerX;      /**< 中心点x值 */
@property (assign, nonatomic) CGFloat centerY;      /**< 中心点y值 */
@property (assign, nonatomic) CGSize size;          /**< 设置高宽 */
@property (assign, nonatomic) CGPoint origin;       /**< 设置x,y */
@property (assign, nonatomic, readonly) CGFloat viewMaxX;     /**< 视图x值+宽度 */
@property (assign, nonatomic, readonly) CGFloat viewMaxY;     /**< 视图y值+高度 */

/**
 *  设置圆角
 *
 *  @param radius 半径
 */
- (void)setCornerRadiur:(CGFloat)radius;

/**
 *  设置边框
 *
 *  @param borderWidth 边框宽度
 *  @param color       边框颜色
 */
- (void)setBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;

/**
 *  设置阴影
 *
 *  @param color   阴影颜色
 *  @param opacity 不透明度
 *  @param offset  偏移量
 */
- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset;

@end
