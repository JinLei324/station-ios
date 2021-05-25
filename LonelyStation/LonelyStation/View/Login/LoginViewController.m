//
//  LoginViewController.m
//  LonelyStation
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "LoginViewController.h"
#import "MainTabBarController.h"
#import "LeftSortsViewController.h"
#import "LeftSlideViewController.h"
#import "NetAccess.h"
#import "LonelyUser.h"
#import "UIUtil.h"
#import "EMImageView.h"
#import "LoginStatusObj.h"
#import "UIView+Toast.h"
#import "ForgetPwdViewController.h"
#import "StandViewController.h"
#import "PersonInfoViewController.h"
#import "ViewModelCommom.h"
#import "UploadImgViewController.h"
#import "RegisterViewController.h"
#import "TelValidateVC.h"


@interface LoginViewController()<UIScrollViewDelegate,CAAnimationDelegate>{
    LoginViewModel *_loginViewModel;
    EMButton *_currentSelectBtn;
    EMView *_topView;
    EMView *_slideView;
    UIScrollView *_bottomScrollView;
    EMButton *_loginBtn;
    EMButton *_registerBtn;
    NSMutableArray *_textFieldArray;
    EMTextField *_userTextField;
    EMTextField *_pwdTextField;
    
    EMTextField *_registerUserTextField;
    EMTextField *_registerPwdTextField;
    EMTextField *_ensuerPwdTextField;
    EMButton *selectedBtn;
    EMButton *sexSelectedBtn;

}

@property (nonatomic) UIView *maskView;
@property (nonatomic) UIView *nilNameView;

@property (nonatomic) CGPoint scrollViewStartPosPoint;
@property (nonatomic) int     scrollDirection;

@end

@implementation LoginViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    [self initViews];
//    if (!_isHiddenAnimation) {
//        [self showFirstAnimation];
//    }else{
//        for (int i = 30000; i<30003; i++) {
//            UIView *view = [self.view viewWithTag:i];
//            [view removeFromSuperview];
//        }
//    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        NSLog(@"finished");
        for (int i = 30000; i<30003; i++) {
            UIView *view = [self.view viewWithTag:i];
            [view removeFromSuperview];
        }
    }
}


- (void)showFirstAnimation {
    UIImageView *backView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstPage1"]];
    backView1.frame = self.view.bounds;
    backView1.tag = 30000;
    [self.view addSubview:backView1];
    UIImageView *backView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstPage2"]];
    backView2.tag = 30001;
    backView2.frame = self.view.bounds;
    
    UIImageView *backView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstPage3"]];
    backView3.tag = 30002;
    backView3.frame = self.view.bounds;
    
    [self.view addSubview:backView2];
    backView2.alpha = 1;
    
    [self.view addSubview:backView3];
    backView3.alpha = 0;
    
    
    CGFloat kAnimationDuration = 1.f;
    CAGradientLayer *contentLayer = (CAGradientLayer *)backView2.layer;
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.f)];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.f, 1.f, 1.f)];
    scaleAnimation.duration = kAnimationDuration;
    scaleAnimation.cumulative = NO;
    scaleAnimation.repeatCount = 4;
    scaleAnimation.delegate = self;
    [scaleAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    [contentLayer addAnimation: scaleAnimation forKey:@"myScale"];
    
    
    CGPoint position = contentLayer.position;
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x + 5, position.y);
    CGPoint y = CGPointMake(position.x - 5, position.y);
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:0.3];
    // 设置次数
    [animation setRepeatCount:3];
    [contentLayer addAnimation: animation forKey:@"myMove"];

    
    CABasicAnimation *showViewAnn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    showViewAnn.fromValue = [NSNumber numberWithFloat:0.0];
    showViewAnn.toValue = [NSNumber numberWithFloat:1.f];
    showViewAnn.duration = kAnimationDuration;
    showViewAnn.fillMode = kCAFillModeForwards;
    showViewAnn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    showViewAnn.removedOnCompletion = NO;
    [backView3.layer addAnimation:showViewAnn forKey:@"myShow"];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = kAnimationDuration;
    group.removedOnCompletion = NO;
    group.repeatCount = 1;
    group.fillMode = kCAFillModeForwards;
    [group setAnimations:@[scaleAnimation,animation,showViewAnn]];
    
    
    
    
