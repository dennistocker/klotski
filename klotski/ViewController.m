
#import "ViewController.h"
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
@property (nonatomic, weak) UIButton *currentButton;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timeUsed;
@property (nonatomic, assign) NSInteger stepUsed;
@property (nonatomic, assign) NSInteger gameLevel;
@property (nonatomic, strong) NSMutableArray *numberArray;

@property (nonatomic, assign) CGPoint touchPoint;
//
//@property (nonatomic, strong) PriorityQueue *openNodes;
//@property (nonatomic, strong) NSMutableArray *closedNodes;
//@property (nonatomic, strong) GameState *desState;

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
    CGFloat top = (height - width) / 2 + 40;
    CGRect bgRect = CGRectMake(kMargin, top, width-kMargin*2, width-kMargin*2);
    UIBezierPath *bgPath = [UIBezierPath bezierPathWithRoundedRect:bgRect cornerRadius:5];
    CAShapeLayer *bgLayer = [CAShapeLayer layer];
    bgLayer.path = bgPath.CGPath;
    bgLayer.lineJoin = kCALineJoinRound;
    bgLayer.lineCap = kCALineCapRound;
    bgLayer.strokeColor = [UIColor colorWithHex:0x333333].CGColor;
    bgLayer.fillColor = [UIColor colorWithHex:0xeeeeee].CGColor;
    [self.view.layer addSublayer:bgLayer];
}

- (void)setupSubviews
{
    CGFloat height = kMainScreenHeight;
    CGFloat width = kMainScreenWidth;
    CGFloat top = (height - width) / 2 + 10;
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
        make.top.equalTo(self.view).offset((height - width)/2 + 40 + width - kMargin * 2 + 10);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];

    _levelLabel = [[UILabel alloc] init];
    _levelLabel.font = [UIFont boldSystemFontOfSize:56];
    _levelLabel.textColor = [UIColor colorWithHex:0x333333];
    _levelLabel.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(levelLabelClicked:)];
    [_levelLabel addGestureRecognizer:tap];
    [self.view addSubview:_levelLabel];
    [_levelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(kMargin*4);
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
    button.layer.borderColor = [UIColor colorWithHex:0xFEE152].CGColor;
    [button addTarget:self action:@selector(numberButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

    for (NSNumber *number in @[ @(UISwipeGestureRecognizerDirectionUp),
                                                 @(UISwipeGestureRecognizerDirectionDown),
                                                 @(UISwipeGestureRecognizerDirectionLeft),
                                                 @(UISwipeGestureRecognizerDirectionRight)] ) {
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(buttonSwipe:)];
        swipe.direction = [number integerValue];
        [button addGestureRecognizer:swipe];
    }
    return button;
}

- (void)numberButtonClicked:(UIButton *)button
{
    NSInteger number = button.tag;

    NSInteger indexOfZero = [_numberArray indexOfObject:@(0)];
    NSInteger indexOfNumber = [_numberArray indexOfObject:@(number)];

    if (labs(indexOfNumber/_gameLevel - indexOfZero/_gameLevel) + labs(indexOfNumber%_gameLevel - indexOfZero%_gameLevel) == 1) {
        [self moveView:button];
    }
}

- (void)buttonSwipe:(UISwipeGestureRecognizer *)swipe
{
    int direction = 0;
    switch (swipe.direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            direction = 0;
            break;
        case UISwipeGestureRecognizerDirectionUp:
            direction = 1;
            break;
        case UISwipeGestureRecognizerDirectionRight:
            direction = 2;
            break;
        case UISwipeGestureRecognizerDirectionDown:
            direction = 3;
            break;
    }

    UIButton *button = (UIButton *)swipe.view;
    if ([self canMoveView:button withDirection:direction]) {
        [self moveView:button];
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
    CGFloat baseTop = (kMainScreenHeight - kMainScreenWidth) / 2 + 40;
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

- (BOOL)canMoveView:(UIButton *)button withDirection:(NSInteger)direction
{
    NSInteger index = [_numberArray indexOfObject:@(button.tag)];
    NSInteger desIndex = 0;

    switch (direction) {
        case 0:
            desIndex = index - 1;
            break;
        case 1:
            desIndex = index - _gameLevel;
            break;
        case 2:
            desIndex = index + 1;
            break;
        case 3:
            desIndex = index + _gameLevel;
            break;
        default:
            break;
    }
    return (desIndex >= 0 && desIndex < pow(_gameLevel, 2) && [_numberArray[desIndex] integerValue] == 0);
}

- (void)moveView:(UIButton *)button
{
    NSInteger number = button.tag;
    NSInteger indexOfZero = [_numberArray indexOfObject:@(0)];
    NSInteger indexOfNumber = [_numberArray indexOfObject:@(number)];

    // move
    _numberArray[indexOfZero] = @(number);
    _numberArray[indexOfNumber] = @(0);
    _stepUsed++;
    _stepLabel.text = @(_stepUsed).stringValue;
    CGAffineTransform scale = CGAffineTransformMakeScale(1.3, 1.3);
    [UIView animateWithDuration:0.15 animations:^{
        _stepLabel.transform = scale;
    } completion:^(BOOL finished) {
        _stepLabel.transform = CGAffineTransformMakeScale(1, 1);
    }];

    CGFloat gap = 5;
    CGFloat baseTop = (kMainScreenHeight - kMainScreenWidth) / 2 + 40;
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

@end
