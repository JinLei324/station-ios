//
//  GlobalDefine.h
//  CustomNavigationBarDemo
//
//  Created by jimple on 14-1-6.
//  Copyright (c) 2014年 Jimple Chen. All rights reserved.
//

#ifndef CustomNavigationBarDemo_GlobalDefine_h
#define CustomNavigationBarDemo_GlobalDefine_h

#import "UtilityFunc.h"
#import "UIView+Toast.h"
#import "YYModel.h"
#import "YYImage.h"
#import "YYWebImage.h"
#import "NetAccess.h"
#import "ViewModelCommom.h"


#define USERSER @"https://app.thevoicelover.com"
//#define USERSER @"https://testapp.thevoicelover.com"


#define EMKEY "EmeTechPush"
#define HTTPTIMEOUT 20
#ifdef DEBUG

#define ENABLE_ASSERT_STOP          1
#define ENABLE_DEBUGLOG             1

#endif


// 颜色日志
#define XCODE_COLORS_ESCAPE_MAC @"\033["
#define XCODE_COLORS_ESCAPE_IOS @"\xC2\xA0["
#define XCODE_COLORS_ESCAPE  XCODE_COLORS_ESCAPE_MAC
#define XCODE_COLORS_RESET_FG  XCODE_COLORS_ESCAPE @"fg;" // Clear any foreground color
#define XCODE_COLORS_RESET_BG  XCODE_COLORS_ESCAPE @"bg;" // Clear any background color
#define XCODE_COLORS_RESET     XCODE_COLORS_ESCAPE @";"   // Clear any foreground or background color
#define LogBlue(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,150,255;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#define LogRed(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg250,0,0;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)
#define LogGreen(frmt, ...) NSLog((XCODE_COLORS_ESCAPE @"fg0,235,30;" frmt XCODE_COLORS_RESET), ##__VA_ARGS__)

// debug log
#ifdef ENABLE_DEBUGLOG
#define APP_DebugLog(...) NSLog(__VA_ARGS__)
#define APP_DebugLogBlue(...) LogBlue(__VA_ARGS__)
#define APP_DebugLogRed(...) LogRed(__VA_ARGS__)
#define APP_DebugLogGreen(...) LogGreen(__VA_ARGS__)
#else
#define APP_DebugLog(...) do { } while (0);
#define APP_DebugLogBlue(...) do { } while (0);
#define APP_DebugLogRed(...) do { } while (0);
#define APP_DebugLogGreen(...) do { } while (0);
#endif

// log
#define APP_Log(...) NSLog(__VA_ARGS__)


// assert
#ifdef ENABLE_ASSERT_STOP
#define APP_ASSERT_STOP                     {LogRed(@"APP_ASSERT_STOP"); NSAssert1(NO, @" \n\n\n===== APP Assert. =====\n%s\n\n\n", __PRETTY_FUNCTION__);}
#define APP_ASSERT(condition)               {NSAssert(condition, @" ! Assert");}
#else
#define APP_ASSERT_STOP                     do {} while (0);
#define APP_ASSERT(condition)               do {} while (0);
#endif


/////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Redefine

#define HAVE_WECHAT_BUILD
#define KWXAPPID @"wxc25d5746d95833bc"
#define KWXAPPSECRET @"a533d195e0de29e7525ee0d97efbd8f8"
#define UMENG_APPKEY @"5503e6fcfd98c5a13f000756"
#define YunBaAppKey @"55c568bf9477ebf5246955f7"
//#define AppKey @"55a311eec75ecd535d69b69f"

#define IMGURLSER @"http://oss.emitong.cn/app/theme/"

#define BlurAlpha 0
#define Line RGB(0xd9,0xd9,0xd9)
#define ColorF2 RGB(0xf2, 0xf2, 0xf2)
#define ColorCd RGB(0xcd, 0xcd, 0xcd)
#define Color4c RGB(0x4c, 0x4c, 0x4c)
#define Color80 RGB(0x80, 0x80, 0x80)
#define Color33 RGB(0x33, 0x91, 0xe8)
#define ColorF4 RGB(0xf4, 0xf4, 0xf4)
#define Color00 RGB(0x0,0x0,0x0)
#define ColorFF RGB(0xff,0xff,0xff)
#define Color5b RGB(0xff,0x5b,0x45);
#define WhiteHead RGB(0xfa,0xfa,0xfa)


#define ERRORKEY @"msg"

#define ERRORTime 1

#define WS(weakSelf) __weak __typeof(&*self)weakSelf = self;
#define SS(weakSelf,strongSelf) __strong __typeof(weakSelf)strongSelf = weakSelf;

#define Local(a) NSLocalizedStringFromTable(a, @"Localization", nil)
#define NOTNULLObj(a)  ([[NSNull null] isEqual:a]|| a==nil) ? @"" : a


#define PositionY(View)  View.frame.origin.y+View.frame.size.height
#define PositionX(View)  View.frame.origin.x+View.frame.size.width

#define ApplicationDelegate                 ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define UserDefaults                        [NSUserDefaults standardUserDefaults]
#define SharedApplication                   [UIApplication sharedApplication]
#define Bundle                              [NSBundle mainBundle]
#define BundlePath(a,b)                              [[NSBundle mainBundle] pathForResource:a ofType:b]


