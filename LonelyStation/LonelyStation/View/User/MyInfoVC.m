//
//  MyInfoVC.m
//  LonelyStation
//
//  Created by zk on 2016/10/27.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyInfoVC.h"
#import "EMButton.h"
#import "EMLabel.h"
#import "EMView.h"
#import "UIUtil.h"
#import "ZHPickView.h"
#import "UploadImgViewController.h"
#import "EMUtil.h"
#import "PersonInfoViewModel.h"
#import "ViewModelCommom.h"
#import "MainTabBarController.h"
#import "LeftSortsViewController.h"
#import "EMActionSheet.h"
#import "MainViewVM.h"
#import "LonelySpkLang.h"
#import "MyVoicesVC.h"
#import "WeightObj.h"
#import "IdentyObj.h"
#import "RoleDetailVC.h"
#import "HightObj.h"
#import "RecordIntroduceVC.h"
#import "ProfitObj.h"

@interface MyInfoVC ()<ZHPickViewDelegate>{
    NSMutableDictionary *_textFieldDict;
    NSMutableDictionary *_labelDict;

    NSArray *_labelArray;
    EMButton *selectedBtn;
    ZHPickView *datePicker;
    PersonInfoViewModel *personInfoViewModel;
    NSDictionary *langdict;
    NSMutableDictionary *dataDict;
    EMButton *rightBtn;
    EMButton *uploadBtn;
    EMButton *uploadVoiceBtn;
    MainViewVM *_mainViewVM;
    NSMutableArray *_languageArray;
    NSMutableArray *_countryArray;
    NSMutableArray *_cityArray;
    NSMutableArray *_jobArray;
    NSMutableArray *_weightArray;
    NSMutableArray *_identityArray;
    NSMutableArray *_hightList;

    LonelyCountry *_currentCountry;
    LonelyCity *_currentCity;
    JobObj *_currentJob;
    WeightObj *_currentWeight;
    IdentyObj *_currentIdenty;

    UIImageView *_uploadBtnStatusImgView;
    UIImageView *_uploadVoiceStatusImgView;
    
    NSMutableArray *_valueLabelArray;
    
    NSMutableArray *_valueTextFieldArray;
    NSMutableArray *_valueTextFieldBackArray;
    
    EMLabel *_hightLabel;

    UISlider *_slider;
    
    EMButton *_infoBtn;
    
    UIScrollView *scrollView;
    
    BOOL shouldAction;
    
}

@property (nonatomic,strong)EMLabel *airPortLabel;
@property (nonatomic,strong)EMLabel *giftLabel;
@property (nonatomic,strong)EMLabel *chatLabel;



@end

@implementation MyInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initalData];
    [self initViews];
    [self.viewNaviBar setTitle:Local(@"PersonalInfo") andColor:RGB(145,90,173)];
    

    
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!rightBtn.selected) {
        [UIUtil showHUD:self.view];
        [_mainViewVM getMyProfileWithBlock:^(NSDictionary *dict, BOOL ret) {
            [UIUtil hideHUD:self.view];
            [self getHightList];
            if (dict && ret ) {
                [self updateInfo];
            }else{
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
            }
        }];
    }
}


