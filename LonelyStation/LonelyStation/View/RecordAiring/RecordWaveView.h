//
//  RecordWaveView.h
//  LonelyStation
//
//  Created by zk on 16/8/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMView.h"

@protocol RecordWaveDelegate <NSObject>

- (void)willUpdateLeftValue:(int)value andLeftText:(NSString*)leftText andRightValue:(int)rightValue andRightText:(NSString*)rightText;

- (void)localUpdateLeftValue:(int)value andLeftText:(NSString*)leftText;

- (void)didStartLocalPan;

- (void)didEndLocalPan:(int)value;

@end

typedef NS_ENUM(NSInteger,RecordStatus){
    RecordStatusRecord = 0,
    RecordStatusClip,
    RecordStatusPlay
};

@interface RecordWaveView : EMView


@property(nonatomic,assign)id<RecordWaveDelegate> delegate;
@property(nonatomic,assign)long long accountValue;
@property(nonatomic,assign)long long currentValue;



- (void)updateView:(CGFloat)peakPowerForChannel;

- (void)startRecord;

- (void)resetRightOrgin;

//更新游标
- (void)updateSet:(float)value;

- (void)startPlay;

- (void)clearSample;

- (void)stopPlay;

- (void)showClipView;

@end
