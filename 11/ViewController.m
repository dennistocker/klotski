//
//  ViewController.m
//  11
//
//  Created by 程利 on 2018/1/15.
//  Copyright © 2018年 foundersc. All rights reserved.
//

#import "ViewController.h"
#import "HRNumView.h"
#import "PriorityQueue.h"
#import "GameState.h"
#import "UIColor+Hex.h"
#import "Macros.h"
#import "Masonry.h"

static const CGFloat kMargin = 20;
static const CGFloat kOffset = 5;
static const NSInteger kDefaultLevel = 4;
static const NSInteger kMinLevel = 3;
static const NSInteger kMaxLevel = 7;

static NSString *kGameLevel = @"gameLevel";

@interface ViewController ()

@property (nonatomic, strong) UIImageView *footImageView;
@property (nonatomic, strong) UIImageView *clockImageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *stepLabel;
@property (nonatomic, strong) UILabel *levelLabel;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeUsed;
@property (nonatomic, assign) NSInteger stepUsed;
@property (nonatomic, assign) NSInteger gameLevel;
@property (nonatomic, strong) NSMutableArray *numberArray;

@property (nonatomic, strong) HRNumView *currentView;
@property (nonatomic, assign) CGPoint touchPoint;


@property (nonatomic, strong) PriorityQueue *openNodes;
@property (nonatomic, strong) NSMutableArray *closedNodes;
@property (nonatomic, strong) GameState *desState;

@end

@implementation ViewController


- (NSArray *)generatePuzzleWithSize:(NSInteger)size
                               step:(NSInteger)step
{
    NSInteger count = pow(size, 2);
    NSMutableArray *puzzleArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < count -1; ++i) {
        [puzzleArray addObject:@(i+1)];
    }
    [puzzleArray addObject:@(0)];

    NSInteger currentPosition = count - 1;
    NSInteger lastPosition = -1;
    NSMutableArray *moveArray = [[NSMutableArray alloc] init];

    for (NSInteger i = 0; i < step; ++i) {
        NSInteger x = currentPosition / size;
        NSInteger y = currentPosition % size;

        [moveArray removeAllObjects];

        if (x - 1 >= 0) {
            NSInteger position = (x - 1) * size + y;
            [moveArray addObject:@(position)];
        }
        if (x + 1 < size) {
            NSInteger position = (x + 1) * size + y;
            [moveArray addObject:@(position)];
        }
        if (y - 1 >= 0) {
            NSInteger position = x * size + y - 1;
            [moveArray addObject:@(position)];
        }
        if (y + 1 <= size-1) {
            NSInteger position = x * size + y + 1;
            [moveArray addObject:@(position)];
        }

        NSInteger nextPosition = -1;
        while (nextPosition == -1 || nextPosition == lastPosition) {
            uint32_t index = arc4random_uniform((uint32_t)moveArray.count);
            nextPosition = [moveArray[index] integerValue];
        }

        [puzzleArray exchangeObjectAtIndex:currentPosition withObjectAtIndex:nextPosition];

        lastPosition = currentPosition;
        currentPosition = nextPosition;
    }

    return puzzleArray;
}

- (void)drawBoard
{
    self.view.backgroundColor = [UIColor colorWithHex:0xEBEFF2];

    CGFloat height = kMainScreenHeight;
    CGFloat width = kMainScreenWidth;
    CGFloat top = (height - width) / 2;
    CGRect bgRect = CGRectMake(kMargin, top, width-kMargin*2, width-kMargin*2);
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRoundedRect:bgRect cornerRadius:5];
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.path = bgPath.CGPath;
    bgLayer.lineJoin = kCALineJoinRound;
    bgLayer.lineCap = kCALineCapRound;
    bgLayer.strokeColor = [UIColor colorWithHex:0x333333].CGColor;
    bgLayer.fillColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:bgLayer];
}