-(void)initViews{
    rightBtn = [[EMButton alloc] initWithFrame:Rect(0, 25, 70, 30)];
    [rightBtn setTitle:Local(@"Edit") forState:UIControlStateNormal];
    [rightBtn setTitle:Local(@"Complate") forState:UIControlStateSelected];

//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton"] forState:UIControlStateNormal];
//    [rightBtn setBackgroundImage:[UIImage imageNamed:@"upperRightButton_d"] forState:UIControlStateHighlighted];
    [rightBtn.layer setBackgroundColor:RGB(145,90,173).CGColor];
    [rightBtn.titleLabel setFont:ComFont(16)];
    [rightBtn.layer setCornerRadius:10];
    
    [rightBtn setTitleColor:RGBA(0xff, 0xff, 0xff,1) forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(completeAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setRightBtn:rightBtn];
    
    
    scrollView = [[UIScrollView alloc] initWithFrame:Rect(0, 64, kScreenW, kScreenH-64)];
    [self.view addSubview:scrollView];
    
    CGFloat width = 80*kScale;
    CGFloat x = (kScreenW - width * 2 - 38 *kScale)/2.f;
    CGFloat y = 46;
    
    
    EMLabel *desLabel = [[EMLabel alloc] initWithFrame:Rect(0, 0, kScreenW, 30*kScale)];
//    desLabel.textColor = RGB(143,211,244);
//    desLabel.backgroundColor = RGBA(0, 0, 0,0.2);
//    desLabel.text = Local(@"UploadImageCanUseMore");
    desLabel.font = ComFont(13*kScale);
    desLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:desLabel];
    
    
    uploadBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, width)];
    uploadBtn.layer.cornerRadius = width/2;
    uploadBtn.layer.masksToBounds = YES;
    [uploadBtn addTarget:self action:@selector(uploadAction:) forControlEvents:UIControlEventTouchUpInside];
    [uploadBtn setBackgroundImage:[UIImage imageNamed:@"cover_add"] forState:UIControlStateNormal];
    [scrollView addSubview:uploadBtn];
    
    CGFloat statusWidth = 25*kScale;
    _uploadBtnStatusImgView = [[UIImageView alloc] initWithFrame:Rect(x + width - statusWidth, y - 5*kScale, statusWidth, statusWidth)];
    [_uploadBtnStatusImgView setImage:[UIImage imageNamed:@"center_add_big"]];
    [scrollView addSubview:_uploadBtnStatusImgView];
    
    x = PositionX(uploadBtn) + 38*kScale;
    uploadVoiceBtn = [[EMButton alloc] initWithFrame:Rect(x, uploadBtn.frame.origin.y, width, width)];
    uploadVoiceBtn.layer.cornerRadius = width/2;
    uploadVoiceBtn.layer.masksToBounds = YES;
    [uploadVoiceBtn addTarget:self action:@selector(uploadVoiceAction:) forControlEvents:UIControlEventTouchUpInside];
    [uploadVoiceBtn setBackgroundImage:[UIImage imageNamed:@"SBTlistenMe_d"] forState:UIControlStateNormal];
    [scrollView addSubview:uploadVoiceBtn];
    
    
    _uploadVoiceStatusImgView = [[UIImageView alloc] initWithFrame:Rect(x + width - statusWidth, y - 5*kScale, statusWidth, statusWidth)];
    [_uploadVoiceStatusImgView setImage:[UIImage imageNamed:@"center_add_big"]];
    [scrollView addSubview:_uploadVoiceStatusImgView];
    
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    ProfitObj *profit = [[FileAccessData sharedInstance] objectForMemKey:@"profit"];
    NSString *airIn = profit ? profit.radioChatpoint : @"";
    NSString *giftIn = profit ? profit.giftChatpoint : @"";
    NSString *talkIn = profit ? profit.talkChatpoint : @"";
    NSString *listenNum = profit ? profit.listenMeNums : @"0";
    NSString *whoCareNum = profit ? profit.favoriteMeNums : @"0";
    NSString *giftNum = profit ? profit.giftNums : @"0";
    NSArray *numArray = @[@"0",@"0",@"0",whoCareNum,listenNum,giftNum];
    
    if ([@"M" isEqualToString:user.gender]) {
        //如果是男的
        CGFloat aWith = (kScreenW - 17*2*kScale-12*kScale)*0.5;
        _airPortLabel = [[EMLabel alloc] initWithFrame:Rect(17*kScale, PositionY(desLabel)+120*kScale, aWith , 31*kScale) andConners:5*kScale];
        [scrollView addSubview:_airPortLabel];
        [self configLabel:_airPortLabel andGender:@"M" andUpText:Local(@"AirPortIn") andDownText:[NSString stringWithFormat:@"%@%@",airIn,Local(@"ChatMoney")]];
        _giftLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_airPortLabel)+12*kScale, PositionY(desLabel)+120*kScale, aWith, 31*kScale) andConners:5*kScale];

        [scrollView addSubview:_giftLabel];
        [self configLabel:_giftLabel andGender:@"M" andUpText:Local(@"GiftIn") andDownText:[NSString stringWithFormat:@"%@%@",giftIn,Local(@"ChatMoney")]];

    }else {
        CGFloat labelWidth = (kScreenW - 40*kScale)/3;
        _airPortLabel = [[EMLabel alloc] initWithFrame:Rect(10, PositionY(desLabel)+120*kScale, labelWidth, 46*kScale) andConners:5*kScale];
        [scrollView addSubview:_airPortLabel];
        [self configLabel:_airPortLabel andGender:@"F" andUpText:Local(@"AirPortIn") andDownText:[NSString stringWithFormat:@"%@%@",airIn,Local(@"ChatMoney")]];

        _giftLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_airPortLabel)+10*kScale, PositionY(desLabel)+120*kScale, labelWidth, 46*kScale) andConners:5*kScale];
        [self configLabel:_giftLabel andGender:@"F" andUpText:Local(@"GiftIn") andDownText:[NSString stringWithFormat:@"%@%@",giftIn,Local(@"ChatMoney")]];

        [scrollView addSubview:_giftLabel];
        _chatLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_giftLabel)+10*kScale, PositionY(desLabel)+120*kScale, labelWidth, 46*kScale) andConners:5*kScale];
        [scrollView addSubview:_chatLabel];
        [self configLabel:_chatLabel andGender:@"F" andUpText:Local(@"ChatIn") andDownText:[NSString stringWithFormat:@"%@%@",talkIn,Local(@"ChatMoney")]];
    }
    
    EMView *backView = [[EMView alloc] initWithFrame:Rect(0, PositionY(_airPortLabel)+9*kScale, kScreenW, 68*2*kScale)];
    [scrollView addSubview:backView];
    backView.backgroundColor = RGB(209,172,255);
    