//    [UIView animateWithDuration:1.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        backView2.alpha = 1;
//        backView3.alpha = 1;
//    } completion:^(BOOL finished) {
//        if(finished){
//            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                backView1.alpha = 0;
//                backView2.alpha = 0;
//                backView3.alpha = 0;
//            } completion:^(BOOL finished) {
//                if (finished) {
//                    [backView1 removeFromSuperview];
//                    [backView2 removeFromSuperview];
//                    [backView3 removeFromSuperview];
//                }
//            }];
//        }
//    }];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //做一个启动动画，启动完再initViews
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    _userTextField.text = user.userName;
    _pwdTextField.text = user.password;
}


-(void)initViews{
    _textFieldArray = [NSMutableArray array];
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginBack"]];
//    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
//    [self.view addSubview:backgroundImageView];
    
    [self initTopView];
    [self initBottomView];
    _loginViewModel = [[LoginViewModel alloc] init];
    
    //test
//    _userTextField.text = @"719865682@qq.com";
//    _pwdTextField.text = @"63920253";
}

-(void)initTopView{
    CGFloat x = 33;
    CGFloat y = 66;
//    if (kScreenH == 568 || (kScreenH == 480)) {
//        y = 66;
//    }
    CGFloat width = kScreenW-x*2;
    CGFloat height = 47;
    _topView = [[EMView alloc] initWithFrame:Rect(x, y, width, height)];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    
    _loginBtn = [self buttonWithName:Local(@"LoginBtn") andFrame:Rect(27, 0, 75, 44)];
    _loginBtn.selected = YES;
    _currentSelectBtn = _loginBtn;
    [_topView addSubview:_loginBtn];
    
    _registerBtn = [self buttonWithName:Local(@"REGISTERWithOutName") andFrame:Rect(PositionX(_loginBtn)+20, 0, 75, 44)];
    [_topView addSubview:_registerBtn];

    _slideView = [[EMView alloc] initWithFrame:Rect(_loginBtn.frame.origin.x, 44, 70, 3)];
    _slideView.backgroundColor = RGB(145, 90, 173);
    _slideView.center = Point(_currentSelectBtn.center.x, _slideView.center.y);
    [_topView addSubview:_slideView];
}


-(void)initBottomView{
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:Rect(0, _topView.frame.origin.y+_topView.frame.size.height, kScreenW, kScreenH-(_topView.frame.origin.y+_topView.frame.size.height))];
    _bottomScrollView.backgroundColor = [UIColor clearColor];
    _bottomScrollView.contentSize = Size(kScreenW*2, 0);
    _bottomScrollView.pagingEnabled = YES;
    _bottomScrollView.delegate = self;
    _bottomScrollView.directionalLockEnabled = YES;
    [self.view addSubview:_bottomScrollView];
    [self initBottomLeftView];
    [self initBottomRightView];
}