#define MainScreen                          [UIScreen mainScreen]
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO
#define NetworkActivityIndicatorVisible(x)  [UIApplication sharedApplication].networkActivityIndicatorVisible = x
#define SelfNavBar                          self.navigationController.navigationBar
#define SelfTabBar                          self.tabBarController.tabBar
#define SelfNavBarHeight                    self.navigationController.navigationBar.bounds.size.height
#define SelfTabBarHeight                    self.tabBarController.tabBar.bounds.size.height
#define ScreenRect                          [[UIScreen mainScreen] bounds]
#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height
#define TouchHeightDefault                  44
#define TouchHeightSmall                    32
#define ViewWidth(v)                        v.frame.size.width
#define ViewHeight(v)                       v.frame.size.height
#define ViewX(v)                            v.frame.origin.x
#define ViewY(v)                            v.frame.origin.y
#define SelfViewHeight                      self.view.bounds.size.height
#define RectX(f)                            f.origin.x
#define RectY(f)                            f.origin.y
#define RectWidth(f)                        f.size.width
#define RectHeight(f)                       f.size.height
#define RectSetWidth(f, w)                  CGRectMake(RectX(f), RectY(f), w, RectHeight(f))
#define RectSetHeight(f, h)                 CGRectMake(RectX(f), RectY(f), RectWidth(f), h)
#define RectSetX(f, x)                      CGRectMake(x, RectY(f), RectWidth(f), RectHeight(f))
#define RectSetY(f, y)                      CGRectMake(RectX(f), y, RectWidth(f), RectHeight(f))
#define RectSetSize(f, w, h)                CGRectMake(RectX(f), RectY(f), w, h)
#define RectSetOrigin(f, x, y)              CGRectMake(x, y, RectWidth(f), RectHeight(f))
#define Rect(x, y, w, h)                    CGRectMake(x, y, w, h)
#define DATE_COMPONENTS                     NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
#define TIME_COMPONENTS                     NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
#define FlushPool(p)                        [p drain]; p = [[NSAutoreleasePool alloc] init]
#define RGB(r, g, b)                        [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]
#define RGBA(r, g, b, a)                    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define StatusBarHeight                     [UIApplication sharedApplication].statusBarFrame.size.height
#define SelfDefaultToolbarHeight            self.navigationController.navigationBar.frame.size.height
#define IOSVersion                          [[[UIDevice currentDevice] systemVersion] floatValue]
#define IsiOS7Later                         !(IOSVersion < 7.0)
#define IsiOS8Later                         (IOSVersion > 8.2)
#define IsiOS10Later                        (IOSVersion >= 10.0)


#define Size(w, h)                          CGSizeMake(w, h)
#define Point(x, y)                         CGPointMake(x, y)
#define ComFont(x)                          [UIFont systemFontOfSize:x]
//#define BoldFont(x)                         [UIFont boldSystemFontOfSize:x]
#define BoldFont(x)        (IsiOS8Later?[UIFont systemFontOfSize:x weight:UIFontWeightSemibold]:[UIFont boldSystemFontOfSize:x])
#define TabBarHeight                        49.0f
#define NaviBarHeight                       44.0f
#define HeightFor4InchScreen                568.0f
#define HeightFor3p5InchScreen              480.0f

#define ViewCtrlTopBarHeight                (IsiOS7Later ? (NaviBarHeight + StatusBarHeight) : NaviBarHeight)
#define IsUseIOS7SystemSwipeGoBack          (IsiOS7Later ? YES : NO)




//////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - app define


#define AppBarStyle              [UtilityFunc barStyle]
#define Is4Inch                                 [UtilityFunc is4InchScreen]
#define IsIPhone4                                [UtilityFunc isIPhone4]
#define IsIPhoneX                                [UtilityFunc isIPhoneX]
#define GETCountryCode [UtilityFunc getCountryCode]
#define GETLang [UtilityFunc getLang]
#define GETLangCode [UtilityFunc getLanguageCode]

#define Is320 [UtilityFunc is320]

#define kScale [UtilityFunc getScale]


#define RGB_AppWhite                            RGB(252.0f, 252.0f, 252.0f)

#define RGB_TextLightGray                       RGB(200.0f, 200.0f, 200.0f)
#define RGB_TextMidLightGray                    RGB(127.0f, 127.0f, 127.0f)
#define RGB_TextDarkGray                        RGB(100.0f, 100.0f, 100.0f)
#define RGB_TextLightDark                       RGB(50.0f, 50.0f, 50.0f)
#define RGB_TextDark                            RGB(10.0f, 10.0f, 10.0f)
#define RGB_TextAppOrange                       RGB(224.0f, 83.0f, 51.0f)
#define SIZE_TextSmall                          10.0f
#define SIZE_TextContentNormal                  13.0f
#define SIZE_TextTitleMini                      15.0f
#define SIZE_TextTitleNormal                    17.0f
#define SIZE_TextLarge                          16.0f
#define SIZE_TextHuge                           18.0f



#endif
