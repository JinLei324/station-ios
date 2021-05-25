//
//  RegisterViewController.m
//  LonelyStation
//
//  Created by 钟铿 on 2017/12/9.
//  Copyright © 2017年 zk. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIUtil.h"
#import "EMView.h"
#import "PersonInfoViewController.h"
#import "StandViewController.h"

@interface RegisterViewController (){
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
}

@property (nonatomic) CGPoint scrollViewStartPosPoint;
@property (nonatomic) int     scrollDirection;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTopView];
    [self initBottomView];
    // Do any additional setup after loading the view.
}


-(void)initTopView{
    CGFloat x = 33;
    CGFloat y = 130;
    if (kScreenH == 568 || (kScreenH == 480)) {
        y = 70;
    }
    CGFloat width = kScreenW-x*2;
    CGFloat height = 47;
    _topView = [[EMView alloc] initWithFrame:Rect(x, y, width, height)];
    _topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_topView];
    
    UILabel *logoLabel = [[UILabel alloc] initWithFrame:Rect(0, 100, kScreenW, 30)];
    logoLabel.text = Local(@"SignAccount");
    logoLabel.textAlignment = NSTextAlignmentCenter;
    logoLabel.textColor = RGB(51, 51, 51);
    logoLabel.font = BoldFont(27);
    [self.view addSubview:logoLabel];
}


-(void)initBottomView{
    _bottomScrollView = [[UIScrollView alloc] initWithFrame:Rect(0, _topView.frame.origin.y+_topView.frame.size.height, kScreenW, kScreenH-(_topView.frame.origin.y+_topView.frame.size.height))];
    _bottomScrollView.backgroundColor = [UIColor clearColor];
    _bottomScrollView.contentSize = Size(0, 0);
    _bottomScrollView.pagingEnabled = YES;
    [self.view addSubview:_bottomScrollView];
    [self initBottomRightView];
}

- (void)initBottomRightView{
    CGFloat x = 33;
    CGFloat y = 70;
    CGFloat width = kScreenW-x*2;
    CGFloat height = 40;
    CGFloat ySpace = 28;
    CGFloat ySpaceRegist = 50;
    //    CGFloat corner = 20;
    if(kScreenH == 568){
        ySpaceRegist = 28;
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
    
    EMButton *nextStepBtn = [UIUtil createPurpleBtnWithFrame:Rect(x, y, width, height) andTitle:Local(@"NextStep") andSelector:@selector(registAction:)  andTarget:self];
    [_bottomScrollView addSubview:nextStepBtn];
    
    
    
    y = 31;
    if (kScreenH == 480) {
        y -= 17;
    }
    EMView *line = [[EMView alloc] initWithFrame:Rect(x,  _bottomScrollView.frame.size.height-2*y-height-1, width, 1)];
    line.alpha = 0.7;
    line.backgroundColor = RGB(171, 171, 171);
    [_bottomScrollView addSubview:line];
    
    EMButton *forgetBtn = [UIUtil buttonWithName:@"" andFrame:Rect(x, _bottomScrollView.frame.size.height-y-height, width, height) andSelector:@selector(standedAction:) andTarget:self isEnable:YES];
    forgetBtn.alpha = 0.7;
    [forgetBtn.titleLabel setFont:ComFont(13)];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc]initWithString:Local(@"EnSureNextStep")];
    [str
     addAttribute:NSForegroundColorAttributeName value:RGB(145,90,173) range:NSMakeRange(Local(@"EnSureNextStep").length-Local(@"Standed").length,Local(@"Standed").length)];
    [str
     addAttribute:NSForegroundColorAttributeName value:RGB(51, 51, 51) range:NSMakeRange(0,Local(@"EnSureNextStep").length-Local(@"Standed").length)];
    [forgetBtn setAttributedTitle:str forState:UIControlStateNormal];
    [_bottomScrollView addSubview:forgetBtn];
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
    [_bottomScrollView addSubview:filedBack];
    [_bottomScrollView addSubview:field];
    return field;
}

-(void)standedAction:(EMButton*)button{
    StandViewController *stand = [[StandViewController alloc] init];
    [self.navigationController pushViewController:stand animated:YES];
    stand = nil;
}



-(void)registAction:(EMButton*)button{
    
    //    PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] init];
    //    [self.navigationController pushViewController:personInfo animated:YES];
    //    personInfo = nil;
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
    [self startAnimation:button];
    if (!_loginViewModel) {
        _loginViewModel = [LoginViewModel new];
    }
    [_loginViewModel regist:_registerUserTextField.text andPwd:_registerPwdTextField.text andBlock:^(NSDictionary *dict, BOOL ret) {
        [self endAnimation:button];
        [button setTitle:Local(@"NextStep") forState:UIControlStateNormal];
        if (dict && ret) {
            if ([[[dict objectForKey:@"code"] objectForKey:@"text"] isEqualToString:@"1"]) {
                DLog(@"dict==%@",dict);
                LonelyUser *user = [[LonelyUser alloc] init];
                user.userID = [[dict objectForKey:@"userid"] objectForKey:@"text"];
                user.userName = _registerUserTextField.text;
                user.password = _registerPwdTextField.text;
                user.sipid = dict[@"sip_info"][@"account"][@"text"];
                user.sipHost = dict[@"sip_info"][@"host"][@"text"];
                user.sipPort = dict[@"sip_info"][@"port"][@"text"];
                [ViewModelCommom setCurrentEmail:user.userName];
                [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                [self.view makeToast:Local(@"RegisterSuccess") duration:ERRORTime position:[CSToastManager defaultPosition]];
                PersonInfoViewController *personInfo = [[PersonInfoViewController alloc] init];
                [self.navigationController pushViewController:personInfo animated:YES];
                personInfo = nil;
            }else{
                [self.view makeToast:[[dict objectForKey:ERRORKEY] objectForKey:@"text"]  duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }else{
            [self.view makeToast:Local(@"RegisterFailed") duration:ERRORTime position:[CSToastManager defaultPosition]];
            
        }
    }];
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

-(void)endAnimation:(EMButton*)btn{
    UIActivityIndicatorView *active = [btn viewWithTag:4001];
    [active stopAnimating];
    [active removeFromSuperview];
    active.userInteractionEnabled = NO;
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
