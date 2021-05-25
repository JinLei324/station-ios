//
//  AudioTransferCoding.h
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import <Foundation/Foundation.h>
#import "VoiceConverter.h"
#import <UIKit/UIKit.h>
#import "AudioToolbox/AudioToolbox.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
@protocol AudioRecordAndTransCodingDelegate<NSObject>
-(void)wavToAmrComplete;
@end

@interface AudioTransferCoding : EMObject

@property (retain, nonatomic)   AVAudioRecorder     *recorder;
@property (copy, nonatomic)     NSString            *recordFileName;//录音文件名
@property (copy, nonatomic)     NSString            *recordFilePath;//录音文件路径
@property (nonatomic,assign)    BOOL                isWavToAmrCompleted;//转码是否结束
@property (nonatomic, assign) id<AudioRecordAndTransCodingDelegate>delegate;

- (void)beginRecordByFileName:(NSString*)_fileName;
- (void)endRecord;
-(void)mixAudio:(NSString*)wavPath1 andPath:(NSString*)wavePath2 toPath:(NSString *)outpath;
-(void)mixAmr:(NSString*)AmrPath1 andPath:(NSString*)AmrPath2;

@end
