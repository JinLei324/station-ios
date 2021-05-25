//
//  ZKWaveView.h
//  LonelyStation
//
//  Created by zk on 16/8/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMView.h"

@interface ZKWaveView : EMView

@property(nonatomic,assign) float sampleWidth;
@property(nonatomic,assign) float intervalTime;
//游标
@property(nonatomic,strong) UIImageView *imgView;

@property (nonatomic, strong) NSMutableArray *samples;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)addSamples:(NSNumber *)value;

- (void)clearSamples;


@end
