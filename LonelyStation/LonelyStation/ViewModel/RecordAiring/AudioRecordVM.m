//
//  AudioRecordVM.m
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AudioRecordVM.h"
#import "AudioTransferCoding.h"
#import "AudioPublicMethod.h"
#import "VoiceConverter.h"
#import "lame.h"
#import "AppDelegate.h"

@interface AudioRecordVM () <AudioRecordAndTransCodingDelegate,AVAudioRecorderDelegate>{
    NSTimer *timer;
    BOOL waitMixAmr;//正在转换
    AudioTransferCoding *audioRecord;//录音带转换
    NSTimer *recoderTimer;
}

@end


@implementation AudioRecordVM

@synthesize vedioing,totalSeconds;

- (instancetype)init {
    self = [super init];
    totalSeconds = 0;
    return self;
}

- (void)recordButtonClick {
    if (vedioing) {
        [self performSelector:@selector(endToRecordAudio) withObject:nil afterDelay:0.5];
    }
    else {
        [self beginToRecordAudio];
    }
}

- (void)updateMiter {
    if (vedioing) {
        [audioRecord.recorder updateMeters];
        float peakPowerForChannel = [audioRecord.recorder peakPowerForChannel:0];

        if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTimePower:)]) {
            [_delegate didUpdateTimePower:peakPowerForChannel];
        }
    }
}

//获取录音data
- (NSData*)getData:(NSString*)path {

    
    
    BOOL ret = [self audio_PCMtoMP3:path];
    NSString *currPath = @"";
    if (ret) {
        currPath = [[AudioPublicMethod getPathByFileName:path ofType:@"mp3"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }else{
     currPath = [[AudioPublicMethod getPathByFileName:path ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    NSData *data = [NSData dataWithContentsOfFile:currPath];
    return data;
}


- (BOOL)audio_PCMtoMP3:(NSString*)path
{
    
    NSString *WAVFilePath = [AudioPublicMethod getPathByFileName:path ofType:@"wav"];
    
    
    NSString *mp3FilePath = [AudioPublicMethod getPathByFileName:path ofType:@"mp3"];
    
    
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        DLog(@"删除");
    }
    
    @try {
        int read, write;

        FILE *pcm = fopen([WAVFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
//        const int PCM_SIZE = 8192;
//        const int MP3_SIZE = 8192;
//        short int pcm_buffer[PCM_SIZE*2];
//        unsigned char mp3_buffer[MP3_SIZE];
//        
//        lame_t lame = lame_init(); // 初始化
//        lame_set_num_channels(lame, 2); // 双声道，跟录音要匹配
//        lame_set_in_samplerate(lame, 8000); // 8k采样率
//        lame_set_VBR(lame, vbr_default);
//        lame_init_params(lame);
//        lame_set_brate(lame, 16);  // 压缩的比特率为16
//        lame_set_quality(lame, 2);  // mp3音质
//
//        do {
//            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
//            if (read == 0)
//                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
//            else
//                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
//            
//            fwrite(mp3_buffer, write, 1, mp3);
//            
//        } while (read != 0);
//        
//        lame_close(lame);
//        fclose(mp3);
//        fclose(pcm);
        
        int PCM_SIZE = 640;
        int MP3_SIZE = 8192;
        
        short int pcm_buffer[PCM_SIZE];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        
        lame_set_num_channels(lame,1);
        lame_set_in_samplerate(lame,8000);
        lame_set_brate(lame,16);
        lame_set_mode(lame,3);
        lame_set_VBR(lame, vbr_default);
        lame_set_quality(lame,1); /* 2=high 5 = medium 7=low */
        
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, sizeof(short int), PCM_SIZE, pcm);
            
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
            {
                write = lame_encode_buffer(lame,
                                           pcm_buffer, NULL,  
                                           read,mp3_buffer,MP3_SIZE);  
            }  
            
            fwrite(mp3_buffer, write, 1, mp3);  
        } while (read != 0);  
                
        lame_close(lame);  
        fclose(mp3);  
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        
    }
    
    if (mp3FilePath != nil) {
        return YES;
    }
    return NO;
}



/**
 *  开始录音
 */
- (void)beginToRecordAudio {
    vedioing = YES;
    if (self.isNotMixPreRecord) {
        self.aAudioPath =  [NSString stringWithFormat:@"%@",[AudioPublicMethod getCurrentTimeString]];
    }else{
        self.vedioPath= [NSString stringWithFormat:@"%@",[AudioPublicMethod getCurrentTimeString]];
    }
    if (!audioRecord) {
        audioRecord = [[AudioTransferCoding alloc]init];
        audioRecord.recorder.delegate = self;
        audioRecord.delegate = self;
    }
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appdele.isRecording = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
             if (self.isNotMixPreRecord) {
                 [audioRecord beginRecordByFileName:self.aAudioPath];
             }else{
                 [audioRecord beginRecordByFileName:self.vedioPath];
             }
            timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(levelTimerCallBack) userInfo:nil repeats:YES];
            
            recoderTimer = [NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(updateMiter) userInfo:nil repeats:YES];
        });
    });
}




