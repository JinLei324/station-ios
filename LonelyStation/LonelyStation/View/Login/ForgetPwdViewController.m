//
//  ForgetPwdViewController.m
//  LonelyStation
//
//  Created by zk on 16/5/22.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ForgetPwdViewController.h"
#import "UIUtil.h"
#import "EMLabel.h"
#import "EMImageView.h"
#import "LoginViewModel.h"
#import "UIView+Toast.h"


@interface ForgetPwdViewController (){
    EMView *_topView;
    EMTextField *_emailTextField;
    LoginViewModel *_loginViewModel;
}

@end

@implementation ForgetPwdViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self initViews];
    _loginViewModel = [[LoginViewModel alloc] init];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return AppBarStyle;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)initViews{
    
//    EMButton *backBtn = [[EMButton alloc] initWithFrame:Rect(11, 44, 18, 20)];
//    [backBtn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
//    [backBtn setImage:[UIImage imageNamed:@"back_d"] forState:UIControlStateHighlighted];
//    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
    
    CGFloat x = 33;
    CGFloat y = 150;
    if (kScreenH == 568 || (kScreenH == 480)) {
        y = 100;
    }
    CGFloat width = kScreenW-x*2;
    CGFloat height = kScreenH-y;
    _topView = [[EMView alloc] initWithFrame:Rect(x, y, width, height)];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    
    EMButton *_forgetBtn = [self buttonWithName:Local(@"ForgetBtn") andFrame:Rect(27, 0, 99, 44)];
    _forgetBtn.selected = YES;
    [_topView addSubview:_forgetBtn];
    EMView *_slideView = [[EMView alloc] initWithFrame:Rect(27, PositionY(_forgetBtn), 86, 3)];
    _slideView.backgroundColor = RGB(0x98, 0x4f, 0xa6);
    _slideView.center = Point(_forgetBtn.center.x, _slideView.center.y);
    [_topView addSubview:_slideView];
    
    if (kScreenH == 568 || (kScreenH == 480)) {
        x = 12;
    }else{
        x = 40;
    }
    
    EMLabel *topLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_slideView)+57, kScreenW-2*40, 16)];
    topLabel.text = Local(@"PlsInputYourEmail");
    topLabel.textColor = RGB(51, 51, 51);
    topLabel.alpha = 0.8;
    topLabel.font = ComFont(17);
    [_topView addSubview:topLabel];
    
    EMLabel *bottomLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(topLabel)+12, kScreenW-2*40, 16)];
    bottomLabel.text = Local(@"WeWillSendEmailToYou");
    bottomLabel.textColor = RGB(51, 51, 51);
    bottomLabel.alpha = 0.8;
    bottomLabel.font = ComFont(17);
    [_topView addSubview:bottomLabel];
    
    _emailTextField = [self textFieldWithPlaceHolder:Local(@"UserName") andName:@"email" andFrame:Rect(0, PositionY(bottomLabel)+51, kScreenW-2*28, 37)];
    _emailTextField.keyboardType = UIKeyboardTypeEmailAddress;

    EMButton *forgetBtn = [UIUtil createPurpleBtnWithFrame:Rect(0, PositionY(_emailTextField)+73, kScreenW-2*28, 37) andTitle:Local(@"EnSureSend") andSelector:@selector(forgetAction:)  andTarget:self];
    [_topView addSubview:forgetBtn];
}

-(void)forgetAction:(EMButton*)sender{
    if(![UIUtil checkTextIsNotNull:_emailTextField.text]){
        [self.view makeToast:Local(@"PlsInputUser") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    if(![UIUtil isValidateEmail:_emailTextField.text]){
        [self.view makeToast:Local(@"PlsInputRightEmail") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    UIActivityIndicatorView *activity_indicator_view = [[UIActivityIndicatorView alloc] initWithFrame:((EMButton*)sender).bounds];
    [activity_indicator_view setUserInteractionEnabled:YES];//点击不传递事件到button
    [activity_indicator_view setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activity_indicator_view.tag = 4001;
    [((EMButton*)sender) addSubview:activity_indicator_view];
    [activity_indicator_view startAnimating];
    activity_indicator_view = nil;
    [((EMButton*)sender) setTitle:@"" forState:UIControlStateNormal];
    
    [_loginViewModel forget:_emailTextField.text andBlock:^(NSDictionary *dict, BOOL ret) {
        UIActivityIndicatorView *active = [sender viewWithTag:4001];
        [active stopAnimating];
        [active removeFromSuperview];
        active.userInteractionEnabled = NO;
        [sender setTitle:Local(@"EnSureSend") forState:UIControlStateNormal];
        if (ret) {
            
            if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                [self.view makeToast:Local(@"ForgetSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }else{
                [self.view makeToast:[[dict objectForKey:ERRORKEY] objectForKey:@"text"]  duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else{
            [self.view makeToast:Local(@"ForgetFailed")  duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
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

    placeholderLabel.textColor = RGB(49,49,49);
    field.titStr = name;
    [_topView addSubview:filedBack];
    [_topView addSubview:field];
    return field;
}

-(EMButton*)buttonWithName:(NSString*)name andFrame:(CGRect)rect{
    EMButton *btn = [[EMButton alloc] initWithFrame:rect];
    btn.titStr = name;
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitleColor:RGB(51, 51, 51) forState:UIControlStateNormal];
    [btn setEnabled:NO];
    return btn;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