- (void)initBottomRightView{
    CGFloat x = 33;
    CGFloat y = 70;
    CGFloat width = kScreenW-x*2;
    x = kScreenW + 33;
    CGFloat height = 40;
    CGFloat ySpace = 28;
    CGFloat ySpaceRegist = 50;
    //    CGFloat corner = 20;
    if(kScreenH == 568){
        ySpaceRegist = 20;
    }else if (kScreenH == 480) {
        y = 28;
        ySpaceRegist = 28;
    }
    _registerUserTextField = [self textFieldWithPlaceHolder:Local(@"PleaseInputEmail") andName:@"inputEmail" andFrame:Rect(x, y, width, height)];
    
    y += ySpace+height;
    _registerPwdTextField = [self textFieldWithPlaceHolder:Local(@"SetingPWD") andName:@"setingpwd" andFrame:Rect(x, y, width, height)];
    _registerPwdTextField.secureTextEntry = YES;
    
    
    y += ySpace+height;
    _ensuerPwdTextField = [self textFieldWithPlaceHolder:Local(@"EnSurePWD") andName:@"ensurepwd" andFrame:Rect(x, y, width, height)];
    _ensuerPwdTextField.secureTextEntry = YES;
    
    y += ySpace+height;
    
    EMLabel *sexLabel = [self labelWithText:Local(@"Sex") andFont:ComFont(13) andColor:RGB(49,49,49) andFrame:Rect(x, y+7, 30, 13) andAlpha:0.6];
    [_bottomScrollView addSubview:sexLabel];
    x += 30+8;
    
    NSArray *sexArray = @[Local(@"Boy"),Local(@"Girl")];
    for (int j = 0; j<sexArray.count; j++) {
        EMButton *boyButton = [[EMButton alloc] initWithFrame:Rect(x, y, 27, 27)];
        [boyButton setImage:[UIImage imageNamed:@"singlenoButton"] forState:UIControlStateNormal];
        [boyButton setImage:[UIImage imageNamed:@"singleyesButton"] forState:UIControlStateSelected];
        boyButton.titStr = [sexArray[j] isEqualToString:Local(@"Boy")]?@"M":@"F";
        [boyButton addTarget:self action:@selector(registerSexAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomScrollView addSubview:boyButton];
        EMLabel *boyLabel = [self labelWithText:sexArray[j] andFont:ComFont(13) andColor:RGB(49,49,49) andFrame:Rect(PositionX(boyButton)+8, y + 7, 30, 13) andAlpha:0.6];
        [_bottomScrollView addSubview:boyLabel];
        x += 27 + 8 + 30 + 8;
    }
    
    ySpace = 10;
    y += ySpace+height;
    
    x = kScreenW + 33;
    EMLabel *sexDesLabel = [self labelWithText:Local(@"SexCannotChange") andFont:ComFont(12) andColor:RGB(49,49,49) andFrame:Rect(x, y, kScreenW - 2*33, 13) andAlpha:1];
    sexDesLabel.textColor = RGB(145,90,173);
    sexDesLabel.textAlignment = NSTextAlignmentCenter;
    [_bottomScrollView addSubview:sexDesLabel];
    
    y += height ;
    x = kScreenW + 33;
    
    EMButton *nextStepBtn = [UIUtil createPurpleBtnWithFrame:Rect(x, y, width, height) andTitle:Local(@"NextStep") andSelector:@selector(registAction:)  andTarget:self];
    [_bottomScrollView addSubview:nextStepBtn];
    
    
    
    y = 15;
    if (kScreenH == 480 || kScreenH == 568) {
        y -= 17;
    }
    EMView *line = [[EMView alloc] initWithFrame:Rect(x,  _bottomScrollView.frame.size.height-2*y-height-1, width, 1)];
    line.alpha = 0.7;
    line.backgroundColor = RGB(210,210,210);
    [_bottomScrollView addSubview:line];
    
    EMButton *forgetBtn = [UIUtil buttonWithName:@"" andFrame:Rect(x, _bottomScrollView.frame.size.height-y-height, width, height) andSelector:@selector(standedAction:) andTarget:self isEnable:YES];
    forgetBtn.alpha = 0.7;
    [forgetBtn.titleLabel setFont:ComFont(13)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:Local(@"EnSureNextStep")];
    [str
     addAttribute:NSForegroundColorAttributeName value:RGBA(106,76,156,0.8) range:NSMakeRange(Local(@"EnSureNextStep").length-Local(@"Standed").length,Local(@"Standed").length)];
    [str
     addAttribute:NSForegroundColorAttributeName value:RGBA(49,49,49,0.8) range:NSMakeRange(0,Local(@"EnSureNextStep").length-Local(@"Standed").length)];
    [forgetBtn setAttributedTitle:str forState:UIControlStateNormal];
    [_bottomScrollView addSubview:forgetBtn];
}


-(void)standedAction:(EMButton*)button{
    StandViewController *stand = [[StandViewController alloc] init];
    [self.navigationController pushViewController:stand animated:YES];
    stand = nil;
}



-(void)registAction:(EMButton*)button{
    //下一步按钮
    [self.view endEditing:YES];
    
    if(![UIUtil checkTextIsNotNull:_registerUserTextField.text]){
        [self.view makeToast:Local(@"PlsInputUser") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if(![UIUtil isValidateEmail:_registerUserTextField.text]){
        [self.view makeToast:Local(@"PlsInputRightEmail") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if(![UIUtil checkTextIsNotNull:_registerPwdTextField.text]){
        [self.view makeToast:Local(@"PlsInputPwd") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if(![_registerPwdTextField.text isEqualToString:_ensuerPwdTextField.text]){
        [self.view makeToast:Local(@"PlsInputSamePwd") duration:ERRORTime position:[CSToastManager defaultPosition]];
        _ensuerPwdTextField.text = @"";
        return;
    }
    if(!sexSelectedBtn) {
        [self.view makeToast: [NSString stringWithFormat:@"%@%@",Local(@"ChoosePhoto"),Local(@"Sex")] duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    
    [self startAnimation:button];
    WS(weakSelf);
    [_loginViewModel registerNext:_registerUserTextField.text andPwd:_registerPwdTextField.text andGender:sexSelectedBtn.titStr andBlock:^(NSDictionary *dict, BOOL ret) {
        SS(weakSelf, strongSelf);
        [strongSelf endAnimation:button];
        [button setTitle:Local(@"NextStep") forState:UIControlStateNormal];
        if (ret) {
            if (dict[@"data"][@"GiftQualified"]) {
                //判断GiftQualified
                NSString *giftQualified =  dict[@"data"][@"GiftQualified"][@"text"];
                if ([@"N" isEqualToString:giftQualified]) {
                    //直接走登录
                    [self LoginWithUser:_registerUserTextField.text andPwd:_registerPwdTextField.text andBtn:_loginBtn];
                }else {
                    //去那个填手机号的页面
                    TelValidateVC *telValidateVC = [[TelValidateVC alloc] init];
                    [self.navigationController pushViewController:telValidateVC animated:YES];
                }
            }else {
                //直接走登录
                [self LoginWithUser:_registerUserTextField.text andPwd:_registerPwdTextField.text andBtn:_loginBtn];
            }
        }
    }];
}


- (void)registerSexAction:(EMButton*)btn {
    if (sexSelectedBtn != btn) {
        if (!sexSelectedBtn) {
            sexSelectedBtn = btn;
        }else{
            sexSelectedBtn.selected = NO;
        }
        btn.selected = !btn.selected;
        sexSelectedBtn = btn;
    }
}

- (EMLabel*)labelWithText:(NSString*)text andFont:(UIFont*)font andColor:(UIColor*)color andFrame:(CGRect)rect andAlpha:(CGFloat)alpha{
    EMLabel *nickLabel = [[EMLabel alloc] initWithFrame:rect];
    nickLabel.font = font;
    nickLabel.text = text;
    nickLabel.textColor = color;
    nickLabel.alpha = alpha;
    return nickLabel;
}

-(void)initBottomLeftView{
    CGFloat x = 33;
    CGFloat y = 70;
    CGFloat width = kScreenW-x*2;
    CGFloat height = 40;
    CGFloat ySpace = 28;
    CGFloat ySpaceLogin = 95;
    if(kScreenH == 568){
        ySpaceLogin = 65;
    }else if (kScreenH == 480) {
        y = 28;
        ySpaceLogin = 50;
    }
     
    _userTextField = [self textFieldWithPlaceHolder:Local(@"UserName") andName:@"userName" andFrame:Rect(x, y, width, height)];
    _userTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    y += ySpace+height;
    _pwdTextField = [self textFieldWithPlaceHolder:Local(@"Password") andName:@"password" andFrame:Rect(x, y, width, height)];
    _pwdTextField.secureTextEntry = YES;
    y += ySpace+height;
    
    EMButton *loginBtn = [UIUtil createPurpleBtnWithFrame:Rect(x, y, width, height) andTitle:Local(@"LoginBtn") andSelector:@selector(LoginAction:) andTarget:self];
    [_bottomScrollView addSubview:loginBtn];
    
    y += ySpace+height;
    x = 50;
//    width = kScreenW / 2.f - 70;
//    EMButton *registerBtn = [UIUtil buttonWithName:Local(@"SignAccount") andFrame:Rect(x, y, width, height) andSelector:@selector(RegisterAction:) andTarget:self isEnable:YES];
//    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//    registerBtn.titleLabel.font = ComFont(16);
//    [registerBtn setTitleColor:RGB(49,49,49) forState:UIControlStateNormal];
//    [_bottomScrollView addSubview:registerBtn];
//
//
//    x += width + 20;
//    EMView *middleLine = [[EMView alloc] initWithFrame:Rect(x, y + (height-11)/2, 1, 11)];
//    middleLine.alpha = 0.7;
//    middleLine.backgroundColor = RGB(171, 171, 171);
//    [_bottomScrollView addSubview:middleLine];
//
//    x += 21;
//    EMButton *forgetBtn = [UIUtil buttonWithName:Local(@"ForgetPwd") andFrame:Rect(x,y,width,height) andSelector:@selector(forgetAction:) andTarget:self isEnable:YES];
//    [forgetBtn setTitleColor:RGB(49,49,49) forState:UIControlStateNormal];
//    forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    forgetBtn.titleLabel.font = ComFont(16);
//    [_bottomScrollView addSubview:forgetBtn];
    
    y = 31;
    x = 33;
    width = kScreenW / 2.f - x - 20;
    
    if (IsIPhone4) {
        height = 10;
    }
    
    EMView *lineLeft = [[EMView alloc] initWithFrame:Rect(x, _bottomScrollView.frame.size.height-2*y-height-1, width, 1)];
    lineLeft.alpha = 0.7;
    lineLeft.backgroundColor = RGB(171,171,171);
    [_bottomScrollView addSubview:lineLeft];
    
    x += width;
    UILabel *orLabel = [[UILabel alloc] initWithFrame:Rect(x, _bottomScrollView.frame.size.height-2*y-height-10, 40, 20)];
    orLabel.textAlignment = NSTextAlignmentCenter;
    orLabel.textColor = RGB(171,171,171);
    orLabel.text = @"or";
    orLabel.font = ComFont(16);
    [_bottomScrollView addSubview:orLabel];
    
    x += 40;
    EMView *lineRight = [[EMView alloc] initWithFrame:Rect(x, _bottomScrollView.frame.size.height-2*y-height-1, width, 1)];
    lineRight.alpha = 0.7;
    lineRight.backgroundColor =  RGB(171,171,171);
    [_bottomScrollView addSubview:lineRight];
    
//    width = kScreenW/2;
//    EMButton *nilLoginBtn = [UIUtil buttonWithName:Local(@"LoginWithOutName") andFrame:Rect((kScreenW-width)/2,_bottomScrollView.height-y-height, width, height) andSelector:@selector(nilNameAction:) andTarget:self isEnable:YES];
//    nilLoginBtn.selected = YES;
//    [nilLoginBtn setTitleColor:RGB(49, 49, 49) forState:UIControlStateSelected];
//    [_bottomScrollView addSubview:nilLoginBtn];
    width = kScreenW / 2.f - 70;
    x = 50;
    y =  _bottomScrollView.height-y-height;
    EMButton *registerBtn = [UIUtil buttonWithName:Local(@"LoginWithOutName") andFrame:Rect(x, y, width, height) andSelector:@selector(nilNameAction:) andTarget:self isEnable:YES];
    registerBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    registerBtn.titleLabel.font = ComFont(16);
    [registerBtn setTitleColor:RGB(49,49,49) forState:UIControlStateNormal];
    [_bottomScrollView addSubview:registerBtn];
    
    
    x += width + 20;
    EMView *middleLine = [[EMView alloc] initWithFrame:Rect(x, y + (height-11)/2, 1, 11)];
    middleLine.alpha = 0.7;
    middleLine.backgroundColor = RGB(171, 171, 171);
    [_bottomScrollView addSubview:middleLine];
    
    x += 21;
    EMButton *forgetBtn = [UIUtil buttonWithName:Local(@"ForgetPwd") andFrame:Rect(x,y,width,height) andSelector:@selector(forgetAction:) andTarget:self isEnable:YES];
    [forgetBtn setTitleColor:RGB(49,49,49) forState:UIControlStateNormal];
    forgetBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    forgetBtn.titleLabel.font = ComFont(16);
    [_bottomScrollView addSubview:forgetBtn];

}

- (void)scrollRight {
    [self loginAndRegisterClick:_registerBtn];
}


- (void)nilNameAction:(EMButton*)btn {
    [self addMaskView];
    [self addNilNameView];
    [UIView animateWithDuration:0.5 animations:^{
        CGFloat h = ScreenHeight*0.5;
        if (IsIPhone4) {
            h = ScreenHeight * 0.65;
        }
        _nilNameView.frame = Rect(0, ScreenHeight - h, ScreenWidth, h);
    }];}


- (void)RegisterAction:(EMButton*)btn {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}




-(void)LoginAction:(EMButton*)sender{
    if(![UIUtil checkTextIsNotNull:_userTextField.text]){
        [self.view makeToast:Local(@"PlsInputUser") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if(![UIUtil isValidateEmail:_userTextField.text]){
        [self.view makeToast:Local(@"PlsInputRightEmail") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    
    if(![UIUtil checkTextIsNotNull:_pwdTextField.text]){
        [self.view makeToast:Local(@"PlsInputPwd") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [self.view endEditing:YES];
    [self startAnimation:sender];
    [self LoginWithUser:_userTextField.text andPwd:_pwdTextField.text andBtn:((EMButton*)sender)];
}


-(void)startAnimation:(UIButton*)sender{
    UIActivityIndicatorView *activity_indicator_view = [[UIActivityIndicatorView alloc] initWithFrame:((EMButton*)sender).bounds];
    [activity_indicator_view setUserInteractionEnabled:YES];//点击不传递事件到button
    [activity_indicator_view setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activity_indicator_view.tag = 4001;
    [((EMButton*)sender) addSubview:activity_indicator_view];
    [activity_indicator_view startAnimating];
    activity_indicator_view = nil;
    [((EMButton*)sender) setTitle:@"" forState:UIControlStateNormal];
}

- (void)setDefaultInfo {
    LonelyUser *user =  [ViewModelCommom getCuttentUser];
    _userTextField.text = user.userName;
    _pwdTextField.text = user.password;
    [_bottomScrollView setContentOffset:CGPointZero];

}

-(void)endAnimation:(EMButton*)btn{
    UIActivityIndicatorView *active = [btn viewWithTag:4001];
    [active stopAnimating];
    [active removeFromSuperview];
    active.userInteractionEnabled = NO;
}

-(void)LoginWithUser:(NSString*)userName andPwd:(NSString*)pwd andBtn:(EMButton*)btn{
    [_loginViewModel login:userName andPwd:pwd andFlag:@"1" andBlock:^(NSDictionary *dict,BOOL ret){
        [self endAnimation:btn];
        [btn setTitle:Local(@"LoginBtn") forState:UIControlStateNormal];
        if (dict) {
            if (ret && [[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                //判断城市和国家还有性别有没有，如果都没有，去填个人信息
                if (dict[@"info"][@"city"][@"text"] == nil && dict[@"info"][@"country"][@"text"] == nil && dict[@"info"][@"gender"][@"text"] == nil) {

                    PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] init];
                    [self.navigationController pushViewController:personInfo animated:YES];
                    [personInfo.view makeToast:Local(@"PlsInputPersonalInfo") duration:ERRORTime position:[CSToastManager defaultPosition]];

                }else {
                    LoginStatusObj *loginedStatus = [[LoginStatusObj alloc] init];
                    loginedStatus.isLogined = YES;
                    loginedStatus.shouldGetUserMsg = NO;
                    [[FileAccessData sharedInstance] setAObject:loginedStatus forEMKey:@"LoginStatus"];
                    loginedStatus = nil;
                    
                    MainTabBarController *mainTab = [[MainTabBarController alloc] init];
                    mainTab.isHiddenNavigationBar = YES;
                    
                    LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
                    LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:mainTab];
                    mainTab.slideViewCtl = leftSlideVC;
                    [self.navigationController pushViewController:leftSlideVC animated:YES];
                    mainTab = nil;
                }
            }else{
                [self.view makeToast:[[dict objectForKey:ERRORKEY] objectForKey:@"text"] duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else{
            [self.view makeToast:Local(@"LoginFailed") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
        DLog(@"dict===%@,-====%d",dict,ret);
    }];
}


-(void)forgetAction:(EMButton*)button{
    ForgetPwdViewController *forgetPwdView = [[ForgetPwdViewController alloc] init];
//    forgetPwdView.isHiddenNavigationBar = YES;
    [self.navigationController pushViewController:forgetPwdView animated:YES];
    forgetPwdView = nil;
}







-(EMTextField*)textFieldWithPlaceHolder:(NSString*)placeHolder andName:(NSString*)name andFrame:(CGRect)rect{
    EMImageView *filedBack = [[EMImageView alloc] initWithFrame:rect];
    filedBack.backgroundColor = RGBA(228,228,228,0.15);
    filedBack.layer.cornerRadius = 20;
    filedBack.layer.masksToBounds = YES;
    filedBack.layer.borderColor = RGBA(145,90,173,0.15).CGColor;
    filedBack.layer.borderWidth = 1;
    rect.origin.x = rect.origin.x + 20;
    rect.size.width = rect.size.width-40;
    EMTextField *field = [[EMTextField alloc] initWithFrame:rect];
    field.placeholder = placeHolder;
    field.font = ComFont(13);
    [field setTintColor:RGB(49,49,49)];
    field.textColor = RGB(49,49,49);
    
//    [field setValue:RGB(49,49,49) forKeyPath:@"_placeholderLabel.textColor"];
    Ivar ivar =  class_getInstanceVariable([UITextField class], "_placeholderLabel");
    UILabel *placeholderLabel = object_getIvar(field, ivar);

    placeholderLabel.textColor = RGB(49, 49, 49);
    field.titStr = name;
    [_bottomScrollView addSubview:filedBack];
    [_bottomScrollView addSubview:field];
    return field;
}



-(EMButton*)buttonWithName:(NSString*)name andFrame:(CGRect)rect{
    EMButton *btn = [[EMButton alloc] initWithFrame:rect];
    btn.titStr = name;
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:RGB(0x99, 0x99, 0x99) forState:UIControlStateNormal];
    [btn setTitleColor:RGB(0x51, 0x51, 0x51) forState:UIControlStateSelected];
    
    [btn addTarget:self action:@selector(loginAndRegisterClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

-(void)loginAndRegisterClick:(EMButton*)btn{
    if (_currentSelectBtn == btn) {
        return;
    }
    _currentSelectBtn.selected = NO;
    btn.selected = YES;
    _currentSelectBtn = btn;
    CGFloat x = [btn.titStr isEqualToString:Local(@"LoginBtn")]?0:kScreenW;
    [UIView animateWithDuration:0.3 animations:^{
        _slideView.center = Point(_currentSelectBtn.center.x, _slideView.center.y);
        [_bottomScrollView setContentOffset:Point(x, 0) animated: NO];
    }];
}


-(void) modifyTopScrollViewPositiong: (UIScrollView *) scrollView{
    if (scrollView.contentOffsetX == kScreenW) {
        _registerBtn.selected = YES;
        _loginBtn.selected = NO;
        _currentSelectBtn = _registerBtn;
    }else{
        _registerBtn.selected = NO;
        _loginBtn.selected = YES;
        _currentSelectBtn = _loginBtn;
    }
}

///拖拽后调用的方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self modifyTopScrollViewPositiong:scrollView];
    if (decelerate) {
        self.scrollDirection =0;
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self modifyTopScrollViewPositiong:scrollView];
    self.scrollDirection =0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([_bottomScrollView isEqual:scrollView]) {
        CGRect frame = _slideView.frame;
        frame.origin.x =  (scrollView.contentOffset.x/kScreenW)*(_registerBtn.frame.origin.x - _loginBtn.frame.origin.x) +  _loginBtn.frame.origin.x;
        _slideView.frame = frame;
    }
    
    if (self.scrollDirection == 0){//we need to determine direction
        //use the difference between positions to determine the direction.
        if (ABS(self.scrollViewStartPosPoint.x-scrollView.contentOffset.x)<
            ABS(self.scrollViewStartPosPoint.y-scrollView.contentOffset.y)){
            //Vertical Scrolling
            self.scrollDirection = 1;
        } else {
            //Horitonzal Scrolling
            self.scrollDirection = 2;
        }
    }
    //Update scroll position of the scrollview according to detected direction.
    if (self.scrollDirection == 1) {
        scrollView.contentOffset = CGPointMake(self.scrollViewStartPosPoint.x,scrollView.contentOffset.y);
    } else if (self.scrollDirection == 2){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x,self.scrollViewStartPosPoint.y);
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.scrollViewStartPosPoint = scrollView.contentOffset;
    self.scrollDirection = 0;
}



#pragma maskView

- (void)addMaskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _maskView.userInteractionEnabled = YES;
        _maskView.backgroundColor = RGB(0, 0, 0);
        _maskView.alpha = 0.5;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeMaskView)];
        [_maskView addGestureRecognizer:gesture];
    }
    [self.view.window addSubview:_maskView];
    
}

- (void)removeMaskView{
    [_nilNameView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_nilNameView removeFromSuperview];
    _nilNameView = nil;
    [_maskView removeFromSuperview];
    _maskView = nil;
}

- (void)addNilNameView {
    if (!_nilNameView) {
        CGFloat h = ScreenHeight*0.5;
        if (IsIPhone4) {
            h = ScreenHeight*0.65;
        }
        _nilNameView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, h)];
        _nilNameView.backgroundColor = RGB(40,40,40);
        
        EMButton *closeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 14-13, 13, 14, 14)];
        [closeBtn setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(removeMaskView) forControlEvents:UIControlEventTouchUpInside];
        [_nilNameView addSubview:closeBtn];
        
        CGFloat x = 50;
        CGFloat y = 33;
        CGFloat height = 20;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, ScreenWidth-2*x, height)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = Local(@"LoginWithOutName");
        titleLabel.font = BoldFont(18);
        titleLabel.textColor = RGB(255, 255, 255);
        [_nilNameView addSubview:titleLabel];
        
        y += 25 + height;
        height = 17;
        UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, ScreenWidth-2*x, height)];
        desLabel.textAlignment = NSTextAlignmentCenter;
        desLabel.text = [NSString stringWithFormat:@"%@%@",Local(@"ChoosePhoto"),Local(@"Sex")];
        desLabel.font = ComFont(15);
        desLabel.textColor = RGB(255, 255, 255);
        [_nilNameView addSubview:desLabel];
        
        //添加按钮
        x = 57;
        y = 117;
        CGFloat width = 75;
        EMButton *boyBtn = [[EMButton alloc] initWithFrame:CGRectMake(x, y, width, width)];
        [boyBtn setBackgroundImage:[UIImage imageNamed:@"gender_M"] forState:UIControlStateNormal];
//        [boyBtn setImage:[UIImage imageNamed:@"gender_M_d"] forState:UIControlStateSelected];
        boyBtn.tag = 100;
        [boyBtn addTarget:self action:@selector(sexAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nilNameView addSubview:boyBtn];
        
        y += width + 17;
        UILabel *boyLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,  y, width, 16)];
        boyLabel.textAlignment = NSTextAlignmentCenter;
        boyLabel.text = Local(@"IMBOY");
        boyLabel.font = ComFont(15);
        boyLabel.textColor = RGB(255, 255, 255);
        [_nilNameView addSubview:boyLabel];
        
        x = kScreenW - width - x;
        y = 117;
        EMButton *girlBtn = [[EMButton alloc] initWithFrame:CGRectMake(x, y, width, width)];
        [girlBtn setBackgroundImage:[UIImage imageNamed:@"gender_F"] forState:UIControlStateNormal];
//        [girlBtn setImage:[UIImage imageNamed:@"gender_F_d"] forState:UIControlStateSelected];
        girlBtn.tag = 101;
        [girlBtn addTarget:self action:@selector(sexAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nilNameView addSubview:girlBtn];
        
        y += width + 17;
        UILabel *girlLabel = [[UILabel alloc] initWithFrame:CGRectMake(x,  y, width, 16)];
        girlLabel.textAlignment = NSTextAlignmentCenter;
        girlLabel.text = Local(@"IMGIRL");
        girlLabel.font = ComFont(15);
        girlLabel.textColor = RGB(255, 255, 255);
        [_nilNameView addSubview:girlLabel];
        
        x = 25;
        height = 37;
        CGFloat ySpace = 24;
        if (Is4Inch) {
            ySpace = 12;
        }
        y = h - ySpace - height;
        width = kScreenW - 2*x;
        EMButton *loginBtn = [UIUtil createLoginBtnWithFrame:Rect(x, y, width, height) andTitle:Local(@"LoginBtn") andSelector:@selector(nilNameLoginAction:) andTarget:self];
        [_nilNameView addSubview:loginBtn];
    }
    [self.view.window addSubview:_nilNameView];
}


- (void)sexAction:(EMButton*)btn {
    if (selectedBtn != btn) {
        if (!selectedBtn) {
            selectedBtn = btn;
        }else{
            selectedBtn.selected = NO;
            selectedBtn.layer.borderWidth = 0;
            selectedBtn.layer.borderColor = [UIColor clearColor].CGColor;
        }
        btn.selected = !btn.selected;
        selectedBtn = btn;
        if (selectedBtn.selected) {
            selectedBtn.layer.borderWidth = 8;
            selectedBtn.layer.cornerRadius = btn.frame.size.width/2;
            selectedBtn.layer.borderColor = RGB(145,90,173).CGColor;
        }else{
            selectedBtn.layer.borderWidth = 0;
            selectedBtn.layer.borderColor = [UIColor clearColor].CGColor;
        }
    }
 
}

- (void)nilNameLoginAction:(EMButton*)btn {
    if (!selectedBtn) {
        [self.nilNameView makeToast: [NSString stringWithFormat:@"%@%@",Local(@"ChoosePhoto"),Local(@"Sex")] duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    [self removeMaskView];
    NSString *gender = @"M";
    if (selectedBtn.tag == 100) {
        //男生
        gender = @"M";
    }else {
        //女生
        gender = @"F";
    }
    LoginStatusObj *loginedStatus = [[LoginStatusObj alloc] init];
    loginedStatus.isLogined = NO;
    loginedStatus.shouldGetUserMsg = NO;
    loginedStatus.gender = gender;
    [[FileAccessData sharedInstance] setAObject:loginedStatus forEMKey:@"LoginStatus"];
    loginedStatus = nil;
    
    MainTabBarController *mainTab = [[MainTabBarController alloc] init];
    mainTab.isHiddenNavigationBar = YES;
    LeftSortsViewController *leftVC = [[LeftSortsViewController alloc] init];
    LeftSlideViewController *leftSlideVC = [[LeftSlideViewController alloc] initWithLeftView:leftVC andMainView:mainTab];
    mainTab.slideViewCtl = leftSlideVC;
    [self.navigationController pushViewController:leftSlideVC animated:YES];
    mainTab = nil;
    
    
}


@end
