//
//  EMUtil.m
//  emeNew
//
//  Created by zk on 15/12/10.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "EMUtil.h"
#import "EMAlertView.h"
#import "AppDelegate.h"
#import "AddMoneyMainVC.h"
#import "ChatViewController.h"
#import "MainViewVM.h"
#import "EMWebViewController.h"
#import "LoginStatusObj.h"
#import "UIUtil.h"
#import "AllPopView.h"
#import <AVFoundation/AVFoundation.h>

@implementation EMUtil

+(NSString*)GetCurrentDate{
    NSString *currentDateStr = [EMUtil getDateStringWithDate:[NSDate date] DateFormat:@"YYYY-MM-dd"];
    return currentDateStr;
}


+(NSString*)GetCurrentTime{
    NSString *currentDateStr = [EMUtil getDateStringWithDate:[NSDate date] DateFormat:@"YYYY-MM-dd HH:mm:ss"];
    return currentDateStr;
}

+(NSDate*)parseDateFromString:(NSString*)str andFormate:(NSString*)formateStr{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formateStr]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:str];
    formatter = nil;
    return date;
}


+ (NSString*)getTimeToNowWithSec:(NSString*)str {
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:[str doubleValue]];
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *date1Str = [[self class] getDateStringWithDate:date1 DateFormat:@"YYYY-MM-dd HH:mm:ss"];
    date1 = [dateFormatter dateFromString:date1Str];
    NSDate *date2=[dateFormatter dateFromString:[[self class] GetCurrentTime]];
    NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
    int days = ((int)time)/(3600*24);
    int hours = ((int)time)%(3600*24)/3600;
    int min = ((int)time)%(3600*24)%3600/60;
    NSString *dateContent = [NSString stringWithFormat:@"%i天%i小时%i分",days,hours,min];
    if (days == 0 && hours != 0) {
        dateContent = [NSString stringWithFormat:@"%i小时前",hours];
    }else if (days == 0 && hours == 0){
        dateContent = [NSString stringWithFormat:@"%i分前",min];
    }else if(days > 0 && days < 4) {
        dateContent = [NSString stringWithFormat:@"%i天前",days];
    }else {
        dateContent = [[self class] getDateStringWithDate:date1 DateFormat:@"YYYY/MM/dd"];
    }
    return dateContent;
    
}

+ (NSString*)getTimeToNow:(NSString*)timeStr {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    
    //创建了两个日期对象
    NSDate *date1=[dateFormatter dateFromString:timeStr];
    NSDate *date2=[dateFormatter dateFromString:[[self class] GetCurrentTime]];
    //NSDate *date=[NSDate date];
    //NSString *curdate=[dateFormatter stringFromDate:date];
    
    //取两个日期对象的时间间隔：
    //这里的NSTimeInterval 并不是对象，是基本型，其实是double类型，是由c定义的:typedef double NSTimeInterval;
    NSTimeInterval time=[date2 timeIntervalSinceDate:date1];
    
    int days = ((int)time)/(3600*24);
    int hours = ((int)time)%(3600*24)/3600;
    int min = ((int)time)%(3600*24)%3600/60;
    NSString *dateContent = [NSString stringWithFormat:@"%i天%i小时%i分",days,hours,min];
    if (days == 0 && hours != 0) {
        dateContent = [NSString stringWithFormat:@"%i小时前",hours];
    }else if (days == 0 && hours == 0){
        dateContent = [NSString stringWithFormat:@"%i分前",min];
    }else if(days > 0 && days < 4) {
        dateContent = [NSString stringWithFormat:@"%i天前",days];
    }else {
        dateContent = [[self class] getYearAndMonthAndDayWithString:timeStr];
    }
    return dateContent;
}

