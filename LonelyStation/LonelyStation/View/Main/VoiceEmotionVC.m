//
//  VoiceEmotionVC.m
//  LonelyStation
//
//  Created by zk on 16/10/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "VoiceEmotionVC.h"

@implementation VoiceEmotionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"outsideBrightPG"]];
    backgroundImageView.frame = Rect(0, 0, kScreenW, kScreenH);
    [self.view addSubview:backgroundImageView];
    [self.viewNaviBar setTitle:Local(@"SpeechEmotion")];
    [self initViews];
}


- (void)initViews {
    
}

@end
