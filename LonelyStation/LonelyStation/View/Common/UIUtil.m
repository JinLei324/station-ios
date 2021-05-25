//
//  UIUtil.m
//  emeNew
//
//  Created by zk on 15/12/15.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "UIUtil.h"
#import "YYWebImage.h"
#import "EMImageView.h"
#import "EMLabel.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "LoginStatusObj.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "RecordIntroduceVC.h"
#import "MyInfoVC.h"

@implementation UIUtil

+(MJRefreshStateHeader*)createTableHeaderWithSel:(SEL)action andTarget:(id)target{
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:target  refreshingAction:action];
    header.stateLabel.textColor = RGB(145,90,173);
    header.lastUpdatedTimeLabel.textColor = RGB(145,90,173);
    return header;
}

+(MJRefreshBackNormalFooter*)createTableFooterWithSel:(SEL)action andTarget:(id)target{
    MJRefreshBackNormalFooter *footer =  [MJRefreshBackNormalFooter footerWithRefreshingTarget:target refreshingAction:action];
    footer.stateLabel.textColor = RGB(145,90,173);
    [footer setTitle:@"上拉刷新" forState:MJRefreshStateIdle];
    [footer setTitle:@"刷新中，请稍后" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
    return footer;
}


+ (void)showHUD:(UIView*)view {
    if (view) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![MBProgressHUD HUDForView:view]) {
                [MBProgressHUD showHUDAddedTo:view animated:YES];
            }
        });
    }
}

+ (void)hideHUD:(UIView *)view {
    if (view) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([MBProgressHUD HUDForView:view]) {
                [MBProgressHUD hideHUDForView:view animated:YES];
            }
            [MBProgressHUD hideHUDForView:view animated:YES];
        });
    }
}

+ (void)addLineWithSuperView:(UIView*)view andRect:(CGRect)rect {
    EMView *line = [[EMView alloc] initWithFrame:rect];
    line.backgroundColor = RGB(171, 171, 171);
    if (view) {
        [view addSubview:line];
    }
}


+ (void)addLineWithSuperView:(UIView*)view andRect:(CGRect)rect andColor:(UIColor*)color{
    EMView *line = [[EMView alloc] initWithFrame:rect];
    line.backgroundColor = color;
    if (view) {
        [view addSubview:line];
    }
}


+ (BOOL)haveDeviceAuthorization {
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    BOOL isSupport = videoAuthStatus == AVAuthorizationStatusAuthorized;
    if (!isSupport) {
        // 请求权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
            
        }];
    }
    return isSupport;
}

+ (void)showDeviceWarning{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:Local(@"MicPhoneAccess")
                                   delegate:nil
                          cancelButtonTitle:Local(@"IKnowRecordIsTooShort")
                          otherButtonTitles:nil]  show];
    });
}