+ (BOOL)isBetweenDate:(NSString*)beginDate andDate:(NSString*)endDate
{
    NSDate *date = [NSDate date];
    NSString *beginDateStr = [NSString stringWithFormat:@"%@ %@:00",[[self class] getDateStringWithDate:date DateFormat:@"YYYY-MM-dd"],beginDate];
    NSString *endDateStr = [NSString stringWithFormat:@"%@ %@:59",[[self class] getDateStringWithDate:date DateFormat:@"YYYY-MM-dd"],endDate];
    
    NSDate *beginsDate = [[self class] parseDateFromString:beginDateStr andFormate:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *endsDate = [[self class] parseDateFromString:endDateStr andFormate:@"YYYY-MM-dd HH:mm:ss"];
    date = [[self class] parseDateFromString:[[self class] getDateStringWithDate:date DateFormat:@"YYYY-MM-dd HH:mm:ss"] andFormate:@"YYYY-MM-dd HH:mm:ss"];
    if ([date compare:beginsDate] ==NSOrderedAscending)
        return NO;
    
    if ([date compare:endsDate] ==NSOrderedDescending)
        return NO;
    
    return YES;
}


+ (NSString*)getInitfiString {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    long long time = user.vipEndSecond.longLongValue - user.vipStartSecond.longLongValue;
    NSString *str = [NSString stringWithFormat:@"%@%lld%@",Local(@"UnlimitedChat"),time/86400,Local(@"Day")];
    if (time < 0) {
        str = [NSString stringWithFormat:@"%@0%@",Local(@"UnlimitedChat"),Local(@"Day")];
    }
    if (time/86400 > 0 && time/86400 < 1) {
        str = [NSString stringWithFormat:@"%@%lld%@",Local(@"UnlimitedChat"),time/3600,Local(@"Hour")];
    }
    return str;
}

+ (NSString *)stringWithCurrentTime
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags fromDate:[NSDate date]];
    calendar = nil;
    return[NSString stringWithFormat:@"%02d%02d%02d%02d%02d%02d", (int)[components year], (int)[components month], (int)[components day], (int)[components hour], (int)[components minute], (int)[components second]];
}

+(NSString*)getCurrentYear{
    NSString *currentDateStr = [EMUtil getDateStringWithDate:[NSDate date] DateFormat:@"YYYY"];
    return currentDateStr;
}

+ (NSString *)getDateStringWithDate:(NSDate *)date DateFormat:(NSString *)formatString{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:formatString];
    NSString *dateString = [dateFormat stringFromDate:date];
    dateFormat = nil;
    return dateString;
}

+(NSString*)getYearWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY/MM/dd"]];
    dateFormat = nil;
    return dateString;
}


+(NSString*)getYearAndMonthWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY年MM月"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY/MM/dd HH:mm:ss"]];
    dateFormat = nil;
    return dateString;
}

+(NSString*)getYearAndMonthAndDayWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY/MM/dd"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY-MM-dd HH:mm:ss"]];
    dateFormat = nil;
    return dateString;
}


+(NSString*)getMonthAndDateWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM月dd日 HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY-MM-dd HH:mm:ss"]];
    dateFormat = nil;
    return dateString;
}

+(NSString*)getMonthAndDateIntStringWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYYMM"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY年MM月"]];
    dateFormat = nil;
    return dateString;
}

+(NSString*)getRateTimeWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY年MM月dd日 HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY-MM-dd HH:mm:ss"]];
    dateFormat = nil;
    return dateString;
}

+(NSString*)getTimeWithString:(NSString*)dateStr{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:[EMUtil parseDateFromString:dateStr andFormate:@"YYYY-MM-dd HH:mm:ss"]];
    dateFormat = nil;
    return dateString;
}

+ (NSString*)getAlltimeString:(NSString*)duration {
    return [NSString stringWithFormat:@"%02d:%02d",[EMUtil getMiniterWithTime:[duration intValue]],[EMUtil getSecWithTime:[duration intValue]]];
}


+(int)getMiniterWithTime:(int)time{
    int min = (int)(time/60%60);
    return min;
}

+(int)getSecWithTime:(int)time{
    int min = (int)(time%60);
    return min;
}

+ (UIImage*) convertImageToGreyScale:(UIImage*) image{
    // Create image rectangle with current image width/height
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // Grayscale color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    // Create bitmap content with current image size and grayscale colorspace
    CGContextRef context = CGBitmapContextCreate(nil, image.size.width, image.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
    
    CGContextDrawImage(context, imageRect, [image CGImage]);
    // Create bitmap image info from pixel data in current context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    
    // Create a new UIImage object
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    
    // Release colorspace, context and bitmap information
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    CFRelease(imageRef);
    // Return the new grayscale image
    return newImage;
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}


+(NSString*)getChatTime:(NSString*)time{
    NSString *currentDate = [EMUtil GetCurrentDate];
    NSString *timeCurrentDate = [EMUtil getYearAndMonthAndDayWithString:time];
    NSString *ret = @"";
    if ([currentDate isEqualToString:timeCurrentDate]) {
        ret = [EMUtil getTimeWithString:time];
    }else{
        ret = timeCurrentDate;
    }
    return ret;
}

+ (NSString*)getMainDefaultImgNameUseSelfGender:(NSString*)gender {
    NSString *str = @"home_nophoto_m";
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        if ([gender isEqualToString:@"M"]) {
            str = @"home_nophoto_w";
        }
    }else {
        if ([@"M" isEqualToString:loginStatus.gender]) {
            str = @"home_nophoto_w";
        }
    }
    return str;
}

