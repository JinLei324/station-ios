//
//  AudioRecordVM.h
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"
#import <AVFoundation/AVFoundation.h>

@protocol EMAudioRecordDelegate <NSObject>

- (void)didUpdateTime:(NSString*)time;

- (void)didUpdateTimePower:(float)power;

//转换完成的委托
- (void)didRecordMixComplete:(NSString*)path;

//完成录音
- (void)recodeComplete:(NSString*)path;

@end


//专门控制音频录制的类
@interface AudioRecordVM : EMObject

@property (nonatomic,assign)id<EMAudioRecordDelegate> delegate;

@property (nonatomic,assign)BOOL vedioing;//正在录音

@property (nonatomic,assign)long long totalSeconds;

@property (nonatomic,copy)NSString *lastVedio; //最后录音的路径

@property (nonatomic,copy)NSString *vedioPath; //录音路径

@property (nonatomic,copy)NSString *aAudioPath;//新的路径


@property (nonatomic,assign)BOOL isNotMixPreRecord;//是否拼接上一段录音，重录的话得设置为YES

//录音和完成之间自动切换，按录音键和停止键响应的事件
- (void)recordButtonClick;

//点了剪切键，或者上传键需要调用这个方法需录音这个状态完成，包括删除前都需要先调用这个方法
- (void)actionButtonClick;

//开始录音
- (void)beginToRecordAudio;

//完成录音
- (void)endToRecordAudio;

//删除录音
- (void)deleteVedioNamed:(NSString *)name;

- (NSData*)getData:(NSString*)path;

//转换成mp3
- (BOOL)audio_PCMtoMP3:(NSString*)path;



- (void)convertPathWithPathwav2Mp3:(NSString*)aPath andType:(NSString*)type  andNewPath:(NSString*)aNewPath andBlock:(void(^)(NSString *newPath))block;

//合并音频和裁剪一起
- (void)cropActionWithAudioPathForThree:(NSString*)path andMiddlePath:(NSString*)middlePath andLeftDuration:(NSTimeInterval)leftInterval andRightDuration:(NSTimeInterval)rightInterval andAllDuration:(NSTimeInterval)allInterval andBlock:(void(^)(NSString *newPath))block;


//裁剪音频
- (void)cropActionWithAudioPath:(NSString*)path andLeftDuration:(NSTimeInterval)leftInterval andRightDuration:(NSTimeInterval)rightInterval andAllDuration:(NSTimeInterval)allInterval andBlock:(void(^)(NSString *newPath))block;




@end