//    NSArray *titleArray = @[Local(@"MyCare"),Local(@"WhoListenMe"),Local(@"WhoCareMe"),Local(@"MyCollection"),Local(@"MyRecord"),Local(@"MyVoice")];
//    NSArray *imgArray = @[[UIImage imageNamed:@"Profile_attention"],[UIImage imageNamed:@"Profile_who_me"],[UIImage imageNamed:@"Profile_two_heart"],[UIImage imageNamed:@"Profile_star"],[UIImage imageNamed:@"Profile_my_radio"],[UIImage imageNamed:@"Profile_gift"]];
    NSArray *imgArray = @[[UIImage imageNamed:@"Profile_attention"],[UIImage imageNamed:@"Profile_star"],[UIImage imageNamed:@"Profile_my_radio"],[UIImage imageNamed:@"Profile_two_heart"],[UIImage imageNamed:@"Profile_who_me"],[UIImage imageNamed:@"Profile_gift"]];
     NSArray *titleArray = @[Local(@"MyCare"),Local(@"MyCollection"),Local(@"MyRecord"),Local(@"WhoCareMe"),Local(@"WhoListenMe"),Local(@"MyVoice")];
    CGFloat everyBtnWidth = ScreenWidth/3.f;
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton *control = [[UIButton alloc] initWithFrame:Rect(j*everyBtnWidth, i*68*kScale, everyBtnWidth, 68*kScale)];
            UIImageView *imgView = [[UIImageView alloc] initWithImage:imgArray[i*3+j]];
            imgView.frame = Rect(everyBtnWidth*0.5 - 11*kScale,10*kScale, 30*kScale, 30*kScale);
            [control addSubview:imgView];
            [backView addSubview:control];
            EMLabel *numLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(imgView)-7*kScale, 7*kScale, 18*kScale, 18*kScale) andConners:9*kScale];
            numLabel.backgroundColor = RGB(255,252,0);
            numLabel.textColor = RGB(51,51,51);
            numLabel.font = ComFont(13*kScale);
            numLabel.text = numArray[i*3+j];
            if ([numArray[i*3+j] intValue] == 0){
                numLabel.hidden = YES;
            }
            numLabel.textAlignment = NSTextAlignmentCenter;
            [control addSubview:numLabel];
            
            
            control.tag = 100+i*3+j;
            [control addTarget:self action:@selector(clickAction:)  forControlEvents:UIControlEventTouchUpInside];
            EMLabel *titleLabel = [[EMLabel alloc] initWithFrame:Rect(5*kScale,PositionY(imgView) + 5*kScale, everyBtnWidth-10*kScale, 18*kScale)];
            titleLabel.textColor = RGB(51,51,51);
            titleLabel.font = ComFont(18*kScale);
            titleLabel.text = titleArray[i*3+j];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            [control addSubview:titleLabel];
        }
    }
    
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, PositionY(backView), kScreenW, 1)];
    line.backgroundColor = RGB(171, 171, 171);
    [scrollView addSubview:line];
    
    NSArray *labelArray = @[Local(@"NickName"),Local(@"Birthday"),Local(@"Country"),Local(@"City"),Local(@"Job"),Local(@"Slogan"),Local(@"Height"),Local(@"Weight"),Local(@"Role")];
    NSArray *valueArray = @[user.nickName,user.birthday,user.country,user.city, NOTNULLObj(user.job),NOTNULLObj(user.slogan),NOTNULLObj(user.height),NOTNULLObj(user.weight),NOTNULLObj(user.identityName)];
    y = PositionY(line) + 20*kScale;
    _valueLabelArray = [NSMutableArray array];
    _valueTextFieldArray = [NSMutableArray array];
    _valueTextFieldBackArray = [NSMutableArray array];

    for (int i = 0; i < labelArray.count; i++) {
        x = 33*kScale;
        EMLabel *nameLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, 95*kScale, 30*kScale)];
        nameLabel.text = [NSString stringWithFormat:@"%@:",labelArray[i]];
        nameLabel.textColor = RGB(51,51,51);
        nameLabel.font = ComFont(18*kScale);
        [scrollView addSubview:nameLabel];
        
        EMLabel *valueLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(nameLabel)+10*kScale, y, 215*kScale, 30*kScale)];
        valueLabel.text = valueArray[i];
        if ([@"" isEqualToString:valueArray[i]] || (i == 1 && [@"//" isEqualToString:valueArray[i]])) {
            valueLabel.textColor = RGB(255,0,0);
            valueLabel.text = Local(@"NotFillYet");
        }else{
            valueLabel.textColor = RGB(51,51,51);

        }
        valueLabel.font = ComFont(18*kScale);
        [scrollView addSubview:valueLabel];
        [_valueLabelArray addObject:valueLabel];
        [_labelDict setObject:valueLabel forKey:_labelArray[i]];
        valueLabel.hidden = NO;
        
        if (i != 6) {
            
            CGRect rect = Rect(PositionX(nameLabel) , y, 215*kScale, 30*kScale);
            
            EMImageView *filedBack = [[EMImageView alloc] initWithFrame:rect];
            filedBack.alpha = 0.15;
            filedBack.backgroundColor = RGB(171, 171, 171);
            filedBack.layer.cornerRadius = rect.size.height/2.f;
            filedBack.layer.masksToBounds = YES;
            rect.origin.x = rect.origin.x + 20;
            rect.size.width = rect.size.width-40;
            
            EMTextField *textField = [[EMTextField alloc] initWithFrame:rect];
            textField.text = valueArray[i];
            textField.textColor = RGB(51,51,51);
            textField.font = ComFont(18*kScale);
            [_valueTextFieldArray addObject:textField];
            [_valueTextFieldBackArray addObject:filedBack];
            [_textFieldDict setObject:textField forKey:_labelArray[i]];
            [scrollView addSubview:filedBack];
            [scrollView addSubview:textField];
            if (i == 0 || i == 5) {
                textField.enabled = YES;
            }else {
                textField.enabled = NO;
            }
            
            if (i == labelArray.count - 1) {
                _infoBtn = [[EMButton alloc] initWithFrame:Rect(PositionX(textField)+29, y+3, 24*kScale, 24*kScale)];
                [_infoBtn setImage:[UIImage imageNamed:@"center_message"] forState:UIControlStateNormal];
                [_infoBtn addTarget:self action:@selector(infoClick:) forControlEvents:UIControlEventTouchUpInside];
                [scrollView addSubview:_infoBtn];
                _infoBtn.hidden = YES;
            }
            
            textField.hidden = YES;
            filedBack.hidden = YES;
        }else {
            EMView *sliderBackView = [[EMView alloc] initWithFrame:Rect(PositionX(nameLabel) - 30, y-10, 215*kScale + 40, 50*kScale)];
            
            UILabel *labelLeft = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 25, 30)];
            labelLeft.text = @"140";
            labelLeft.font = ComFont(9);
            labelLeft.textColor = RGB(51,51,51);
            labelLeft.textAlignment = NSTextAlignmentRight;
            [sliderBackView addSubview:labelLeft];
            
            _slider = [[UISlider alloc] initWithFrame:Rect(30, 15, 215*kScale, 30*kScale)];
            UIImage *cicleImage = [UIUtil circleImage:RGB(253,125,255) andSize:CGSizeMake(13*kScale, 13*kScale)];
            [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
            [_slider setThumbImage:cicleImage forState:UIControlStateNormal];
            [_slider setMinimumTrackTintColor:RGB(235,173,255)];
            [_slider setMaximumTrackTintColor:RGB(171, 171, 171)];
            [sliderBackView addSubview:_slider];
            
            UILabel *labelRight = [[UILabel alloc] initWithFrame:CGRectMake(PositionX(_slider)+5, 10, 40, 30)];
            labelRight.text = @"220";
            labelRight.font = ComFont(9);
            labelRight.textColor = RGB(51,51,51);
            [sliderBackView addSubview:labelRight];
            _hightLabel = [[EMLabel alloc] initWithFrame:CGRectMake(30+(215*kScale - 50)/2, 5, 50, 20)];
            _hightLabel.textAlignment = NSTextAlignmentCenter;
            _hightLabel.text = [NSString stringWithFormat:@"%dcm",(int)(140+80*_slider.value)];
            _hightLabel.font = ComFont(9);
            _hightLabel.textColor =  RGB(51,51,51);
            [sliderBackView addSubview:_hightLabel];
            [_valueTextFieldArray addObject:sliderBackView];
            [scrollView addSubview:sliderBackView];
            [_valueTextFieldBackArray addObject:@""];
            
            sliderBackView.hidden = YES;
        }
        y += 10*kScale + 30*kScale;
    }
    scrollView.contentSize = Size(0, y);
    //不能自己填的加上手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFiledTextAction:)];
    [scrollView addGestureRecognizer:tapGesture];
    
    
    
    NSDate *date=[NSDate date];
    datePicker = [[ZHPickView alloc] initDatePickWithDate:date datePickerMode:UIDatePickerModeDate isHaveNavControler:YES];
    datePicker.datePicker.maximumDate = [NSDate date];
    NSDate *nowDate = [NSDate date];
    //算出1970到现在的时间
    NSTimeInterval timeTo1970 = [nowDate timeIntervalSince1970];
    //再往前算 3122064000为99年
    NSTimeInterval leftTime = 3122064000 - timeTo1970;
    //取到从1970年以前的date，用这个dateWithTimeIntervalSinceNow直接取不行
    NSDate *sinceNowDate = [NSDate dateWithTimeIntervalSince1970:-leftTime];
    
    datePicker.datePicker.minimumDate = sinceNowDate;
    EMTextField *textField = [_textFieldDict objectForKey:Local(@"Birthday")];
    if (![textField.text isEqualToString:@""]) {
        date = [EMUtil parseDateFromString:textField.text andFormate:@"YYYY/MM/dd"];
    }
    datePicker.delegate = self;
    if (date != nil && ![date isEqual:[NSNull null]]) {
        datePicker.defaultDatePickerDate = date;

    }
}

