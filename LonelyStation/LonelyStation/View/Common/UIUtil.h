//
//  UIUtil.h
//  emeNew
//
//  Created by zk on 15/12/15.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EMLabel.h"
#import "EMTextField.h"
#import "EMView.h"
#import "EMButton.h"
#import "EMAlertView.h"
#import "EMTableView.h"
#import "MJRefresh.h"
#import "EMImageView.h"
#import "Masonry.h"


@interface UIUtil : NSObject

+(BOOL)isValidateEmail:(NSString *)email;


+(BOOL)checkTextIsNotNull:(NSString*)str;



+(MJRefreshStateHeader*)createTableHeaderWithSel:(SEL)action andTarget:(id)target;

+(MJRefreshAutoStateFooter*)createTableFooterWithSel:(SEL)action andTarget:(id)target;

+(EMImageView*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect andTextField:(EMTextField*)field;

+(EMButton*)buttonWithName:(NSString*)name andFrame:(CGRect)rect andSelector:(SEL)selector andTarget:(id)target isEnable:(BOOL)isEnable;

+(EMButton*)createWhiteBtnWithFrame:(CGRect)rect andTitle:(NSString*)title andSelector:(SEL)selector andTarget:(id)target;

+(EMButton*)createPurpleBtnWithFrame:(CGRect)rect andTitle:(NSString*)title andSelector:(SEL)selector andTarget:(id)target;

+(EMLabel*)createLabel:(NSString*)name andRect:(CGRect)rect andTextColor:(UIColor*)color andFont:(UIFont*)font andAlpha:(CGFloat)alpha;

+(EMTextField*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect andSuperView:(UIView*)superView;

+ (void)showInfo:(NSString*)info;


+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset;

+(UIImage*)circleImage:(UIColor*)color andSize:(CGSize)size;

+ (void)showHUD:(UIView*)view;

+ (void)hideHUD:(UIView*)view;

+ (void)addLineWithSuperView:(UIView*)view andRect:(CGRect)rect;

+ (void)addLineWithSuperView:(UIView*)view andRect:(CGRect)rect andColor:(UIColor*)color;

+ (UIView *)lastControllerView;

+ (EMButton*)createLoginBtnWithFrame:(CGRect)rect andTitle:(NSString*)title andSelector:(SEL)selector andTarget:(id)target;

+ (BOOL)checkLogin;

+ (BOOL)haveDeviceAuthorization;

+ (void)showDeviceWarning;

+ (BOOL)alertVoiceRecordWarning:(UIViewController*)controller andMsg:(NSString*)msg;

+ (BOOL)alertProfileWarning:(UIViewController*)controller andMsg:(NSString*)msg;


+(NSMutableAttributedString*)getAttrStr:(NSString*)allStr andAllColor:(UIColor*)color andDstStr:(NSString*)dstStr andDstColor:(UIColor*)dstColor;
@end