// 通过音量更新录制界面
- (void)levelTimerCallBack {
    if (vedioing) {
            totalSeconds++;
            int seconds = totalSeconds % 60;
            int minutes = (totalSeconds / 60) % 60;
            //时间更新，通过委托来更新
            //
            if (_delegate && [_delegate respondsToSelector:@selector(didUpdateTime:)]) {
                [_delegate didUpdateTime:[NSString stringWithFormat:@"%02d:%02d", minutes, seconds]];
            }
    }
}

//转换完成的委托
- (void)wavToAmrComplete {
    if (waitMixAmr && _lastVedio) {
        [self mixAmr];
    }else{
//    去除转码，因为这步没用
        if(_delegate && [_delegate respondsToSelector:@selector(didRecordMixComplete:)]){
            [_delegate didRecordMixComplete:_lastVedio];
            if (self.delegate && [_delegate respondsToSelector:@selector(recodeComplete:)]) {
                [self.delegate recodeComplete:_lastVedio];
            }
        }
    }
}

- (void)actionButtonClick {
    if (vedioing) {
        [self cancleRecord];
        [self recordComplete];
    }
    else {
        [self recordComplete];
    }
}


// 用户录制中途取消录音处理
- (void)cancleRecord {
    if (_lastVedio) {
        NSString *lastAmr=[AudioPublicMethod getPathByFileName:[_lastVedio stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
        [self deleteVedioNamed:lastAmr];
        NSString *lastWav=[AudioPublicMethod getPathByFileName:_lastVedio ofType:@"wav"];
        [self deleteVedioNamed:lastWav];
        _lastVedio = nil;
    }
    if (_vedioPath) {
        NSString *vedioAmr=[AudioPublicMethod getPathByFileName:[_vedioPath stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
        [self deleteVedioNamed:vedioAmr];
        NSString *vedioWav=[AudioPublicMethod getPathByFileName:_vedioPath ofType:@"wav"];
        [self deleteVedioNamed:vedioWav];
        _lastVedio = nil;
    }
}

//录音结束，返回最终音频地址
- (void)recordComplete {
    if (self.delegate && [_delegate respondsToSelector:@selector(recodeComplete:)]) {
        [audioRecord endRecord];
        audioRecord.delegate = nil;
        audioRecord = nil;
        [self.delegate recodeComplete:_lastVedio];
//        _lastVedio = nil;
    }
}



//完成录音
- (void)endToRecordAudio {
    if (vedioing) {
        vedioing = NO;
        AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appdele.isRecording = NO;
        if (timer) {
            if ([timer isValid]) {
                [timer invalidate];
            }
            timer = nil;
        }
        if (recoderTimer) {
            if ([recoderTimer isValid]) {
                [recoderTimer invalidate];
            }
            recoderTimer = nil;
        }
        
        //UIView *bg = (UIView *)[self viewWithTag:10086];
        //[bg removeFromSuperview];
        
        if (audioRecord&&[audioRecord.recorder isRecording]) {
            [audioRecord endRecord];
        }
        if (_vedioPath.length>0) {
            // 显示语音长度
            int length=[AudioPublicMethod getVedioLength:_vedioPath];
            if (length<1) {
                //                [self deleteVedioNamed:vedioPath];
                _vedioPath=nil;
                //录音时间过短
                UIAlertView *alert=[[UIAlertView alloc] initWithTitle:Local(@"Warning") message:Local(@"RecordIsTooShort") delegate:self cancelButtonTitle:Local(@"IKnowRecordIsTooShort") otherButtonTitles:nil];
                [alert show];
                return;
            }else{
                if (_lastVedio.length == 0) {
                    _lastVedio = _vedioPath;
                }else{
                    if (![_lastVedio isEqualToString:_vedioPath]) {
                        int length = [AudioPublicMethod getVedioLength:_vedioPath];
                        if (length!=0) {
                            if (!self.isNotMixPreRecord) {
                                waitMixAmr = YES;
                                NSString *lastString = [AudioPublicMethod getPathByFileName:_lastVedio ofType:@"wav"];
                                NSString *pathString = [AudioPublicMethod getPathByFileName:_vedioPath ofType:@"wav"];
                                NSString *newName = [NSString stringWithFormat:@"%@_new",_vedioPath];
                                [audioRecord mixAudio:pathString andPath:lastString toPath:[AudioPublicMethod getPathByFileName:newName ofType:@"wav"]];
                            }
                        }
                    }
                }
            }
        }
    }
}



//混合音频
- (void)mixAmr {
    NSString *newName=[NSString stringWithFormat:@"%@_new",_vedioPath];
    //两个amr的位置
    NSString *vedioAmr=[AudioPublicMethod getPathByFileName:[_vedioPath stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    NSString *lastAmr=[AudioPublicMethod getPathByFileName:[_lastVedio stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    
    [audioRecord mixAmr:lastAmr andPath:vedioAmr];
    NSString *newPath=[AudioPublicMethod getPathByFileName:[newName stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    [[NSFileManager defaultManager] copyItemAtPath:lastAmr toPath:newPath error:nil];
//    //将拼接的两个录音的音频和转码后amr文件都删除
//    [self deleteVedioNamed:_lastVedio];
//    [self deleteVedioNamed:vedioPath];
    _lastVedio = newName;
    waitMixAmr = NO;
    if(_delegate && [_delegate respondsToSelector:@selector(didRecordMixComplete:)]){
        [_delegate didRecordMixComplete:_lastVedio];
    }
}

//删除音频
- (void)deleteVedioNamed:(NSString *)name {
    NSString *pathString=[AudioPublicMethod getPathByFileName:name ofType:@"wav"];
    NSString *vedioAmr=[AudioPublicMethod getPathByFileName:[name stringByAppendingString:@"wavToAmr"] ofType:@"amr"];
    [AudioPublicMethod deleteFileAtPath:pathString];
    [AudioPublicMethod deleteFileAtPath:vedioAmr];
}



/**
 合成从0到左，中间wav，从右到总长的wav

 @param path <#path description#>
 @param middlePath <#middlePath description#>
 @param leftInterval <#leftInterval description#>
 @param rightInterval <#rightInterval description#>
 @param allInterval <#allInterval description#>
 @param block <#block description#>
 */
- (void)cropActionWithAudioPathForThree:(NSString*)path andMiddlePath:(NSString*)middlePath andLeftDuration:(NSTimeInterval)leftInterval andRightDuration:(NSTimeInterval)rightInterval andAllDuration:(NSTimeInterval)allInterval andBlock:(void(^)(NSString *newPath))block {
    NSString *leftNewPath = [NSString stringWithFormat:@"%@_left_new",[AudioPublicMethod getCurrentTimeString]];
    [self cutPathWithPathwav:path andType:@"wav" andLeftDuration:0 andRightDuration:leftInterval andNewPath:leftNewPath andBlock:^(NSString *leftPath) {
        //导完左边，开始右边
        NSString *rightNewPath = [NSString stringWithFormat:@"%@_right_new",[AudioPublicMethod getCurrentTimeString]];
        [self cutPathWithPathwav:path andType:@"wav" andLeftDuration:rightInterval andRightDuration:allInterval andNewPath:rightNewPath andBlock:^(NSString *aNewPath) {
            //右边的也导出来了
            //现在合并3个wav
            NSArray *array = @[leftPath,middlePath,aNewPath];
            if (leftInterval == 0) {
                array = @[middlePath,aNewPath];
            }
            if (rightInterval == allInterval) {
                array = @[leftPath,middlePath];
            }
            if (array.count == 3) {
                [self mergeFileWithLeftFile:leftPath andRightFile:middlePath andType:@"wav" andBlock:^(NSString *aaanewPath) {
                    [self mergeFileWithLeftFile:aaanewPath andRightFile:aNewPath andType:@"wav" andBlock:^(NSString *newNewPath) {
                        _lastVedio = newNewPath;
                        block(newNewPath);
                    }];
                }];
            }else{
                [self mergeFileWithLeftFile:array[0] andRightFile:array[1] andType:@"wav" andBlock:^(NSString *aaanewPath) {
                        _lastVedio = aaanewPath;
                        block(aaanewPath);
                }];
            }
        }];
    }];
}


- (void)mergeFileWithLeftFile:(NSString*)leftFile andRightFile:(NSString*)rightFile andType:(NSString*)type andBlock:(void(^)(NSString* newPath))block {
    
    NSString *audioPath1 = [AudioPublicMethod getPathByFileName:rightFile ofType:type];
    NSString *audioPath2 = [AudioPublicMethod getPathByFileName:leftFile ofType:type];
    
    // 1. 获取两个音频源
    AVURLAsset *audioAsset1 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath1]];
    AVURLAsset *audioAsset2 = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath2]];
    
    // 2. 获取两个音频素材中的素材轨道
    AVAssetTrack *audioAssetTrack1 = [[audioAsset1 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    AVAssetTrack *audioAssetTrack2 = [[audioAsset2 tracksWithMediaType:AVMediaTypeAudio] firstObject];
    
    // 3. 向音频合成器, 添加一个空的素材容器
    AVMutableComposition *composition = [AVMutableComposition composition];
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    
    // 4. 向素材容器中, 插入音轨素材
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset2.duration) ofTrack:audioAssetTrack2 atTime:kCMTimeZero error:nil];
    [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset1.duration) ofTrack:audioAssetTrack1 atTime:audioAsset2.duration error:nil];

    // 合并后的文件导出 - `presetName`要和之后的`session.outputFileType`相对应。
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
    NSString *newPath = [NSString stringWithFormat:@"%@_new",[AudioPublicMethod getCurrentTimeString]];
    
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",newPath,type]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    // 查看当前session支持的fileType类型
    session.outputURL = [NSURL fileURLWithPath:filePath];
    session.outputFileType = AVFileTypeWAVE; //与上述的`present`相对应
    session.shouldOptimizeForNetworkUse = YES;   //优化网络
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        switch (session.status)
        {
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusCompleted:
            case AVAssetExportSessionStatusFailed:
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if (session.status == AVAssetExportSessionStatusCompleted)
                    {
                        NSString *newFilePath = [[AudioPublicMethod getPathByFileName:newPath ofType:type] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        
                        NSURL *audioURL = [NSURL fileURLWithPath:newFilePath];
                        
                        [[NSFileManager defaultManager] moveItemAtURL:session.outputURL toURL:audioURL error:nil];
                        
                        // TODO: 记录裁剪出得新音频文件,需要更新播放
                        block(newPath);
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }];
}


// 裁剪音频事件
/**
 *  裁剪音频，生成一个新的音频文件path
 *
 *  @param path          原文件路径
 *  @param leftInterval  左边时长
 *  @param rightInterval 右边时常
 *  @param allInterval   总时长
 *  @param block         新文件路径用block传
 */
- (void)cropActionWithAudioPath:(NSString*)path andLeftDuration:(NSTimeInterval)leftInterval andRightDuration:(NSTimeInterval)rightInterval andAllDuration:(NSTimeInterval)allInterval andBlock:(void(^)(NSString *newPath))block
{
    NSString *aNewPath = [NSString stringWithFormat:@"%@_new",[AudioPublicMethod getCurrentTimeString]];
//    [self cutPathWithPathwav:path andType:@"wav" andLeftDuration:leftInterval andRightDuration:rightInterval andNewPath:aNewPath andBlock:^(NSString *newPath) {
//        _lastVedio = aNewPath;
//        block(newPath);
//    }];
    
    [self cutPathWithPathWavNew:path andType:@"wav" andLeftDuration:leftInterval andRightDuration:rightInterval andAllDuration:allInterval andNewPath:aNewPath andBlock:^(NSString *newPath) {
        _lastVedio = newPath;
        block(newPath);
    }];
}

//切从0到左，右到底的时间
- (void)cutPathWithPathWavNew:(NSString*)path andType:(NSString*)type andLeftDuration:(NSTimeInterval)leftInterval andRightDuration:(NSTimeInterval)rightInterval andAllDuration:(NSTimeInterval)allInterval andNewPath:(NSString*)aNewPath andBlock:(void(^)(NSString *newPath))block {
    NSString *leftNewPath = [NSString stringWithFormat:@"%@_left_new",[AudioPublicMethod getCurrentTimeString]];
    [self cutPathWithPathwav:path andType:@"wav" andLeftDuration:0 andRightDuration:leftInterval andNewPath:leftNewPath andBlock:^(NSString *leftPath) {
        //导完左边，开始右边
        NSString *rightNewPath = [NSString stringWithFormat:@"%@_right_new",[AudioPublicMethod getCurrentTimeString]];
        [self cutPathWithPathwav:path andType:@"wav" andLeftDuration:rightInterval andRightDuration:allInterval andNewPath:rightNewPath andBlock:^(NSString *aNewPath) {
            //右边的也导出来了
            //现在合并2个wav
            NSArray *array = @[leftPath,aNewPath];
            if (leftInterval == 0) {
                array = @[aNewPath];
            }
            if (rightInterval == allInterval) {
                array = @[leftPath];
            }
            [self mergeFileWithFileArray:array andType:type  andBlock:^(NSString *newPath) {
                NSLog(@"newPath==%@",newPath);
                block(newPath);
            }];
            
        }];
    }];
    
}

- (void)mergeFileWithFileArray:(NSArray*)fileNameArray andType:(NSString*)type andBlock:(void(^)(NSString* newPath))block {
    AVMutableComposition *composition = [AVMutableComposition composition];
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    AVURLAsset *lastAudioAsset = nil;
    for (int i = 0; i < fileNameArray.count; i++) {
        NSString *audioPath = [AudioPublicMethod getPathByFileName:fileNameArray[i] ofType:type];
        AVURLAsset *audioAsset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];

        // 音频采集通道
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        // 音频合并 - 插入音轨文件
        if (!lastAudioAsset) {
             [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
        }else{
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAsset.duration) ofTrack:audioAssetTrack atTime:lastAudioAsset.duration error:nil];
        }
        lastAudioAsset = audioAsset;
    }
    // 合并后的文件导出 - `presetName`要和之后的`session.outputFileType`相对应。
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetPassthrough];
    NSString *newPath = [NSString stringWithFormat:@"%@_new",[AudioPublicMethod getCurrentTimeString]];

    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",newPath,type]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    // 查看当前session支持的fileType类型
    session.outputURL = [NSURL fileURLWithPath:filePath];
    session.outputFileType = AVFileTypeWAVE; //与上述的`present`相对应
    session.shouldOptimizeForNetworkUse = YES;   //优化网络
    [session exportAsynchronouslyWithCompletionHandler:^{
        
        switch (session.status)
        {
            case AVAssetExportSessionStatusCancelled:
            case AVAssetExportSessionStatusCompleted:
            case AVAssetExportSessionStatusFailed:
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    if (session.status == AVAssetExportSessionStatusCompleted)
                    {
                        NSString *newFilePath = [[AudioPublicMethod getPathByFileName:newPath ofType:type] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        
                        
                        NSURL *audioURL = [NSURL fileURLWithPath:newFilePath];
                        
                        [[NSFileManager defaultManager] moveItemAtURL:session.outputURL toURL:audioURL error:nil];
                        
                        // TODO: 记录裁剪出得新音频文件,需要更新播放
                        block(newPath);
                    }
                }];
            }
                break;
                
            default:
                break;
        }
    }];
    
}



//切的是从左到右的时间
- (void)cutPathWithPathwav:(NSString*)aPath andType:(NSString*)type andLeftDuration:(NSTimeInterval)leftInterval andRightDuration:(NSTimeInterval)rightInterval andNewPath:(NSString*)aNewPath andBlock:(void(^)(NSString *newPath))block {
    [[NSOperationQueue new] addOperationWithBlock:^{
        
        {
            NSString *currPath = [[AudioPublicMethod getPathByFileName:aPath ofType:type] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            NSString *recordAudioFilePath = currPath;
            NSURL *audioURL = [NSURL fileURLWithPath:recordAudioFilePath];
            
            AVAsset *asset = [AVAsset assetWithURL:audioURL];
            
            // get the first audio track
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
            
            AVAssetTrack *track = [tracks firstObject];
            
            // create the export session
            // no need for a retain here, the session will be retained by the
            // completion handler since it is referenced there
            
//            AVAssetExportPresetPassthrough能导出所有类型，这句很关键
            AVAssetExportSession *exportSession = [AVAssetExportSession
                                                   exportSessionWithAsset:asset
                                                   presetName:AVAssetExportPresetPassthrough];
        
            
            
            CMTimeScale scale = [track naturalTimeScale];
            //  TODO:根据左边裁剪点，对应的音频文件的播放时间点
            NSTimeInterval leftCropTime = leftInterval; // 临时还是起点
            //            leftCropTime = (_leftCropView.center.x/_waveformView.frame.size.width)*_audioPlayer.duration;
            
            
            NSTimeInterval rightCropTume = rightInterval;
            //            rightCropTume = (_rightCropView.center.x/_waveformView.frame.size.width)*_audioPlayer.duration;
            
            CMTime startTime = CMTimeMake(leftCropTime*scale, scale);
            CMTime stopTime = CMTimeMake(rightCropTume*scale, scale);
            CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
            
            // setup audio mix
//            AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
//            AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
//            
//            exportAudioMix.inputParameters = [NSArray arrayWithObject:exportAudioMixInputParameters];
            
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",aNewPath,type]];
            
            // configure export session  output with all our parameters
            exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
            exportSession.outputFileType = AVFileTypeWAVE; // output file type
            exportSession.timeRange = exportTimeRange; // trim time range
//            exportSession.audioMix = exportAudioMix; // fade in audio mix
            
            // perform the export
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                
                switch (exportSession.status)
                {
                    case AVAssetExportSessionStatusCancelled:
                    case AVAssetExportSessionStatusCompleted:
                    case AVAssetExportSessionStatusFailed:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            if (exportSession.status == AVAssetExportSessionStatusCompleted)
                            {
                                NSString *newFilePath = [[AudioPublicMethod getPathByFileName:aNewPath ofType:type] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                
                                
                                NSURL *audioURL = [NSURL fileURLWithPath:newFilePath];
                                
                                [[NSFileManager defaultManager] moveItemAtURL:exportSession.outputURL toURL:audioURL error:nil];
                                
                                // TODO: 记录裁剪出得新音频文件,需要更新播放
                                block(aNewPath);
                            }
                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
            }];
        }
    }];
}


- (void)convertPathWithPathwav2Mp3:(NSString*)aPath andType:(NSString*)type  andNewPath:(NSString*)aNewPath andBlock:(void(^)(NSString *newPath))block {
    [[NSOperationQueue new] addOperationWithBlock:^{
        
        {
            NSString *currPath = [[AudioPublicMethod getPathByFileName:aPath ofType:type] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSString *recordAudioFilePath = currPath;
            NSURL *audioURL = [NSURL fileURLWithPath:recordAudioFilePath];
            
            AVAsset *asset = [AVAsset assetWithURL:audioURL];
            
            // get the first audio track
            NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
            
            AVAssetTrack *track = [tracks firstObject];
            
            //            AVAssetExportPresetPassthrough能导出所有类型，这句很关键
            AVAssetExportSession *exportSession = [AVAssetExportSession
                                                   exportSessionWithAsset:asset
                                                   presetName:AVAssetExportPresetPassthrough];
            
            
            CMTimeScale scale = [track naturalTimeScale];
            //  TODO:根据左边裁剪点，对应的音频文件的播放时间点
            NSTimeInterval leftCropTime = 0; // 临时还是起点
            //            leftCropTime = (_leftCropView.center.x/_waveformView.frame.size.width)*_audioPlayer.duration;
            
            NSTimeInterval rightCropTume = 5;
            //            rightCropTume = (_rightCropView.center.x/_waveformView.frame.size.width)*_audioPlayer.duration;
            
            CMTime startTime = CMTimeMake(leftCropTime*scale, scale);
            CMTime stopTime = CMTimeMake(rightCropTume*scale, scale);
            CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
            
            // setup audio mix
            //            AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
            //            AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
            //
            //            exportAudioMix.inputParameters = [NSArray arrayWithObject:exportAudioMixInputParameters];
            
            
            NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@",aNewPath,@"m4a"]];
            
            // configure export session  output with all our parameters
            exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
            exportSession.outputFileType = @"com.apple.m4a-audio"; // output file type
            exportSession.timeRange = exportTimeRange; // trim time range
            //            exportSession.audioMix = exportAudioMix; // fade in audio mix
            
            // perform the export
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                DLog(@"====status==%d",(int)exportSession.status);
                switch (exportSession.status)
                {
                    case AVAssetExportSessionStatusCancelled:
                    case AVAssetExportSessionStatusCompleted:
                    case AVAssetExportSessionStatusFailed:
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            if (exportSession.status == AVAssetExportSessionStatusCompleted)
                            {
                                NSString *newFilePath = [[AudioPublicMethod getPathByFileName:aNewPath ofType:type] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                
                                
                                NSURL *audioURL = [NSURL fileURLWithPath:newFilePath];
                                
                                [[NSFileManager defaultManager] moveItemAtURL:exportSession.outputURL toURL:audioURL error:nil];
                                
                                // TODO: 记录裁剪出得新音频文件,需要更新播放
                                block(aNewPath);
                            }
                        }];
                    }
                        break;
                        
                    default:
                        break;
                }
            }];
        }
    }];
}




@end
