//
//  HRNumView.m
//  11
//
//  Created by 程利 on 2018/1/15.
//  Copyright © 2018年 foundersc. All rights reserved.
//

#import "HRNumView.h"

@interface HRNumView ()

@property (nonatomic, strong) UILabel *numberLabel;;

@end

@implementation HRNumView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _numberLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _numberLabel.font = [UIFont boldSystemFontOfSize:40];
        _numberLabel.backgroundColor = [UIColor lightGrayColor];
        _numberLabel.textColor = [UIColor blueColor];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_numberLabel];
    }
    return self;
}

- (void)setNumber:(NSInteger)number
{
    _numberLabel.text = @(number).stringValue;
}

- (NSInteger)getNumber
{
    return [_numberLabel.text integerValue];
}

@end