+(BOOL)checkTextIsNotNull:(NSString*)str{
    if (str && ![str isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

+(BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


+(EMImageView*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect andTextField:(EMTextField*)field{
    EMImageView *filedBack = [[EMImageView alloc] initWithFrame:rect];
    filedBack.alpha = 0.15;
    filedBack.userInteractionEnabled = YES;
    filedBack.backgroundColor = RGB(0xff, 0xff, 0xff);
    filedBack.layer.cornerRadius = rect.size.height/2;
    filedBack.layer.masksToBounds = YES;
    rect.origin.x = rect.origin.x + 20;
    rect.origin.y = 0;
    rect.size.width = rect.size.width-40;
    field.frame = rect;
    field.placeholder = placeHolder;
    field.font = ComFont(13);
    [field setTintColor:RGB(0xff,0xff,0xff)];
    field.textColor = RGB(0xff,0xff,0xff);
//    [field setValue:RGBA(0xff, 0xff, 0xff,0.6) forKeyPath:@"_placeholderLabel.textColor"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(field, ivar);

    placeholderLabel.textColor = RGBA(0xff, 0xff, 0xff,0.6);
    field.titStr = name;
    [filedBack addSubview:field];
    return filedBack;
}

+(EMButton*)buttonWithName:(NSString*)name andFrame:(CGRect)rect andSelector:(SEL)selector andTarget:(id)target isEnable:(BOOL)isEnable{
    EMButton *btn = [[EMButton alloc] initWithFrame:rect];
    btn.titStr = name;
    [btn setTitle:name forState:UIControlStateNormal];
    if (isEnable) {
        [btn setTitleColor:RGBA(0xff, 0xff, 0xff,0.6) forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(0xff, 0xff, 0xff, 1) forState:UIControlStateSelected];
        [btn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    }else{
        [btn setEnabled:NO];
        [btn setTitleColor:RGBA(0xff, 0xff, 0xff, 1) forState:UIControlStateNormal];
        [btn setTitleColor:RGBA(0xff, 0xff, 0xff, 1) forState:UIControlStateSelected];
    }
    return btn;

}


+(EMLabel*)createLabel:(NSString*)name andRect:(CGRect)rect andTextColor:(UIColor*)color andFont:(UIFont*)font andAlpha:(CGFloat)alpha {
    EMLabel *label = [[EMLabel alloc] initWithFrame:rect];
    label.textColor = color;
    label.font = font;
    label.text = name;
    label.alpha = alpha;
    return label;
}

+(EMTextField*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect andSuperView:(UIView*)superView{
    EMImageView *filedBack = [[EMImageView alloc] initWithFrame:rect];
    filedBack.alpha = 0.15;
    filedBack.backgroundColor = RGB(171, 171, 171);
    filedBack.layer.cornerRadius = rect.size.height/2.f;
    filedBack.layer.masksToBounds = YES;
    rect.origin.x = rect.origin.x + 20;
    rect.size.width = rect.size.width-40;
    EMTextField *field = [[EMTextField alloc] initWithFrame:rect];
    field.placeholder = placeHolder;
    field.font = ComFont(13);
    [field setTintColor:RGB(51,51,51)];
    field.textColor = RGB(51,51,51);
//    [field setValue:RGBA(51, 51, 51,0.6) forKeyPath:@"_placeholderLabel.textColor"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(field, ivar);

    placeholderLabel.textColor = RGBA(51, 51, 51,0.6);
    field.titStr = name;
    [superView addSubview:filedBack];
    [superView addSubview:field];
    return field;
}


+(EMButton*)createWhiteBtnWithFrame:(CGRect)rect andTitle:(NSString*)title andSelector:(SEL)selector andTarget:(id)target{
    EMButton *loginBtn = [[EMButton alloc] initWithFrame:rect isRdius:NO];
    loginBtn.layer.cornerRadius = 20;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn setBackgroundImage:[UIUtil imageWithColor:RGBA(222,222,222,1) andSize:loginBtn.frame.size] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIUtil imageWithColor:RGBA(222,222,222,1) andSize:loginBtn.frame.size] forState:UIControlStateNormal];
    [loginBtn setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    [loginBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//    loginBtn.alpha = 0.7;
    [loginBtn.titleLabel setFont:ComFont(15)];
    [loginBtn setTitle:title forState:UIControlStateNormal];
    return loginBtn;
}

+(EMButton*)createLoginBtnWithFrame:(CGRect)rect andTitle:(NSString*)title andSelector:(SEL)selector andTarget:(id)target{
    EMButton *loginBtn = [[EMButton alloc] initWithFrame:rect isRdius:NO];
    loginBtn.layer.cornerRadius = 20;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn.layer setBorderWidth:1];
    [loginBtn.layer setBorderColor:RGB(0xff, 0xff, 0xff).CGColor];
    [loginBtn setTitleColor:RGB(0xff, 0xff, 0xff) forState:UIControlStateNormal];
    [loginBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    loginBtn.alpha = 0.7;
    [loginBtn.titleLabel setFont:ComFont(15)];
    [loginBtn setTitle:title forState:UIControlStateNormal];
    return loginBtn;
}


+(EMButton*)createPurpleBtnWithFrame:(CGRect)rect andTitle:(NSString*)title andSelector:(SEL)selector andTarget:(id)target{
    EMButton *loginBtn = [[EMButton alloc] initWithFrame:rect isRdius:NO];
    loginBtn.layer.cornerRadius = 20;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn setBackgroundImage:[UIUtil imageWithColor:RGB(145,90,173) andSize:loginBtn.frame.size] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIUtil imageWithColor:RGB(145,90,173) andSize:loginBtn.frame.size] forState:UIControlStateNormal];
    [loginBtn setTitleColor:RGBA(0xff, 0xff, 0xff,0.9) forState:UIControlStateNormal];
    [loginBtn addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
//    loginBtn.alpha = 0.7;
    [loginBtn.titleLabel setFont:ComFont(15)];
    [loginBtn setTitle:title forState:UIControlStateNormal];
    return loginBtn;
}


+(UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//快闪通知
+ (void)showInfo:(NSString*)info {
    UILabel *label = [[UILabel alloc] initWithFrame:Rect(0, 0, kScreenW, 80)];
    label.text = info;
    label.textColor = RGB(255,255,255);
    label.backgroundColor = RGBA(0,0,0,0.8);
    label.textAlignment = NSTextAlignmentCenter;
    UISwipeGestureRecognizer *swipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:[self class] action:@selector(swipUp:)];
    swipGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [label addGestureRecognizer:swipGesture];
    [[[self class] lastControllerView] addSubview:label];
    label.alpha = 1;
    [UIView animateKeyframesWithDuration:1 delay:5 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        label.alpha = 0;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
    
}


+ (void)swipUp:(UISwipeGestureRecognizer*)swip {
    UIView *aView = swip.view;
    [UIView animateKeyframesWithDuration:1 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        aView.frame = Rect(0, -80, kScreenW, 80);
    } completion:^(BOOL finished) {
    }];
}

+ (UIView *)lastControllerView
{
    
    UIViewController *topController = [[(AppDelegate*)ApplicationDelegate window] rootViewController];
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController.view;
}


+(UIImage*)circleImage:(UIColor*)color andSize:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    //新建一个图片图形上下文
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    //获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    
    
    //绘制圆形路径
    CGContextAddEllipseInRect(ctx, rect);
    
    //剪裁上下文
    CGContextClip(ctx);
    
    
    CGContextSetFillColorWithColor(ctx, [color CGColor]);
    CGContextFillRect(ctx, rect);
    //绘制图片
    
    //取出图片
    UIImage *roundImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //结束上下文
    UIGraphicsEndImageContext();
    
    return roundImage;
}

+(UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    
    UIGraphicsBeginImageContext(image.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    //圆的边框宽度为2，颜色为红色
    
    CGContextSetLineWidth(context,2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset *2.0f, image.size.height - inset *2.0f);
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextClip(context);
    
    //在圆区域内画出image原图
    
    [image drawInRect:rect];
    
    CGContextAddEllipseInRect(context, rect);
    
    CGContextStrokePath(context);
    
    //生成新的image
    
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newimg;
    
}

+ (BOOL)checkLogin {
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        return YES;
    }else {
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"THISWANTREGISTER") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                //注册
                UINavigationController *topController = (UINavigationController*)[[(AppDelegate*)ApplicationDelegate window] rootViewController];

                for (int i = 0; i < topController.viewControllers.count; i++) {
                    if ([NSStringFromClass([topController.viewControllers[i] class]) isEqualToString:@"LoginViewController"]) {
                        LoginViewController *loginVC = topController.viewControllers[i];
                        [loginVC setDefaultInfo];
                        loginVC.isHiddenAnimation = YES;
                        
                        LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
                        loginStatus.isLogined = NO;
                        [[FileAccessData sharedInstance] setAObject:loginStatus forEMKey:@"LoginStatus"];
                        [topController popToViewController:loginVC animated:NO];
                        RegisterViewController *registerVC = [[RegisterViewController alloc] init];
                        [loginVC.navigationController pushViewController:registerVC animated:YES];
                        break;
                    }
                }
            }
        } cancelButtonTitle:Local(@"NextTime") otherButtonTitles:Local(@"GOTOREGISTER"), nil];
        [alert show];
        alert = nil;
        return NO;
    }
}

+ (BOOL)alertVoiceRecordWarning:(UIViewController*)controller andMsg:(NSString*)msg {
    LonelyUser *user = [ViewModelCommom  getCuttentUser];
    BOOL ret = NO;
    if (user.voice == nil || [user.voice isEqualToString:@""]) {
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:msg clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                RecordIntroduceVC *voices = [[RecordIntroduceVC alloc] init];
                voices.seq = 1;
                [controller.navigationController pushViewController:voices animated:YES];
            }
        } cancelButtonTitle:Local(@"NextTime") otherButtonTitles:Local(@"GoToRecord"), nil];
        [alert show];
        alert = nil;
        ret = YES;
    }
    return ret;
}

+ (BOOL)alertProfileWarning:(UIViewController*)controller andMsg:(NSString*)msg {
    LonelyUser *user = [ViewModelCommom  getCuttentUser];
    BOOL ret = NO;
    if (user.birth_day == nil || [user.birth_day isEqualToString:@""]) {
        AllPopView *alert = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:msg clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                MyInfoVC *myInfo = [[MyInfoVC alloc] init];
                [controller.navigationController pushViewController:myInfo animated:YES];
            }
        } cancelButtonTitle:Local(@"NextTime") otherButtonTitles:Local(@"GoTo"), nil];
        [alert show];
        alert = nil;
        ret = YES;
    }
    return ret;
}


+(NSMutableAttributedString*)getAttrStr:(NSString*)allStr andAllColor:(UIColor*)color andDstStr:(NSString*)dstStr andDstColor:(UIColor*)dstColor {
    NSMutableAttributedString *retStr = [[NSMutableAttributedString alloc]initWithString:allStr];
    [retStr
     addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,allStr.length)];
    NSRange range = [allStr rangeOfString:dstStr];
    if (range.location != NSNotFound ) {
        [retStr
         addAttribute:NSForegroundColorAttributeName value:dstColor range:range];
    }
    return retStr;
}

@end
