//
//  AudioPublicMethod.h
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMObject.h"

@interface AudioPublicMethod : EMObject
/**
 *  获取音频文件的路径
 *
 *  @param _fileName 文件名
 *  @param _type     文件后缀名
 *
 *  @return 返回文件路径
 */
+ (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type;
+ (NSDictionary*)getAudioRecorderSettingDict;


/**
 *  删除文件
 *
 *  @param _path 文件路径
 *
 *  @return 返回YES/ON
 */
+ (BOOL)deleteFileAtPath:(NSString*)_path;

/**
 *  生成当前时间字符串
 *
 *  @return 当前时间字符串
 */
+ (NSString*)getCurrentTimeString;

/**
 *  获取音频文件时长
 *
 *  @param vedioURL 语音路径
 *
 *  @return 返回 音频文件时长
 */
+(int)getVedioLength:(NSString*)vedioURL;

/**
 *  判断字符串是否为空
 *
 *  @param str 需要判断的字符串
 *
 *  @return 是否为空
 */
+(BOOL)stringIsClassNull:(NSString*)str;

/**
 *  检测麦克风访问 ios 7 之后系统带有的
 *
 *  @return 是否有权限访问麦克风
 */
+ (BOOL)checkRecordPermission;



+ (UIImage*)soundImgWithSamples:(NSArray*)array andWidth:(CGFloat)width andHight:(CGFloat)hight andBackColor:(UIColor*)backColor andWaveColor:(UIColor*)waveColor;


@end
