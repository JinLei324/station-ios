//
//  UIZKRangeView.h
//  Test
//
//  Created by zk on 16/8/18.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMView.h"
#import "AudioPlayView.h"


@protocol UIZKRangeViewDelegate <NSObject>

- (void)zkDidMoveRange:(int)leftStr andRightRange:(int)rightStr;

@end


@interface UIZKRangeView : EMView

@property(nonatomic,strong)UIImageView *leftRangeView;

@property(nonatomic,strong)UIImageView *rightRangeView;

@property(nonatomic,strong)UIView *line;

@property(nonatomic,strong)UIView *cursorView;

@property(nonatomic,assign)BOOL isPlaying;

@property(nonatomic,assign)int totalCount;

@property (nonatomic,assign)id<UIZKRangeViewDelegate> delegate;

@property(nonatomic,assign)int leftRangeValue;

@property(nonatomic,assign)int rightRangeValue;

@property(nonatomic,strong)AudioPlayView *audioPlayView;

- (NSString*)getTimeWithCount:(int)time;

- (void)setLeftHidden:(BOOL)isHidden;

- (void)setRightHidden:(BOOL)isHidden;

@end
