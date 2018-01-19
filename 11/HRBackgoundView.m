//
//  HRBackgoundView.m
//  11
//
//  Created by 程利 on 2018/1/15.
//  Copyright © 2018年 foundersc. All rights reserved.
//

#import "HRBackgoundView.h"
#import "UIColor+Hex.h"

@implementation HRBackgoundView {
    NSInteger _level;
}

- (instancetype)initWithFrame:(CGRect)frame andLevel:(NSInteger)level
{
    self = [super initWithFrame:frame];
    if (self) {
        _level = level;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat lineWidth = 2;

//    CGFloat left = CGRectGetMinX(rect)+lineWidth/2;
//    CGFloat top = CGRectGetMinY(rect)+lineWidth/2;
//    CGFloat right = CGRectGetMaxX(rect)-lineWidth/2;
//    CGFloat bottom = CGRectGetMaxY(rect)-lineWidth/2;
//    CGFloat width = (CGRectGetWidth(rect)-lineWidth) / _level;
//    CGFloat height = (CGRectGetHeight(rect)-lineWidth) / _level;

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectInset(rect, 1, 1)];
//    for (int i = 0; i <= _level; ++i) {
//        [path moveToPoint:CGPointMake(left, top + height*i)];
//        [path addLineToPoint:CGPointMake(right, top + height*i)];
//
//        [path moveToPoint:CGPointMake(left + width*i, top)];
//        [path addLineToPoint:CGPointMake(left + width*i, bottom)];
//    }

    path.lineCapStyle = kCGLineCapRound;
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = lineWidth;

    [[UIColor colorWithHex:0x5C656B] setStroke];

    [path stroke];
}

@end