- (void)clickAction:(UIControl*)control {
    NSArray *classArray = @[@"MyFocousVC",@"MyFavorateRecordVC",@"MyRecordsViewController",@"WhoCareMeVC",@"WhoListenedMeVC",@"MyGiftsVC"];
    NSString *cla = classArray[control.tag - 100];
    UIViewController *controller =  [[NSClassFromString(cla) alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)configLabel:(EMLabel*)label andGender:(NSString*)gender andUpText:(NSString*)upTxt andDownText:(NSString*)downTxt {
    label.font = ComFont(16*kScale);
    if ([@"M" isEqualToString:gender]) {
        label.textColor = RGB(51, 51, 51);
        label.text = [NSString stringWithFormat:@"%@%@",upTxt,downTxt];
        label.textAlignment = NSTextAlignmentCenter;
        label.borderWidth = 1;
        label.borderColor = RGBA(171, 171, 171, 0.7);
    }else {
        NSString *allText = [NSString stringWithFormat:@"%@\n%@",upTxt,downTxt];
        NSMutableAttributedString *muStr = [[NSMutableAttributedString alloc] initWithString:allText];
        NSRange upRange = [allText rangeOfString:upTxt];
//        NSRange downRange = [allText rangeOfString:downTxt];
        NSDictionary * upAttributes = @{ NSFontAttributeName:ComFont(13*kScale)};
        [muStr setAttributes:upAttributes range:upRange];
        
        label.textAlignment = NSTextAlignmentCenter;
        label.borderWidth = 1;
        label.borderColor = RGBA(171, 171, 171, 0.7);
//        label.text = allText;
        label.attributedText = muStr;
        label.textColor = RGB(51, 51, 51);
        label.numberOfLines = 0;

        
    }
//    label.layer.masksToBounds = YES;
//    label.layer.borderColor = RGBA(255,255,255,0.7).CGColor;
//    label.layer.borderWidth = 1;
}

- (void)infoClick:(EMButton*)btn {
    RoleDetailVC *detail = [[RoleDetailVC alloc] init];
    [self.navigationController pushViewController:detail animated:YES];
}


- (void)sliderValueChanged:(UISlider*)slider {
    _hightLabel.text = [NSString stringWithFormat:@"%d cm",(int)(140+80*slider.value)];
}


- (void)textFiledTextAction:(UIGestureRecognizer*)tapGesture {
    if (shouldAction == NO) {
        return;
    }
    [self.view endEditing:YES];
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    for (int  i = 0; i < _valueTextFieldArray.count; i++) {
        EMTextField *textField = _valueTextFieldArray[i];
        if (tapGesture.state == UIGestureRecognizerStateEnded)
        {
            if (CGRectContainsPoint(textField.frame, point)) {
                //判断是哪个textField
                switch (i) {
                    case 1:{
                        //生日
                         [datePicker show];
                        break;
                    }
                    case 2:{
                        //国家
                        [self countryAction:textField];
                        break;
                    }
                    case 3:{
                        //城市
                        [self cityAction:textField];
                        break;
                    }
                    case 4:{
                        //职业
                        [self jobAction:textField];
                        break;
                    }
                    case 7:{
                        //体型
                        [self weightAction:textField];
                        break;
                    }
                    case 8:{
                        //身份别
                        [self identityAction:textField];
                        break;
                    }
                    default:
                        break;
                }
                break;
            }
        }
    }
}


- (void)getHightList {
    [_mainViewVM getHightListWithBlock:^(NSArray *array, BOOL ret) {
        if (array && ret) {
            _hightList = nil;
            _hightList = [NSMutableArray arrayWithArray:array];
        }
    }];
}

- (void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString {
    if (pickView == datePicker) {
        [datePicker remove];
        EMTextField *birthTextField = [_textFieldDict objectForKey:Local(@"Birthday")];
        NSString *birthday = [EMUtil getDateStringWithDate:[EMUtil parseDateFromString:resultString andFormate:@"YYYY-MM-dd HH:mm:ss"] DateFormat:@"YYYY/MM/dd"];
        birthTextField.text = birthday;
        [dataDict setObject:birthday forKey:Local(@"Birthday")];
    }
}

-(void)toobarDonBtnCancel{
    [datePicker remove];
}



- (void)uploadVoiceAction:(EMButton*)btn {
//    MyVoicesVC *uploadViewController = [[MyVoicesVC alloc] init];
//    [self.navigationController pushViewController:uploadViewController animated:YES];
//    uploadViewController = nil;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    if (user.voice.length > 0 && [user.voiceStatus intValue] == 2) {
        AllPopView *alertView = [[AllPopView alloc] initWithTitle:Local(@"Warning") message:Local(@"RecordWaring") clickedBlock:^(AllPopView *alertView, BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled) {
                RecordIntroduceVC *recordIntVC = [[RecordIntroduceVC alloc] init];
                recordIntVC.seq = 1;
                [self.navigationController pushViewController:recordIntVC animated:YES];
            }
        } cancelButtonTitle:Local(@"Cancel") otherButtonTitles:Local(@"Sure"), nil];
        [alertView show];
        alertView = nil;
    }else {
        RecordIntroduceVC *recordIntVC = [[RecordIntroduceVC alloc] init];
        recordIntVC.seq = 1;
        [self.navigationController pushViewController:recordIntVC animated:YES];
    }

    
}




- (void)updateInfo{
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    NSArray *valueArray = @[user.nickName,user.birthday,user.country,user.city,user.job,user.slogan,user.height,user.weight,user.identityName];
    for (int i = 0; i<_labelArray.count; i++) {
        EMLabel *label = _labelDict[_labelArray[i]];
        label.text = valueArray[i];
        if ([@"" isEqualToString:valueArray[i]] || (i == 1 && [@"//" isEqualToString:valueArray[i]])) {
            label.textColor = RGB(255,0,0);
            label.text = Local(@"NotFillYet");
        }else{
            label.textColor = RGB(51,51,51);
            
        }
        EMTextField *textField = _textFieldDict[_labelArray[i]];
        if (textField){
            textField.text = valueArray[i];
        }
    }
    _hightLabel.text = user.height;
    _slider.value = ([user.height intValue] - 140)/80.f;
    _currentJob.jobId = user.jobId;
    _currentJob.jobName = user.job;
    _currentWeight.weightId = user.weightId;
    _currentWeight.weightName = user.weight;
    
    //判断file1和file2有没有成功的，有的话就放在左边
    if (user.file.length > 0 && [user.fileStatus intValue] == 2) {
        [uploadBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:user.file] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"uploadPicture"]];
        [uploadBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:user.file] forState:UIControlStateSelected placeholder:[UIImage imageNamed:@"uploadPicture_d"]];
    }else{
        if (user.file2.length > 0 && [user.file2Status intValue] == 2) {
            [uploadBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:user.file2] forState:UIControlStateNormal placeholder:[UIImage imageNamed:@"uploadPicture"]];
            [uploadBtn yy_setBackgroundImageWithURL:[NSURL URLWithString:user.file2] forState:UIControlStateSelected placeholder:[UIImage imageNamed:@"uploadPicture_d"]];
        }
        
    }
    
    //判断五个头像有没有上传成功
    if(user.file.length > 0 && [user.fileStatus intValue] == 2 && user.file2.length > 0 && [user.file2Status intValue] == 2 && user.file3.length > 0 && [user.file3Status intValue] == 2 && user.file4.length > 0 && [user.file4Status intValue] == 2 && user.file5.length > 0 && [user.file5Status intValue] == 2) {
        _uploadBtnStatusImgView.image = [UIImage imageNamed:@"center_finish_big"];
    }else {
        _uploadBtnStatusImgView.image = [UIImage imageNamed:@"center_add_big"];
    }

    //判断声音有没有上传成功
    if (user.voice.length > 0 && [user.voiceStatus intValue] == 2) {
        _uploadVoiceStatusImgView.image = [UIImage imageNamed:@"center_finish_big"];
    }else if (user.voice.length > 0 && [user.voiceStatus intValue] == 1) {
        _uploadVoiceStatusImgView.image = [UIImage imageNamed:@"center_audit_big"];
    }else if (user.voice.length > 0 && [user.voiceStatus intValue] == 3) {
        _uploadVoiceStatusImgView.image = [UIImage imageNamed:@"center_no_big"];
    }else {
        _uploadVoiceStatusImgView.image = [UIImage imageNamed:@"center_add_big"];
    }
}