- (void)setupSubviews
{
    CGFloat height = kMainScreenHeight;
    CGFloat width = kMainScreenWidth;
    CGFloat top = (height - width) / 2 - 30;
    _clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"clock"]];
    [self.view addSubview:_clockImageView];
    [_clockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(kMargin);
        make.top.equalTo(self.view).offset(top);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];

    _timeLabel = [self createLabel];
    _timeLabel.text = @"00“";
    [self.view addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_clockImageView.mas_right).offset(kOffset);
        make.centerY.equalTo(_clockImageView);
    }];;

    _footImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"foot"]];
    [self.view addSubview:_footImageView];
    [_footImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_clockImageView.mas_right).offset(40);
        make.centerY.equalTo(_clockImageView);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];

    _stepLabel = [self createLabel];
    _stepLabel.text = @"0";
    [self.view addSubview:_stepLabel];
    [_stepLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_footImageView.mas_right).offset(kOffset);
        make.centerY.equalTo(_footImageView);
    }];

    UIImageView *gameImageView = [[UIImageView alloc] initWithImage:
                                  [UIImage imageNamed:@"game"]];
    gameImageView.userInteractionEnabled = YES;
    gameImageView.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(gameImageclicked:)];
    [gameImageView addGestureRecognizer:tap];
    [self.view addSubview:gameImageView];
    [gameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-kMargin);
        make.top.equalTo(self.view).offset((height - width)/2 + width - kMargin * 2 + 10);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];

    UIImageView *favouriteImageView = [[UIImageView alloc] initWithImage:
                                       [UIImage imageNamed:@"favorite"]];
    favouriteImageView.userInteractionEnabled = YES;
    favouriteImageView.contentMode = UIViewContentModeScaleAspectFit;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(favouriteImageClicked:)];
    [favouriteImageView addGestureRecognizer:tap];
    [self.view addSubview:favouriteImageView];
    [favouriteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(gameImageView);
        make.left.equalTo(self.view).offset(kMargin);
        make.size.mas_equalTo(CGSizeMake(36, 32));
    }];

    _levelLabel = [[UILabel alloc] init];
    _levelLabel.font = [UIFont boldSystemFontOfSize:40];
    _levelLabel.textColor = [UIColor colorWithHex:0x333333];
    _levelLabel.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(levelLabelClicked:)];
    [_levelLabel addGestureRecognizer:tap];
    [self.view addSubview:_levelLabel];
    [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kMargin*3);
//        make.bottom.equalTo(_timeLabel).offset(8);
        make.right.equalTo(self.view).offset(-kMargin);
    }];
}

- (void)levelLabelClicked:(UITapGestureRecognizer *)tap
{
    if (++_gameLevel > kMaxLevel) {
        _gameLevel = kMinLevel;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:_gameLevel forKey:kGameLevel];
    [[NSUserDefaults standardUserDefaults] synchronize];

    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag != 0) {
            [subview removeFromSuperview];
        }
    }

    [self loadGame];
}

- (void)gameImageclicked:(UITapGestureRecognizer *)tap
{
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && subview.tag != 0) {
            [subview removeFromSuperview];
        }
    }

    [self loadGame];
}

- (void)favouriteImageClicked:(UITapGestureRecognizer *)tap
{

}

- (UILabel *)createLabel
{
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithHex:0x333333];
    label.font = [UIFont systemFontOfSize:17];
    label.backgroundColor = [UIColor clearColor];
    return label;
}

- (UIButton *)createButtonWithNumber:(NSInteger)number
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithHex:0xF5F8FA];
    button.tag = number;
    button.titleLabel.font = [UIFont boldSystemFontOfSize:32];
    [button setTitle:@(number).stringValue forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
    button.layer.cornerRadius = 5;
    button.layer.shadowOffset = CGSizeMake(0, 3);
    button.layer.shadowOpacity = 0.5;
    [button addTarget:self action:@selector(numberButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)numberButtonClicked:(UIButton *)button
{
    NSInteger number = button.tag;

    NSInteger indexOfZero = [_numberArray indexOfObject:@(0)];
    NSInteger indexOfNumber = [_numberArray indexOfObject:@(number)];

    if (labs(indexOfNumber/_gameLevel - indexOfZero/_gameLevel) + labs(indexOfNumber%_gameLevel - indexOfZero%_gameLevel) == 1) {
        // move
        _numberArray[indexOfZero] = @(number);
        _numberArray[indexOfNumber] = @(0);
        _stepUsed++;
        _stepLabel.text = @(_stepUsed).stringValue;

        CGFloat gap = 5;
        CGFloat baseTop = (kMainScreenHeight - kMainScreenWidth) / 2;
        CGFloat width = (kMainScreenWidth - (kMargin+1) * 2 - gap * (_gameLevel+1)) / _gameLevel;
        CGFloat left = kMargin + 1 + gap + (width + gap) * (indexOfZero % _gameLevel);
        CGFloat top = baseTop + gap + (width + gap) * (indexOfZero / _gameLevel);

        [UIView animateWithDuration:0.1 animations:^{
            button.frame = CGRectMake(left, top, width, width);
        } completion:^(BOOL finished) {
            BOOL completed = TRUE;
            for (NSInteger i = 0; i < _numberArray.count - 1; ++i) {
                if ([_numberArray[i] integerValue] != i+1) {
                    completed = FALSE;
                    break;
                }
            }
            if (completed) {
                NSLog(@"completed");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_timer setFireDate:[NSDate distantFuture]];
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"Congratulations!" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    }];
                    [alertController addAction:action];
                    [self presentViewController:alertController animated:YES completion:nil];
                });
            }
        }];
    }
}

