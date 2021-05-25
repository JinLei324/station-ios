//
//  EMUtil.h
//  emeNew
//
//  Created by zk on 15/12/10.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AllPopView.h"
@class LonelyStationUser;
@class LonelyUser;

@interface EMUtil : NSObject

+(NSString*)GetCurrentDate;

+(NSString*)GetCurrentTime;

+ (NSString *)getDateStringWithDate:(NSDate *)date DateFormat:(NSString *)formatString;

+(NSDate*)parseDateFromString:(NSString*)str andFormate:(NSString*)formateStr;

+ (NSString *)stringWithCurrentTime;

+(NSString*)getCurrentYear;

+(NSString*)getYearAndMonthWithString:(NSString*)dateStr;

+(NSString*)getYearWithString:(NSString*)dateStr;

+(NSString*)getYearAndMonthAndDayWithString:(NSString*)dateStr;

+(NSString*)getMonthAndDateWithString:(NSString*)dateStr;

+(NSString*)getMonthAndDateIntStringWithString:(NSString*)dateStr;

+(int)getMiniterWithTime:(int)time;

+(int)getSecWithTime:(int)time;

+(NSString*)getRateTimeWithString:(NSString*)dateStr;

+ (NSString*)getAlltimeString:(NSString*)duration;

+(NSString*)getTimeWithString:(NSString*)dateStr;

+ (UIImage*) convertImageToGreyScale:(UIImage*) image;

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

+(NSString*)getChatTime:(NSString*)time;

+ (NSString*)getTimeToNow:(NSString*)timeStr;

+ (NSString*)getTimeToNowWithSec:(NSString*)str ;

+ (BOOL)isBetweenDate:(NSString*)beginDate andDate:(NSString*)endDate;

+ (NSString*)getMainDefaultImgName:(NSString*)gender;

+ (NSString*)getHeaderDefaultImgName:(NSString*)gender;

+ (NSString*)getCallHeaderDefaultImgName:(NSString*)gender;

+ (NSString*)getPerHeaderDefaultImgName:(NSString*)gender;

+ (NSAttributedString*)getAttributedStringWithAllStr:(NSString*)allStr andAllBackGroudColor:(UIColor*)backColor andSepcialStr:(NSString*)specialStr andSpecialColor:(UIColor*)sepcialColor;

+ (NSString*)getInitfiString;

+ (NSString*)getMainDefaultImgNameUseSelfGender:(NSString*)gender;

+ (NSString*)getPerHeaderDefaultImgNameUseSelfGender:(NSString*)gender;

+ (void)chatCallUser:(LonelyStationUser*)lonelyUser andController:(UIViewController*)controller;

+ (BOOL)isHaveLimitSecond;

+ (BOOL)isHaveTalkSecond;

+ (NSString*)getFileWithUser:(LonelyStationUser*)lonelyUser;

+ (void)pushToChat:(LonelyStationUser*)lonelyUser andViewController:(UIViewController*)controller;

+ (void)chatWithUser:(LonelyUser*)lonelyUser andFirstBlock:(void(^)(void))pushChatBlock andSecondBlock:(void(^)(void))addMoneyBlock;

+ (EMLabel*)createLabelWithFont:(UIFont*)font andColor:(UIColor*)color;

+ (void)alertMsg:(NSString*)msg andTitle:(NSString*)title andCancelTitle:(NSString*)cancelTitle andCancelBlock:(void(^)(void))cancelBlock andSureTitle:(NSString*)sureTitle andSureBlock:(void(^)(void))sureBlock;

+ (void)pushToWebViewController:(NSString *)title requestURL:(NSString *)requestURL;

+ (NSArray*)getUserOnLineInAllArray:(NSArray*)arr;

+ (NSString*)getHeaderDefaultImgNameSelfGender:(NSString*)gender;

+ (void)getConnectList;

+ (NSString*)getCallInHeader;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


+ (float)getAudioSecWithURL:(NSString*)urlStr;

+ (float)getAudioSecWithFilePath:(NSString*)filePath;

@end