- (void)completeAction:(EMButton*)btn {
    if (btn.selected) {
        //完成
        [self.view endEditing:YES];
        //判断是否录了自介
        if([UIUtil alertVoiceRecordWarning:self andMsg:Local(@"PlsRecordIntroduce")]) {
            return;
        }
        NSString *nickName = [(EMTextField*)_textFieldDict[Local(@"NickName")] text];
        NSString *birthday = [(EMTextField*)_textFieldDict[Local(@"Birthday")] text];
        NSString *country = _currentCountry.countryId;
        NSString *city = _currentCity.cityId;
        NSString *job = _currentJob.jobId;
        NSString *slogan = [(EMTextField*)_textFieldDict[Local(@"Slogan")] text];
        NSString *height = _hightLabel.text;
        if (_hightList && _hightList.count >0) {
            for (int i = 0; i < _hightList.count; i++) {
                HightObj *obj = _hightList[i];
                if ([obj.hightName intValue] == height.intValue) {
                    height = obj.hightId;
                    break;
                }
            }
        }else {
            if (height.intValue > 210) {
                height = @"72";
            }else if(height.intValue >= 140){
                height = [NSString stringWithFormat:@"%d",[_hightLabel.text intValue] - 139];
            }else {
                height = @"1";
            }
        }
        NSString *weight = _currentWeight.weightId;
        NSString *identity = _currentIdenty.identyId;
        
        if(nickName.length > 6) {
            [self.view.window makeToast:Local(@"NickNameLimit6") duration:ERRORTime position:[CSToastManager defaultPosition]];
            return;
        }
        
        if (slogan.length > 8) {
            [self.view.window makeToast:Local(@"SloganLimit8") duration:ERRORTime position:[CSToastManager defaultPosition]];
            return;
        }
        
        [UIUtil showHUD:self.view];
        [_mainViewVM updateProfile:nickName andBirth:birthday andCountry:country andCity:city andJob:job andSlogan:slogan andHeight:height andWeight:weight andIdentity:identity andBlock:^(NSDictionary *adict, BOOL ret) {
            [UIUtil hideHUD:self.view];
            if (adict && ret) {
                if ([adict[@"code"] intValue] == 1) {
                    LonelyUser *user = [ViewModelCommom getCuttentUser];
                    user.identity = _currentIdenty.identyId;
                    user.identityName = _currentIdenty.identyName;
                    user.nickName = nickName;
                    user.birthday = birthday;
                    user.country = _currentCountry.countryName;
                    user.countryId = country;
                    user.cityId = city;
                    user.city = _currentCity.cityName;
                    user.job = _currentJob.jobName;
                    user.jobId = _currentJob.jobId;
                    user.slogan = slogan;
                    user.heightId = height;
                    
                    [[FileAccessData sharedInstance] setAObject:user forEMKey:user.userName];
                    [self.view.window makeToast:adict[@"OperateSuccess"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                    [self.navigationController popViewControllerAnimated:YES];
                }else {
                    [self.view.window makeToast:adict[@"msg"] duration:ERRORTime position:[CSToastManager defaultPosition]];
                }
            }else{
                [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                
            }
        }];
    }
    
    btn.selected = !btn.selected;
    for (int i = 0; i<_valueLabelArray.count; i++) {
        UIView *viewLable = _valueLabelArray[i];
        viewLable.hidden = btn.selected;
        UIView *viewTextField = _valueTextFieldArray[i];
        viewTextField.hidden = !btn.selected;
        if(i!= 6){
            UIView *viewTextBack = _valueTextFieldBackArray[i];
            viewTextBack.hidden = !btn.selected;
            _infoBtn.hidden = !btn.selected;
        }
    }
    if (btn.selected) {
        shouldAction = YES;
    }else{
        shouldAction = NO;
    }
}


- (void)uploadAction:(EMButton*)btn {
    UploadImgViewController *uploadViewController = [[UploadImgViewController alloc] init];
    [self.navigationController pushViewController:uploadViewController animated:YES];
    uploadViewController = nil;
}

- (void)initalData {
    _mainViewVM = [[MainViewVM alloc] init];
    _textFieldDict = [NSMutableDictionary dictionary];
    _labelDict = [NSMutableDictionary dictionary];
    _labelArray = @[Local(@"NickName"),Local(@"Birthday"),Local(@"Country"),Local(@"City"),Local(@"Job"),Local(@"Slogan"),Local(@"Height"),Local(@"Weight"),Local(@"Role")];
    dataDict = [NSMutableDictionary dictionary];
    for (int i = 0; i < _labelArray.count; i++) {
        [dataDict setObject:@"" forKey:_labelArray[i]];
    }
    personInfoViewModel = [[PersonInfoViewModel alloc] init];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    _currentCountry = [[LonelyCountry alloc] init];
    _currentCountry.countryName = user.country;
    _currentCountry.countryId = user.countryId;
    _currentCity = [[LonelyCity alloc] init];
    _currentCity.cityId = user.cityId;
    _currentCity.cityName = user.city;
    _currentWeight = [[WeightObj alloc] init];
    _currentWeight.weightName = user.weight;
    _currentIdenty = [[IdentyObj alloc] init];
    _currentIdenty.identyName = user.identityName;
    _currentIdenty.identyId = user.identity;
    _currentJob = [[JobObj alloc] init];
    _currentJob.jobName = user.job;
    if (_currentIdenty.identyName && ![_currentIdenty.identyName isEqual:[NSNull null]]) {
        [dataDict setObject:_currentIdenty.identyName forKey:Local(@"Role")];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 国家 城市 职业等列表
- (void)getCountryListAndShow:(EMTextField*)texfield {
    [UIUtil showHUD:self.view];
    [_mainViewVM getCountryListWithBlock:^(NSArray<LonelyCountry *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _countryArray = nil;
            _countryArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showCountrySheet:texfield];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}


//显示国家列表
- (void)showCountrySheet:(EMTextField*)texfield {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Country") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyCountry *country = _countryArray[buttonIndex-1];
            _currentCountry = country;
            texfield.text = country.countryName;
            [dataDict setObject:country.countryId forKey:Local(@"Country")];
            
            EMTextField *cityField = [_textFieldDict objectForKey:Local(@"City")];
            cityField.text = @"";
            [dataDict setObject:@"" forKey:Local(@"City")];
            
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _countryArray.count; i++) {
        LonelyCountry *country = _countryArray[i];
        [sheet addButtonWithTitle:country.countryName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//国家
- (void)countryAction:(EMTextField*)texfield {
    if (!_countryArray) {
        [self getCountryListAndShow:texfield];
    }else {
        if (_countryArray.count == 0) {
            [self getCountryListAndShow:texfield];
        }else {
            [self showCountrySheet:texfield];
        }
    }
}


//城市
- (void)cityAction:(EMTextField*)texfield {
    if (!_currentCountry || [_currentCountry.countryId intValue] <= 0) {
        [self.view makeToast:Local(@"LanguageDefault") duration:1 position:[CSToastManager defaultPosition]];
    }else {
        [self getCityAndShow:texfield];
    }
}

//获取城市和显示
- (void)getCityAndShow:(EMTextField*)texfield{
    [UIUtil showHUD:self.view];
    [_mainViewVM getCityListByCountryId:_currentCountry.countryId andBlock:^(NSArray<LonelyCity *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _cityArray = nil;
            _cityArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showCitySheet:texfield];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示城市列表
- (void)showCitySheet:(EMTextField*)texfield {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"City") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            LonelyCity *city = _cityArray[buttonIndex-1];
            texfield.text = city.cityName;
            _currentCity = city;
            [dataDict setObject:city.cityId forKey:Local(@"City")];
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _cityArray.count; i++) {
        LonelyCity *city = _cityArray[i];
        [sheet addButtonWithTitle:city.cityName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}


//获取职业和显示
- (void)getJobAndShow:(EMTextField*)btn {
    [UIUtil showHUD:self.view];
    [_mainViewVM getJobListWithBlock:^(NSArray<JobObj *> *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _jobArray = nil;
            _jobArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showJobSheet:btn];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示职业列表
- (void)showJobSheet:(EMTextField*)btn {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Job") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            JobObj *job = _jobArray[buttonIndex-1];
            _currentJob = job;
            btn.text = job.jobName;
        }else {
            _currentJob = nil;
            btn.text = @"";
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _jobArray.count; i++) {
        JobObj *job = _jobArray[i];
        [sheet addButtonWithTitle:job.jobName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//职业
- (void)jobAction:(EMTextField*)btn {
    if (!_jobArray) {
        [self getJobAndShow:btn];
    }else {
        if (_jobArray.count == 0) {
            [self getJobAndShow:btn];
        }else {
            [self showJobSheet:btn];
        }
    }
}



//获取体型和显示
- (void)getWeightAndShow:(EMTextField*)btn {
    [UIUtil showHUD:self.view];
    [_mainViewVM getWeightListWithBlock:^(NSArray *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _weightArray = nil;
            _weightArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showWeightSheet:btn];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示体型列表
- (void)showWeightSheet:(EMTextField*)btn {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Weight") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            WeightObj *weight = _weightArray[buttonIndex-1];
            _currentWeight = weight;
            btn.text = weight.weightName;
        }else {
            _currentWeight = nil;
            btn.text = @"";
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _weightArray.count; i++) {
        WeightObj *weight = _weightArray[i];
        [sheet addButtonWithTitle:weight.weightName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//体型
- (void)weightAction:(EMTextField*)btn {
    if (!_weightArray) {
        [self getWeightAndShow:btn];
    }else {
        if (_weightArray.count == 0) {
            [self getWeightAndShow:btn];
        }else {
            [self showWeightSheet:btn];
        }
    }
}


//获取身份别和显示
- (void)getIdentityAndShow:(EMTextField*)btn {
    [UIUtil showHUD:self.view];
    [_mainViewVM getIdentityListWithBlock:^(NSArray *arr, BOOL ret) {
        [UIUtil hideHUD:self.view];
        if (arr && ret) {
            _identityArray = nil;
            _identityArray = [[NSMutableArray alloc] initWithArray:arr];
            [self showIdentitySheet:btn];
        }else {
            [self.view.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
        }
    }];
}

//显示身份别列表
- (void)showIdentitySheet:(EMTextField*)btn {
    EMActionSheet *sheet = [[EMActionSheet alloc] initWithTitle:Local(@"Role") clickedBlock:^(EMActionSheet *sheetView, BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            IdentyObj *identity = _identityArray[buttonIndex-1];
            _currentIdenty = identity;
            btn.text = identity.identyName;
        }
    } cancelButtonTitle:Local(@"Cancel") destructiveButtonTitle:nil otherButtonTitles: nil];
    for (int i = 0; i < _identityArray.count; i++) {
        IdentyObj *identity = _identityArray[i];
        [sheet addButtonWithTitle:identity.identyName];
    }
    [sheet showInView:self.view];
    sheet = nil;
}

//身份别
- (void)identityAction:(EMTextField*)btn {
    if (!_identityArray) {
        [self getIdentityAndShow:btn];
    }else {
        if (_identityArray.count == 0) {
            [self getIdentityAndShow:btn];
        }else {
            [self showIdentitySheet:btn];
        }
    }
}



@end