+ (NSString*)getMainDefaultImgName:(NSString*)gender {
    NSString *str = @"home_nophoto_w";
    if ([gender isEqualToString:@"F"]) {
        str = @"home_nophoto_m";
    }
    return str;
}


+ (NSString*)getHeaderDefaultImgNameSelfGender:(NSString*)gender {
    NSString *str = @"small_no_photo_m";
    if ([gender isEqualToString:@"M"]) {
        str = @"small_no_photo_w";
    }
    return str;
}

+ (NSString*)getHeaderDefaultImgName:(NSString*)gender {
    NSString *str = @"small_no_photo_m";
    if ([gender isEqualToString:@"F"]) {
        str = @"small_no_photo_w";
    }
    return str;
}

+ (void)pushToWebViewController:(NSString *)title requestURL:(NSString *)requestURL
{
    EMWebViewController *webVC = [[EMWebViewController alloc] init];
    webVC.weburl = requestURL;
    webVC.title = title;
    UINavigationController *navV = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [navV pushViewController:webVC animated:YES];
}


+ (NSString*)getCallHeaderDefaultImgName:(NSString*)gender {
    NSString *str = @"answer_no_photo_w";
    if ([gender isEqualToString:@"F"]) {
        str = @"answer_no_photo_m";
    }
    return str;
}


+ (NSString*)getCallInHeader {
    NSString *str = @"answer_no_photo_w";
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.gender isEqualToString:@"F"]) {
        str = @"answer_no_photo_m";
    }
    return str;
}

+ (NSString*)getPerHeaderDefaultImgNameUseSelfGender:(NSString*)gender {
    NSString *str = @"per_no_photo_m";
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        if ([gender isEqualToString:@"M"]) {
            str = @"per_no_photo_w";
        }
    }else {
        if ([@"M" isEqualToString:loginStatus.gender]) {
            str = @"per_no_photo_w";
        }
    }
  
    return str;
}

+ (NSString*)getPerHeaderDefaultImgName:(NSString*)gender {
    NSString *str = @"per_no_photo_w";
    if ([gender isEqualToString:@"M"]) {
        str = @"per_no_photo_m";
    }
    return str;
}

+ (NSAttributedString*)getAttributedStringWithAllStr:(NSString*)allStr andAllBackGroudColor:(UIColor*)backColor andSepcialStr:(NSString*)specialStr andSpecialColor:(UIColor*)sepcialColor {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:allStr];
    [str addAttribute:NSForegroundColorAttributeName value:backColor range:NSMakeRange(0,allStr.length)];
    
    NSRange range;
    range = [allStr rangeOfString:specialStr];
    if (range.location != NSNotFound) {
        [str
         addAttribute:NSForegroundColorAttributeName value:sepcialColor range:NSMakeRange(range.location,specialStr.length)];
    }else{
        [str
         addAttribute:NSForegroundColorAttributeName value:sepcialColor range:NSMakeRange(allStr.length-specialStr.length,specialStr.length)];
    }
  
    return str;
  
}

