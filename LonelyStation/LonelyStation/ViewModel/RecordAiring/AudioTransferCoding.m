//
//  AudioTransferCoding.m
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AudioTransferCoding.h"
#import "AudioPublicMethod.h"
#import "AppDelegate.h"

@implementation AudioTransferCoding
@synthesize recorder,recordFileName,recordFilePath,delegate,isWavToAmrCompleted;

#pragma mark - 开始录音
/**
 *  开始录音的相关逻辑
 *
 *  @param _fileName 录音文件名
 */
- (void)beginRecordByFileName:(NSString*)_fileName;{
    isWavToAmrCompleted = NO;
    recordFileName = _fileName;
    //设置文件名和录音路径
    recordFilePath = [AudioPublicMethod getPathByFileName:recordFileName ofType:@"wav"];
    //初始化录音
    self.recorder =  [[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:[recordFilePath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                                settings:[AudioPublicMethod getAudioRecorderSettingDict]
                                                   error:nil];
    recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    //开始录音
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
#pragma mark--加大声音
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    [self.recorder record];
    
    [VoiceConverter changeStu];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //去掉转码，因为这步没用
        [self wavToAmrBtnPressed];
        dispatch_async(dispatch_get_main_queue(), ^{
            isWavToAmrCompleted = YES;
            if (delegate) {
                [delegate wavToAmrComplete];
            }
        });
    });
}



- (void)setSpeakMode:(BOOL)speakMode
{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        AVAudioSessionPortOverride portOverride = speakMode ? AVAudioSessionPortOverrideSpeaker : AVAudioSessionPortOverrideNone;
        [[AVAudioSession sharedInstance] overrideOutputAudioPort:portOverride error:nil];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UInt32 route = speakMode ? kAudioSessionOverrideAudioRoute_Speaker : kAudioSessionOverrideAudioRoute_None;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(route), &route);
#pragma clang diagnostic pop
        
    }
}

#pragma mark - 录音结束
/**
 *  结束录音
 */
- (void)endRecord{
    if (self.recorder.isRecording) {
        [self.recorder stop];
        self.recorder = nil;
        [VoiceConverter changeStu];
    }
}

#pragma mark - 录音WAV实时转码为AMR
/**
 *  录音转码  wavToAmr
 */
- (void)wavToAmrBtnPressed{
    NSString *convertAmr = [recordFileName stringByAppendingString:@"wavToAmr"];
    //转格式
    [VoiceConverter wavToAmr:[AudioPublicMethod getPathByFileName:recordFileName ofType:@"wav"] amrSavePath:[AudioPublicMethod getPathByFileName:convertAmr ofType:@"amr"]];
}

/**
 *  混合拼接录音 wav
 *
 *  @param wavPath1  拼接的第一段录音路径
 *  @param wavePath2 拼接的第二段录音录进
 *  @param outpath   合成后的录音路径
 */
-(void)mixAudio:(NSString*)wavPath1 andPath:(NSString*)wavePath2 toPath:(NSString *)outpath{
    [VoiceConverter mixMusic:wavPath1 andPath:wavePath2 toPath:outpath];
}
/**
 *  混合拼接录音 amr
 *
 *  @param AmrPath1 第一段amr路径同时为拼接后音频的录音
 *  @param AmrPath2 第二段amr路径
 */
-(void)mixAmr:(NSString*)AmrPath1 andPath:(NSString*)AmrPath2 {
    [VoiceConverter mixAmr:AmrPath1 andPath:AmrPath2];
}

@end
