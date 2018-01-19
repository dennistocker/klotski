//
//  GameState.h
//  11
//
//  Created by 程利 on 2018/1/15.
//  Copyright © 2018年 foundersc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comparable.h"

@interface GameState : NSObject <Comparable>

@property (nonatomic, strong) NSArray<NSNumber *> *numbers;
@property (nonatomic, assign) NSInteger f; // f = g + h
@property (nonatomic, assign) NSInteger g;
@property (nonatomic, assign) NSInteger h;

@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, weak) GameState *preState;

@end