+ (void)pushToChat:(LonelyStationUser*)lonelyUser andViewController:(UIViewController*)controller {
    ChatViewController *conversationVC = [[ChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    conversationVC.targetId = lonelyUser.userID;
    conversationVC.defaultInputType = RCChatSessionInputBarInputVoice;
    conversationVC.title = lonelyUser.nickName;
    [[RCIM sharedRCIM] setGlobalMessageAvatarStyle:RC_USER_AVATAR_CYCLE];
    [controller.navigationController pushViewController:conversationVC animated:YES];
}

+ (NSString*)getFileWithUser:(LonelyStationUser*)lonelyUser{
    NSString *file = lonelyUser.file;
    if (file == nil || file.length == 0) {
        file = lonelyUser.file2;
        if (file == nil || file.length == 0) {
            file = @"";
        }
    }
    return file;
}

+ (void)chatWithUser:(LonelyUser*)lonelyUser andFirstBlock:(void(^)(void))pushChatBlock andSecondBlock:(void(^)(void))addMoneyBlock{
    //做判断，1.如果对方是收费，自己有秒数，弹提示1
    //2.如果聊天卡用完，弹购买提示
    //3.如果对方免费，谈提示无限畅聊卡，如果有聊天卡，使用聊天卡
    //4.如果无限畅聊卡都没有，谈提示
    
    //如果自己是女生，都不提示
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([@"F" isEqualToString:user.gender]) {
        pushChatBlock();
        return;
    }
    [UIUtil showHUD:[[UIApplication sharedApplication] keyWindow]];
    [self getUserInfoWithUserId:lonelyUser.userID completion:^(LonelyStationUser *userInfo) {
        [UIUtil hideHUD:[[UIApplication sharedApplication] keyWindow]];
         if ([userInfo.msgCharge isEqualToString:@"Y"]) {
             //收费
             NSString *callDes = [Local(@"MsgWithHer") stringByReplacingOccurrencesOfString:Local(@"ChatMoney") withString:[NSString stringWithFormat:@"%@%@",userInfo.msgChargeRate, Local(@"ChatMoney")]];
             if ([EMUtil isHaveTalkSecond]) {
                 [EMUtil alertMsg:callDes andTitle:Local(@"Warning") andCancelTitle:Local(@"Cancel") andCancelBlock:^{} andSureTitle:Local(@"StartChat") andSureBlock:^{
                     pushChatBlock();
                 }];
             }else{
                 //聊天卡不够，不好意思，加钱
                 [EMUtil alertMsg:Local(@"TalkTimeNotEnough") andTitle:Local(@"Warning") andCancelTitle:Local(@"NextTime") andCancelBlock:^{} andSureTitle:Local(@"OKQuickBuy") andSureBlock:^{
                     addMoneyBlock();
                 }];
             }
         }else{
             //免费
             pushChatBlock();
         }
    }];
}

+ (void)getConnectList {
    NSArray *conversationList = [[RCIMClient sharedRCIMClient]
                                 getConversationList:@[@(ConversationType_PRIVATE),
                                                       @(ConversationType_DISCUSSION)]];
    NSMutableArray *array = [NSMutableArray array];
    for (RCConversation *conversation in conversationList) {
        [self getUserInfoWithUserId:conversation.targetId completion:^(LonelyStationUser *userInfo) {
            [array addObject:userInfo];
            if (array.count == conversationList.count) {
                [[FileAccessData sharedInstance] setMemObject:array forKey:@"chatListUser"];
            }
        }];
    }
}

+ (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(LonelyStationUser* userInfo))completion{
    MainViewVM *mainViewVM = [MainViewVM new];
    [mainViewVM getPersonalInfo:userId andBlock:^(NSDictionary *dict, BOOL ret) {
        if (dict && ret) {
            if ([dict[@"code"] intValue] == 1) {
                LonelyStationUser *user = [[LonelyStationUser alloc] initWithDictory:dict[@"data"]];
                completion(user);
            }
        }
    }];
}


//打电话
+ (void)chatCallUser:(LonelyStationUser*)lonelyUser andController:(UIViewController*)controller {
    //拨打电话
    if (lonelyUser.allowTalkPeriod.length > 0) {
        NSArray *allowTalkArr = [lonelyUser.allowTalkPeriod componentsSeparatedByString:@"-"];
        if (allowTalkArr.count == 2) {
            NSString *startTime = allowTalkArr[0];
            NSString *endTime = allowTalkArr[1];
            if (![EMUtil isBetweenDate:startTime andDate:endTime]) {
                //如果不在这个范围内，不能打电话
                AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"NotAllowed") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
                    
                } cancelButtonTitle:Local(@"IKnowRecordIsTooShort") otherButtonTitles:nil];
                [alert show];
                alert = nil;
                return;
            }
        }
    }
    //如果自己是女生，都不提示
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([@"F" isEqualToString:user.gender]) {
        [EMUtil pushToCall:lonelyUser andController:controller];
        return;
    }
    //做判断，1.如果对方是收费，自己有秒数，弹提示1
    //2.如果聊天卡用完，弹购买提示
    //3.如果对方免费，谈提示无限畅聊卡，如果有聊天卡，使用聊天卡
    //4.如果无限畅聊卡都没有，弹提示
    //获取费率
    [UIUtil showHUD:[[UIApplication sharedApplication] keyWindow]];
    [self getUserInfoWithUserId:lonelyUser.userID completion:^(LonelyStationUser *userInfo) {
        [UIUtil hideHUD:[[UIApplication sharedApplication] keyWindow]];
        if ([userInfo.talkCharge isEqualToString:@"Y"]) {
            NSString *callDes = Local(@"ChatWithHer");
            callDes = [callDes stringByReplacingOccurrencesOfString:Local(@"ChatMoney") withString:[NSString stringWithFormat:@"%@%@",userInfo.talkChargeRate, Local(@"ChatMoney")]];
            if ([EMUtil isHaveTalkSecond]) {
                [EMUtil alertMsg:callDes andTitle:Local(@"Warning") andCancelTitle:Local(@"Cancel") andCancelBlock:^{} andSureTitle:Local(@"StartChat") andSureBlock:^{
                    [EMUtil pushToCall:lonelyUser andController:controller];
                }];
            }else{
                //聊天卡不够，不好意思，加钱
                [EMUtil alertMsg:Local(@"TalkTimeNotEnough") andTitle:Local(@"Warning") andCancelTitle:Local(@"NextTime") andCancelBlock:^{} andSureTitle:Local(@"OKQuickBuy") andSureBlock:^{
                    AddMoneyMainVC *addMoneyMainVC = [[AddMoneyMainVC alloc] init];
                    [controller.navigationController pushViewController:addMoneyMainVC animated:YES];
                }];
            }
        }else{
            [EMUtil pushToCall:lonelyUser andController:controller];
        }
    }];
}

