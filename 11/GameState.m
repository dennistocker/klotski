//
//  GameState.m
//  11
//
//  Created by 程利 on 2018/1/15.
//  Copyright © 2018年 foundersc. All rights reserved.
//

#import "GameState.h"

@implementation GameState

- (int)compareTo:(id<Comparable,NSObject>)object {

    int result = -1;

    if ([object isKindOfClass:[self class]]) {
        GameState *other = object;

        if (self.f == other.f) {
            result = 0;
        } else if (self.f > other.f) {
            result = 1;
        } else {
            result = -1;
        }
    }

    return result;
}

- (BOOL)isEqual:(id)object {
    BOOL isEqual = FALSE;

    if ([object isKindOfClass:[self class]]) {
        GameState *other = object;
        isEqual = (_numbers.count == other.numbers.count);
        if (isEqual) {
            for (int i = 0; i < _numbers.count; ++i) {
                if (_numbers[i] != other.numbers[i]) {
                    isEqual = FALSE;
                    break;
                }
            }
        }
    }
    return isEqual;
}

- (void)setNumbers:(NSArray<NSNumber *> *)numbers {
    _numbers = numbers;

    _h = 0;
    for (int i = 0; i < _numbers.count; ++i) {
        NSInteger number = [_numbers[i] integerValue];
        int x = i / 3;
        int y = i % 3;
        int desX = (int) (number-1) / 3;
        int desY = (int) (number-1) % 3;

        if (number == 0) {
            _x = x;
            _y = y;
        } else {
            _h += ABS(desX - x);
            _h += ABS(desY - y);
        }
    }
}

- (NSInteger)f {
    return _g + _h;
}

- (NSString *)description
{
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendFormat:@"g:%@, h:%@, f:%@\n", @(_g), @(_h), @(self.f)];
    for (int i = 0; i < 3; ++i) {
        NSString *str = [[NSString alloc] initWithFormat:@"%@  %@  %@\n", _numbers[i*3], _numbers[i*3+1], _numbers[i*3+2]];
        [desc appendString:str];
    }

    return desc;
}

@end
