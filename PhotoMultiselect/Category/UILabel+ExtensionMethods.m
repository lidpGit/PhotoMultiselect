//
//  UILabel+ExtensionMethods.m
//  StudioShop
//
//  Created by 李代棚 on 15/3/26.
//  Copyright (c) 2015年 lidp. All rights reserved.
//

#import "UILabel+ExtensionMethods.h"

@implementation UILabel (ExtensionMethods)

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString*)text fontSize:(CGFloat)size textColor:(UIColor *)color line:(NSInteger)line{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:size];
    label.text = [NSString stringWithFormat:@"%@",text];
    label.numberOfLines = line;
    [label sizeToFit];
    return label;
}

+ (UILabel *)labelWithNoSizeFitFrame:(CGRect)frame text:(NSString*)text fontSize:(CGFloat)size textColor:(UIColor *)color line:(NSInteger)line{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = color;
    label.font = [UIFont systemFontOfSize:size];
    label.text = [NSString stringWithFormat:@"%@",text];
    label.numberOfLines = line;
    return label;
}

- (void)setLineSpacing:(CGFloat)spacingValue{
    if (!self.text) {
        return;
    }
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:spacingValue];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
    [self setAttributedText:attributedString];
    [self sizeToFit];
}

- (void)setLineSpacing:(CGFloat)lineSpacing characterSpacing:(CGFloat)characterSpacing{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
    [attributedString addAttribute:NSKernAttributeName value:@(characterSpacing) range:NSMakeRange(0, [self.text length])];
    [self setAttributedText:attributedString];
    [self sizeToFit];
}

- (void)setCharacterSpacing:(CGFloat)spacing{
    if (!self.text) {
        return;
    }
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributedString addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [self.text length])];
    [self setAttributedText:attributedString];
    [self sizeToFit];
}

- (void)setSpanColorByRange:(NSRange)range textColor:(UIColor *)color{
    if (!self.text) {
        return;
    }
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:self.text];
    [attributed addAttributes:@{NSForegroundColorAttributeName:color} range:range];
    [self setAttributedText:attributed];
    [self sizeToFit];
}

@end
