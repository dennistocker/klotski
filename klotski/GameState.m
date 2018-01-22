
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

//    _desState = [[GameState alloc] init];
//    _desState.numbers = @[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(0)];
//
//    // 算法
//    NSLog(@"=== begin");
//    _openNodes = [[PriorityQueue alloc] init];
//    _closedNodes = [[NSMutableArray alloc] init];
//
//    GameState *initialState = [[GameState alloc] init];
//    initialState.numbers = _numberArray;
//    [_openNodes add:initialState];
//
//    while (![_openNodes isEmpty]) {
//        GameState *state = [_openNodes poll];
////        NSLog(@"%@", state);
//        [_closedNodes addObject:state];
//
//        if ([state isEqual:_desState]) {
//            NSLog(@"=== finish");
//
//            GameState *preState = state.preState;
//            while (preState) {
//                NSLog(@"preState: %@", preState);
//                preState = preState.preState;
//            }
//            break;
//        }
//
//        NSArray *nextStates = [self getNextStates:state];
//        for (GameState *nextState in nextStates) {
//            if ([_closedNodes containsObject:nextState]) {
//                continue;
//            }
//
//            if([_openNodes contains:nextState]) {
//                [_openNodes remove:nextState];
//            }
//            [_openNodes add:nextState];
//        }
//    } while (![_openNodes isEmpty]);
//}
//
//- (NSArray *)getNextStates:(GameState *)state {
//
//    int a[2] = {-1, -1};
//    if (state.x - 1 >= 0) {
//        a[0] = state.x - 1;
//    }
//    if (state.x + 1 <= 2) {
//        a[1] = state.x + 1;
//    }
//    int b[2] = {-1, -1};
//    if (state.y - 1 >= 0) {
//        b[0] = state.y - 1;
//    }
//    if (state.y + 1 <= 2) {
//        b[1] = state.y + 1;
//    }
//
//    NSMutableArray *nextStates = [[NSMutableArray alloc] init];
//    for (int i = 0; i < 2; ++i) {
//        if (a[i] != -1) {
//            GameState *nextState = [[GameState alloc] init];
//            nextState.preState = state;
//            nextState.g = state.g + 1;
//            NSMutableArray *numbers = [state.numbers mutableCopy];
//            // swap
//            [numbers exchangeObjectAtIndex:(state.x*3+state.y) withObjectAtIndex:(a[i]*3+state.y)];
//            nextState.numbers = [numbers copy];
//            [nextStates addObject:nextState];
//        }
//    }
//    for (int j = 0; j < 2; ++j) {
//        if (b[j] != -1) {
//            GameState *nextState = [[GameState alloc] init];
//            nextState.preState = state;
//            nextState.g = state.g + 1;
//            NSMutableArray *numbers = [state.numbers mutableCopy];
//            // swap
//            [numbers exchangeObjectAtIndex:(state.x*3+state.y) withObjectAtIndex:(state.x*3+b[j])];
//            nextState.numbers = [numbers copy];
//            [nextStates addObject:nextState];
//        }
//    }
//
//    return nextStates;
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesBegan:touches withEvent:event];
//
//    UITouch *touch = [touches anyObject];
//    UIView *touchView = touch.view;
//    if ([touchView isKindOfClass:[UIButton class]] && touchView.tag != 0) {
//        _touchPoint = [touch locationInView:self.view];
//        _currentButton = (UIButton *) touchView;
//    }
//}
//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesMoved:touches withEvent:event];
//
//    UITouch *touch = [touches anyObject];
//    CGPoint point = [touch locationInView:self.view];
//
//    int direction = 0; // 左上右下
//    CGFloat diff;
//    CGFloat diffY = point.y - _touchPoint.y;
//    CGFloat diffX = point.x - _touchPoint.x;
//    if (ABS(diffY) > ABS(diffX)) {
//        direction = (diffY > 0) ? 3 : 1;
//        diff = diffY;
//    } else {
//        direction = (diffX > 0) ? 2 : 0;
//        diff = diffX;
//    }
//    NSLog(@"move direction: %@", @(direction));
//
//    if ([self canMoveView:_currentButton withDirection:direction]) {
//        [self moveView:_currentButton];
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//
//    _currentButton = nil;
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesCancelled:touches withEvent:event];
//
//    _currentButton = nil;
//}

@end
