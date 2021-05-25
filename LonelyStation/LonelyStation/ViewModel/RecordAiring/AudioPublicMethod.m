//
//  AudioPublicMethod.m
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "AudioPublicMethod.h"
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

@implementation AudioPublicMethod

+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString *documentPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@Downloads",@"zk"]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString* fileDirectory = [[documentPath stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    
    return fileDirectory;
}
+ (NSDictionary*)getAudioRecorderSettingDict
{
    NSDictionary *settings = @{AVFormatIDKey: @(kAudioFormatLinearPCM),
                               AVSampleRateKey: @8000.00f,
                               AVNumberOfChannelsKey: @1,
                               AVLinearPCMBitDepthKey: @16,
                               AVLinearPCMIsNonInterleaved: @NO,
                               AVLinearPCMIsFloatKey: @NO,
                               AVLinearPCMIsBigEndianKey: @NO};
    return settings;
    
//    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                   [NSNumber numberWithFloat: 8000],AVSampleRateKey, //采样率
//                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
//                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
//                                   [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,//通道的数目
//                                   
//                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,//大端还是小端 是内存的组织方式
//                                   //                                   [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,//采样信号是整数还是浮点数
//                                                                      [NSNumber numberWithInt: AVAudioQualityMedium],AVEncoderAudioQualityKey,//音频编码质量
//                                   nil];
//    return recordSetting;
}

/**
 *  删除文件
 *
 *  @param _path 文件路径
 *
 *  @return 返回YES/ON
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path
{
    return [[NSFileManager defaultManager] removeItemAtPath:_path error:nil];
}

/**
 *  生成当前时间字符串
 *
 *  @return 当前时间字符串
 */
+ (NSString*)getCurrentTimeString
{
    NSDateFormatter *dateformat=[[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmssSSS"];
    return [dateformat stringFromDate:[NSDate date]];
}

/**
 *  获取音频文件时长
 *
 *  @param vedioURL 语音路径
 *
 *  @return 返回 音频文件时长
 */
+(int)getVedioLength:(NSString*)vedioURL{
    NSURL *tempUrl = [NSURL URLWithString:[[[self class] getPathByFileName:vedioURL ofType:@"wav"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    AVAudioPlayer *tempPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tempUrl error:nil];
    NSTimeInterval s = tempPlayer.duration;
    int m = round(s);
    return m;
}
/**
 *  判断字符串是否为空
 *
 *  @param str 需要判断的字符串
 *
 *  @return 是否为空
 */
+(BOOL)stringIsClassNull:(NSString*)str{
    NSString *string = [NSString stringWithFormat:@"%@",str];
    if ([string isKindOfClass:[NSNull class]]||[string isEqualToString:@"<null>"]||[string isEqualToString:@"(null)"]||string.length==0) {
        return YES;
    }
    return NO;
}


/**
 *  检测麦克风访问 ios 7 之后系统带有的
 *
 *  @return 是否有权限访问麦克风
 */
+ (BOOL)checkRecordPermission {
    __block BOOL canRecord=YES;
    if ([[[UIDevice currentDevice] systemName] compare:@"7.0"]!=NSOrderedAscending) {
        AVAudioSession* audioSession=[AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted){
                if (granted) {
                    canRecord=YES;
                }
                else{
                    UIAlertView* alert=[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:Local(@"MicPhoneAccess")] delegate:self cancelButtonTitle:nil otherButtonTitles:Local(@"IKnowRecordIsTooShort"), nil];
                    [alert show];
                }
            }];
        }
    }
    return canRecord;
}

/**
 *  通过文件url生成波形图
 *
 *  @param url       <#url description#>
 *  @param width     <#width description#>
 *  @param hight     <#hight description#>
 *  @param backColor <#backColor description#>
 *  @param waveColor <#waveColor description#>
 *
 *  @return <#return value description#>
 */
+ (UIImage*)soundImgWithSamples:(NSArray*)array andWidth:(CGFloat)width andHight:(CGFloat)hight andBackColor:(UIColor*)backColor andWaveColor:(UIColor*)waveColor {
    UIImage *renderedImage = [[self class] drawImgFromSamples:array sampleCount:array.count andWidth:width andHight:hight andBackColor:backColor andWaveColor:waveColor];
    return renderedImage;
}

+ (UIImage*) drawImgFromSamples:(NSArray*)samples
                    sampleCount:(NSInteger)sampleCount andWidth:(CGFloat)width andHight:(CGFloat)hight andBackColor:(UIColor*)backgroundColor andWaveColor:(UIColor*)wavesColor {
    BOOL _drawSpaces = YES;
    CGFloat lastWidth = (sampleCount * 2 > width) ? width : sampleCount*2;
    CGSize imageSize = CGSizeMake(lastWidth, hight);
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, backgroundColor.CGColor);
    CGContextSetAlpha(context, 1.0);
    
    CGRect rect;
    rect.size = imageSize;
    rect.origin.x = 0;
    rect.origin.y = 0;
    
    CGColorRef waveColor = wavesColor.CGColor;
    
    CGContextFillRect(context, rect);
    
    CGContextSetLineWidth(context, 1.0);
    
    float channelCenterY = imageSize.height / 2;
    
    for (NSInteger i = 0; i < sampleCount; i++)
    {
        float sample = [samples[i] floatValue];
        u_int16_t val = 0;
        if (sample >= -10) {
            if (sample >= 0) {
                sample = 0;
            }
            val = ((sample + 11.0) / 18.0)*(hight);
        }else{
            val = (-10.0 /sample) * (hight)/18;
        }
        val += 3;
        
        
        if ((int)val == 0)
            val = 1.0; // draw dots instead emptyness
        CGContextMoveToPoint(context, i * (_drawSpaces ? 2 : 1), channelCenterY - val / 2.0);
        CGContextAddLineToPoint(context, i * (_drawSpaces ? 2 : 1), channelCenterY + val / 2.0);
        CGContextSetStrokeColorWithColor(context, waveColor);
        CGContextStrokePath(context);
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
//    newImage = [AudioPublicMethod imageCompressForSize:newImage targetSize:Size(width, hight)];
    return newImage;
}

+(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();  
    return newImage;  
}  


+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
            
        }
        else{
            
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
}


@end