- (void)timerFired:(NSTimer *)timer
{
    self.timeUsed++;
    NSString *timeUsed = nil;
    if (_timeUsed >= 3600) {
        timeUsed = [[NSString alloc] initWithFormat:@"%02zd:%02zd′%02zd″", _timeUsed / 3600, (_timeUsed % 3600) / 60, (_timeUsed % 60)];
    } else if (_timeUsed >= 60) {
        timeUsed = [[NSString alloc] initWithFormat:@"%02zd′%02zd″", (_timeUsed / 60), (_timeUsed % 60)];
    } else {
        timeUsed = [[NSString alloc] initWithFormat:@"%02zd″", (_timeUsed % 60)];
    }
    _timeLabel.text = timeUsed;
}

- (void)setTimeUsed:(NSInteger)timeUsed
{
    _timeUsed = timeUsed;

    if (_timeUsed == 0 || _timeUsed == 60 || _timeUsed == 3600) {
        NSInteger offset = 40;
        if (_timeUsed == 60) {
            offset = 62;
        } else if (_timeUsed == 3600) {
            offset = 90;
        }
        [_footImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_clockImageView.mas_right).offset(offset);
        }];
    }
}

- (void)loadGame
{
    _gameLevel = [[NSUserDefaults standardUserDefaults] integerForKey:kGameLevel];
    if (_gameLevel < kMinLevel || _gameLevel > kMaxLevel) {
        _gameLevel = kDefaultLevel;
    }
    _numberArray = [[self generatePuzzleWithSize:_gameLevel step:30] mutableCopy];
    _levelLabel.text = [[NSString alloc] initWithFormat:@"%zd x %zd", _gameLevel, _gameLevel];

    [_timer setFireDate:[NSDate distantFuture]];
    _timeUsed = 0;
    [_timer setFireDate:[NSDate distantPast]];
    _stepUsed = 0;
    _stepLabel.text = @(_stepUsed).stringValue;

    CGFloat gap = 5;
    CGFloat baseTop = (kMainScreenHeight - kMainScreenWidth) / 2;
    CGFloat width = (kMainScreenWidth - (kMargin+1) * 2 - gap * (_gameLevel+1)) / _gameLevel;
    NSInteger index = 0;
    for (NSNumber *number in _numberArray) {
        NSInteger value = [number integerValue];
        if (value != 0) {
            UIButton *button = [self createButtonWithNumber:value];
            CGFloat left = kMargin + 1 + gap + (width + gap) * (index % _gameLevel);
            CGFloat top = baseTop + gap + (width + gap) * (index / _gameLevel);
            button.frame = CGRectMake(left, top, width, width);
            [self.view addSubview:button];
        }
        ++index;
    }
}

- (void)setupTimer
{
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self drawBoard];

    [self setupSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self setupTimer];

    [self loadGame];

    return;
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
//    if ([touchView isKindOfClass:[HRNumView class]]) {
//        _currentView = (HRNumView *) touchView;
//        _touchPoint = [touch locationInView:self.view];
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
//    if ([self canMoveView:_currentView withDirection:direction]) {
//        [self moveView:_currentView withDirection:direction offset:diff];
//    }
//}
//
//- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesEnded:touches withEvent:event];
//
//    _currentView = nil;
//}
//
//- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    [super touchesCancelled:touches withEvent:event];
//
//    _currentView = nil;
//}
//
//- (BOOL)canMoveView:(HRNumView *)view withDirection:(NSInteger)direction
//{
//    NSInteger index = [_numberArray indexOfObject:@([view getNumber])];
//    NSInteger desIndex = 0;
//
//    switch (direction) {
//        case 0:
//            desIndex = index - 1;
//            break;
//        case 1:
//            desIndex = index - 3;
//            break;
//        case 2:
//            desIndex = index + 1;
//            break;
//        case 3:
//            desIndex = index + 3;
//            break;
//        default:
//            break;
//    }
//    return (desIndex >= 0 && desIndex < 9 && [_numberArray[desIndex] integerValue] == 0);
//}
//
//- (void)moveView:(HRNumView *)view withDirection:(NSInteger)direction offset:(CGFloat)diff
//{
//    NSInteger index = [_numberArray indexOfObject:@([view getNumber])];
//    NSInteger desIndex = 0;
//
//    switch (direction) {
//        case 0:
//            desIndex = index - 1;
//            break;
//        case 1:
//            desIndex = index - 3;
//            break;
//        case 2:
//            desIndex = index + 1;
//            break;
//        case 3:
//            desIndex = index + 3;
//            break;
//        default:
//            break;
//    }
//    _numberArray[desIndex] = @([view getNumber]);
//    _numberArray[index] = @(0);
//
//    CGFloat width = (302-4*2)/3;
//    view.frame = CGRectMake(32+(width+2)*(desIndex%3), 202+(width+2)*(desIndex/3), width, width);
//}
//
//- (NSInteger)niXuDui:(NSArray *)array {
//    NSInteger count = 0;
//    for (int i = 0; i < array.count; ++i) {
//        for (int j = i+1; j < array.count; ++j) {
//            if (array[i] > array[j]) {
//                count++;
//            }
//        }
//    }
//    return count;
//}

@end