+ (void)pushToCall:(LonelyStationUser*)lonelyUser andController:(UIViewController*)controller {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.callViewController.callStatus = CallOut;
    appDelegate.callViewController.toUser = lonelyUser;
    appDelegate.callViewController.fromUser = [ViewModelCommom getCuttentUser];
    [controller.navigationController pushViewController:appDelegate.callViewController animated:YES];
}

+ (float)getAudioSecWithFilePath:(NSString*)filePath {
    return [self getAudioSecWithURL:filePath];
}


+ (float)getAudioSecWithURL:(NSString*)urlStr {
    if (urlStr == nil || [urlStr isEqual:[NSNull null]]) {
        return 0;
    }
    //只有这个方法获取时间是准确的 audioPlayer.duration获得的时间不准
    AVURLAsset* audioAsset = nil;
    NSDictionary *dic = @{AVURLAssetPreferPreciseDurationAndTimingKey:@(YES)};
    if ([urlStr hasPrefix:@"http://"]) {
        audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:urlStr] options:dic];
    }else {//播放本机录制的文件
        audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:urlStr] options:dic];
    }
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}



+ (BOOL)isHaveLimitSecond {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.vipEndSecond longLongValue] - [[NSDate date] timeIntervalSince1970] > 0) {
        return YES;
    }
    return NO;
}

+ (BOOL)isHaveTalkSecond {
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if ([user.chat_point intValue] > 0) {
        return YES;
    }
    return NO;
}

+ (void)alertMsg:(NSString*)msg andTitle:(NSString*)title andCancelTitle:(NSString*)cancelTitle andCancelBlock:(void(^)(void))cancelBlock andSureTitle:(NSString*)sureTitle andSureBlock:(void(^)(void))sureBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        AllPopView *alert = [[AllPopView alloc] initWithTitle:title message:msg clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                if (sureBlock) {
                    sureBlock();
                }
            }else {
                if (cancelBlock) {
                    cancelBlock();
                }
            }
        } cancelButtonTitle:cancelTitle otherButtonTitles:sureTitle, nil];
        [alert show];
        alert = nil;
    });
}

+ (EMLabel*)createLabelWithFont:(UIFont*)font andColor:(UIColor*)color {
    EMLabel *label = [EMLabel new];
    [label setFont:font];
    label.textColor = color;
    return label;
}

///获取所有的在线的能打电话的用户
+ (NSArray*)getUserOnLineInAllArray:(NSArray*)arr {
    NSMutableArray *onlineArray = [NSMutableArray array];
    if (arr && arr.count > 0) {
        //取出在线的能接电话的用户
        for (int i = 0;i<arr.count;i++) {
            LonelyStationUser *lonelyUser = arr[i];
            if ([lonelyUser.allowTalk intValue] == 1) {
                if (lonelyUser.isOnLine && [lonelyUser.identity isEqualToString:@"3"] && [lonelyUser.optState isEqualToString:@"Y"] && [lonelyUser.connectStat isEqualToString:@"N"]) {
                        [onlineArray addObject:lonelyUser];
                }
            }
        }
        
    }
    return onlineArray;
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


@end
