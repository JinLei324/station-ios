//
//  LiveMallVC.m
//  LonelyStation
//
//  Created by jinxixin on 2018/12/10.
//  Copyright © 2018 zk. All rights reserved.
//

#import "LiveMallVC.h"
#import "LoginStatusObj.h"
#import "Masonry.h"
@interface LiveMallVC ()

@property (nonatomic,strong)UILabel *bridgeLabel;

@end


@implementation LiveMallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setLeftAndTitle];
    [self initBack];
}


- (void)initBack {
    UIImageView *imageView = [UIImageView new];
    imageView.image = [UIImage imageNamed:@"bg_live"];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(200*kScale);
    }];
    
    UILabel *label = [UILabel new];
    label.textColor = RGB(145,90,173);
    [self.view addSubview:label];
    label.font = [UIFont systemFontOfSize:28];
    label.text = Local(@"LiveText");
    label.textAlignment = NSTextAlignmentCenter;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.equalTo(imageView.mas_bottom).offset(50*kScale);
    }];
    label.numberOfLines = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    self.bridgeLabel.text = [NSString stringWithFormat:@"%@",user.unread];
}


- (void)userInfo:(id)sender {
    [self.tabViewController sliderLeftController];
}


- (void)setLeftAndTitle {
    EMButton *userInfoBtn = [[EMButton alloc] initWithFrame:Rect(15, 33, 40, 40) isRdius:YES];
    //    [userInfoBtn setImage:[UIImage imageNamed:@"answer_no_photo"] forState:UIControlStateNormal];
    LoginStatusObj *loginStatus =[LoginStatusObj yy_modelWithDictionary:(NSDictionary*)[[FileAccessData sharedInstance] objectForEMKey:@"LoginStatus"]];
    if (loginStatus.isLogined) {
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        [userInfoBtn yy_setImageWithURL:[NSURL URLWithString:user.file] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:user.gender]]];
    }else {
        if ([loginStatus.gender isEqualToString:@"M"]) {
            [userInfoBtn setImage:[UIImage imageNamed:@"gender_M"] forState:UIControlStateNormal];
        }else{
            [userInfoBtn setImage:[UIImage imageNamed:@"gender_F"] forState:UIControlStateNormal];
        }
    }
    
    [userInfoBtn addTarget:self action:@selector(userInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNaviBar setLeftBtn:nil];
    [self.viewNaviBar addSubview:userInfoBtn];
    
    //添加提示的文字
    _bridgeLabel = [[UILabel alloc] initWithFrame:Rect(PositionX(userInfoBtn) - 5, 33, 19, 13)];
    _bridgeLabel.layer.cornerRadius = 5;
    _bridgeLabel.layer.masksToBounds = YES;
    _bridgeLabel.backgroundColor = RGB(255,252,0);
    _bridgeLabel.textAlignment = NSTextAlignmentCenter;
    _bridgeLabel.text = @"0";
    _bridgeLabel.textColor = RGB(51,51,51);
    _bridgeLabel.font = ComFont(8);
    [self.viewNaviBar addSubview:_bridgeLabel];
    
    EMLabel *infoLabel = [[EMLabel alloc] initWithFrame:Rect((kScreenW - 200)/2, 33, 200, 44)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = RGB(145,90,173);
    infoLabel.font = ComFont(19.f);
    infoLabel.text = Local(@"LiveMall");
    [self.viewNaviBar addSubview:infoLabel];
    
    UIView *view = [UIView new];
    view.backgroundColor = RGB(171, 171, 171);
    [self.viewNaviBar addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(0);
        make.bottom.mas_equalTo(15);
        make.height.mas_equalTo(1);
    }];
}


@end
