//
//  UtilityFunc.m
//  CustomNavigationBarDemo
//
//  Created by jimple on 14-1-6.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#import "UtilityFunc.h"
#import "GlobalDefine.h"

@implementation UtilityFunc



// 是否4英寸屏幕
+ (BOOL)is4InchScreen
{
    static BOOL bIs4Inch = NO;
    static BOOL bIsGetValue = NO;
    
    if (!bIsGetValue)
    {
        CGRect rcAppFrame = [UIScreen mainScreen].bounds;
        bIs4Inch = (rcAppFrame.size.height == 568.0f);
        
        bIsGetValue = YES;
    }else{}
    
    return bIs4Inch;
}


+ (BOOL)isIPhone4{
    CGRect rcAppFrame = [UIScreen mainScreen].bounds;
    BOOL bIs4Inch = (rcAppFrame.size.height == 480.0f);
    return bIs4Inch;
}

+ (NSInteger)barStyle {
    return UIStatusBarStyleDefault;
}




+ (BOOL)isIPhoneX{
    return  (kScreenW == 375.f && kScreenH == 812.f);
}

+ (NSString*)getLang {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *str = [languages objectAtIndex:0];
    return str;
}

+ (NSString *)getCountryCode
{    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *str = [languages objectAtIndex:0];
    if ([str hasPrefix:@"zh-Hans"]) {
        return @"zh_cn";
    }else if ([str hasPrefix:@"zh-Hant"]||[str hasPrefix:@"zh-HK"]||[str hasPrefix:@"zh-"]){
        return @"zh_tw";
    }else{
        return @"en";
    }
}

+ (NSString *)getLanguageCode
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
}

+ (CGFloat)getScale {
    CGFloat ret = 1;
    if (iphone6_4_7) {
        ret = 1;
    }
    if(iphone6Plus_5_5){
        ret = 1.104f;
    }
    if (!iphone6_4_7 && !iphone6Plus_5_5) {
        ret = 0.853f;
    }    
    return ret;
}

+ (BOOL)is320{
    CGRect rcAppFrame = [UIScreen mainScreen].bounds;
    BOOL bIs4Inch = (rcAppFrame.size.width == 320.f);
    return bIs4Inch;
}

// label设置最小字体大小
+ (void)label:(UILabel *)label setMiniFontSize:(CGFloat)fMiniSize forNumberOfLines:(NSInteger)iLines
{
    if (label)
    {
        label.adjustsFontSizeToFitWidth = YES;
        label.minimumScaleFactor = fMiniSize/label.font.pointSize;
    }else{}
}

// 清除PerformRequests和notification
+ (void)cancelPerformRequestAndNotification:(UIViewController *)viewCtrl
{
    if (viewCtrl)
    {
        [[viewCtrl class] cancelPreviousPerformRequestsWithTarget:viewCtrl];
        [[NSNotificationCenter defaultCenter] removeObserver:viewCtrl];
    }else{}
}

// 重设scroll view的内容区域和滚动条区域
+ (void)resetScrlView:(UIScrollView *)sclView contentInsetWithNaviBar:(BOOL)bHasNaviBar tabBar:(BOOL)bHasTabBar
{
    [[self class] resetScrlView:sclView contentInsetWithNaviBar:bHasNaviBar tabBar:bHasTabBar iOS7ContentInsetStatusBarHeight:0 inidcatorInsetStatusBarHeight:0];
}
+ (void)resetScrlView:(UIScrollView *)sclView contentInsetWithNaviBar:(BOOL)bHasNaviBar tabBar:(BOOL)bHasTabBar iOS7ContentInsetStatusBarHeight:(NSInteger)iContentMulti inidcatorInsetStatusBarHeight:(NSInteger)iIndicatorMulti
{
    if (sclView)
    {
        UIEdgeInsets inset = sclView.contentInset;
        UIEdgeInsets insetIndicator = sclView.scrollIndicatorInsets;
        CGPoint ptContentOffset = sclView.contentOffset;
        CGFloat fTopInset = bHasNaviBar ? NaviBarHeight : 0.0f;
        CGFloat fTopIndicatorInset = bHasNaviBar ? NaviBarHeight : 0.0f;
        CGFloat fBottomInset = bHasTabBar ? TabBarHeight : 0.0f;
        
        fTopInset += StatusBarHeight;
        fTopIndicatorInset += StatusBarHeight;
        
        if (IsiOS7Later)
        {
            fTopInset += iContentMulti * StatusBarHeight;
            fTopIndicatorInset += iIndicatorMulti * StatusBarHeight;
        }else{}
        
        inset.top += fTopInset;
        inset.bottom += fBottomInset;
        [sclView setContentInset:inset];
        
        insetIndicator.top += fTopIndicatorInset;
        insetIndicator.bottom += fBottomInset;
        [sclView setScrollIndicatorInsets:insetIndicator];
        
        ptContentOffset.y -= fTopInset;
        [sclView setContentOffset:ptContentOffset];
    }else{}
}





@end
