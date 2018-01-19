//
//  UIColor+Hex.h
//  11
//
//  Created by 程利 on 2018/1/17.
//  Copyright © 2018年 foundersc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(long)hexColor;

+ (UIColor *)colorWithHex:(long)hexColor alpha:(CGFloat)opacity;

@end
