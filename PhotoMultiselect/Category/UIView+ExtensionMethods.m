//
//  UIView+ExtensionMethods.m
//  shine
//
//  Created by 李代棚 on 15/4/13.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import "UIView+ExtensionMethods.h"

@implementation UIView (ExtensionMethods)

- (void)setViewWidth:(CGFloat)viewWidth{
    CGRect frame = self.frame;
    frame.size.width = viewWidth;
    self.frame = frame;
}

- (CGFloat)viewWidth{
    return self.frame.size.width;
}

- (void)setViewHeight:(CGFloat)viewHeight{
    CGRect frame = self.frame;
    frame.size.height = viewHeight;
    self.frame = frame;
}

- (CGFloat)viewHeight{
    return self.frame.size.height;
}

- (void)setViewX:(CGFloat)viewX{
    CGRect frame = self.frame;
    frame.origin.x = viewX;
    self.frame = frame;
}

- (CGFloat)viewX{
    return self.frame.origin.x;
}

- (void)setViewY:(CGFloat)viewY{
    CGRect frame = self.frame;
    frame.origin.y = viewY;
    self.frame = frame;
}

- (CGFloat)viewY{
    return self.frame.origin.y;
}

- (void)setCenterX:(CGFloat)centerX{
    self.center = CGPointMake(centerX, self.centerY);
}

- (CGFloat)centerX{
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY{
    self.center = CGPointMake(self.centerX, centerY);
}

- (CGFloat)centerY{
    return self.center.y;
}

- (CGSize)size{
    return self.frame.size;
}

- (void)setSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGPoint)origin{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)viewMaxX{
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)viewMaxY{
    return CGRectGetMaxY(self.frame);
}

- (void)setCornerRadiur:(CGFloat)radius{
    self.layer.cornerRadius  = radius;
    self.layer.masksToBounds = YES;
}

- (void)setBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color{
    self.layer.borderWidth = borderWidth;
    self.layer.borderColor = color.CGColor;
}

- (void)setShadowColor:(UIColor *)color opacity:(CGFloat)opacity offset:(CGSize)offset{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOpacity = opacity;
    self.layer.shadowOffset = offset;
}

@end
