//
//  GJGCChatInputExpandEmojiPanelGifPageItem.m
//  ZYChat
//
//  Created by ZYVincent QQ:1003081775 on 15/6/3.
//  Copyright (c) 2015年 ZYProSoft.  QQ群:219357847  All rights reserved.
//

#import "MJChatInputExpandEmojiPanelGifPageItem.h"
#import "MJChatBarNotificationCenter.h"
#import "EMView.h"
#import "ViewModelCommom.h"
#import "AppDelegate.h"
#import "AddMoneyMainVC.h"

#define GJCFSystemScreenWidth [UIScreen mainScreen].bounds.size.width //获取屏幕的宽度
#define GJCFSystemScreenHeight [UIScreen mainScreen].bounds.size.height //获取屏幕的高度
#define GJGCChatInputExpandEmojiPanelPageItemSubIconTag 3987652

@interface MJChatInputExpandEmojiPanelGifPageItem ()


@property (nonatomic,strong)NSMutableArray *emojiNamesArray;


//@property (nonatomic,strong)NSTimer *touchTimer;

//@property (nonatomic,assign)BOOL isLongPress;

//@property (nonatomic,assign)CGPoint longPressPoint;

//半透明的view
@property (nonatomic,strong)UIButton *maskViewBtn;

@property (nonatomic,strong)UIButton *maskBtn;

@property (nonatomic,strong)UILabel *maskLabel;


//送礼view
@property (nonatomic,strong) EMButton *maskBtnView;

@property (nonatomic,strong) UIView *sendView;

@property (nonatomic,assign)int sendGiftSec;

@property (nonatomic,strong)NSString *sendGiftText;


@end

@implementation MJChatInputExpandEmojiPanelGifPageItem

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withEmojiNameArray:(NSArray *)emojiArray
{
    if (self = [super initWithFrame:frame]) {
        [self initSubViewsWithEmojiNames:emojiArray];
    }
    
    return self;
}

- (void)initSubViewsWithEmojiNames:(NSArray *)emojiArray
{
    NSInteger rowCount = 4;
    NSInteger cloumnCount = 4;
    CGFloat emojiHeight = 69;
    CGFloat emojiWidth = GJCFSystemScreenWidth/4;
    CGFloat distance = (kScreenW - emojiHeight*4)/6.f;
    
    
    CGFloat emojiMarginY = (self.bounds.size.height - rowCount * emojiHeight)/(rowCount + 1);
    
    for (int i = 0; i < emojiArray.count; i++) {
        
        NSInteger rowIndex = i/cloumnCount;
        NSInteger cloumnIndex = i%cloumnCount;
        
        NSString *iconName = [NSString stringWithFormat:@"%@_l.png",[emojiArray objectAtIndex:i]];
        UIButton *gifEmojiButton = [[UIButton alloc] initWithFrame:CGRectMake(cloumnIndex*emojiWidth + distance, (rowIndex+1)*emojiMarginY + rowIndex*emojiHeight, emojiHeight, emojiHeight)];
        gifEmojiButton.titleLabel.text = iconName;
        [gifEmojiButton setImage:[UIImage imageNamed:iconName] forState:normal];
        [gifEmojiButton addTarget:self action:@selector(tapOnEmojiButton:) forControlEvents:UIControlEventTouchUpInside];
        gifEmojiButton.tag = GJGCChatInputExpandEmojiPanelPageItemSubIconTag + i;
        
        [self addSubview:gifEmojiButton];
        
    }
    _maskViewBtn = [[UIButton alloc] initWithFrame:self.bounds];
    _maskViewBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    [_maskViewBtn addTarget:self action:@selector(maskViewBtnTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_maskViewBtn];
    _maskBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    [_maskBtn addTarget:self action:@selector(maskTap:) forControlEvents:UIControlEventTouchUpInside];
    [_maskViewBtn addSubview:_maskBtn];
    
    _maskLabel = [[UILabel alloc] initWithFrame:Rect(0,kScreenH-34, kScreenW, 34)];
    _maskLabel.backgroundColor = RGB(158,158,158);
    _maskLabel.textColor = RGB(255,255,255);
    _maskLabel.font = ComFont(16);
    _maskLabel.textAlignment = NSTextAlignmentCenter;
    [[UIApplication sharedApplication].keyWindow addSubview:_maskLabel];
    [self hiddenMask];
    
    
    _maskBtnView = [[EMButton alloc] initWithFrame:Rect(0, 0, ScreenWidth, ScreenHeight)];
    _maskBtnView.alpha = 0;
    _maskBtnView.hidden = YES;
    _maskBtnView.backgroundColor = RGBA(0, 0, 0,0.6);
    [_maskBtnView addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] addSubview:_maskBtnView];
    
    CGFloat height = 239*kScale;
    CGFloat y = (kScreenH - height)/2.f;
    _sendView = [[EMView alloc] initWithFrame:Rect(15*kScale, y, kScreenW-30*kScale, height)];
    _sendView.layer.backgroundColor = RGB(0xff, 0xff, 0xff).CGColor;
    _sendView.layer.cornerRadius = 10;
    [_maskBtnView addSubview:_sendView];
    _sendView.hidden = YES;
    CGFloat width = 100;
    height = 100;
    CGFloat x = (kScreenW - width)/2.f;
    y = 52*kScale;
    UIImageView *giftImgView = [[UIImageView alloc] initWithFrame:Rect(x, y, width, height)];
    giftImgView.image = [UIImage imageNamed:@"answerGift"];
    giftImgView.tag = 100;
    [_sendView addSubview:giftImgView];
    
    EMLabel *giftLabel = [[EMLabel alloc] initWithFrame:Rect(60*kScale, PositionY(giftImgView)+6*kScale, kScreenW-120*kScale, 17*kScale)];
    giftLabel.font = ComFont(16*kScale);
    giftLabel.textColor = RGB(239,162,249);
    giftLabel.tag = 101;
    giftLabel.textAlignment = NSTextAlignmentCenter;
    [_sendView addSubview:giftLabel];
    
    width = 92*kScale;
    height = 35*kScale;
    x = (kScreenW - width)/2.f;
    y = PositionY(giftLabel)+ 25*kScale;
    EMButton *sendBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height) andConners:5];
    sendBtn.borderColor = RGB(0,0,0);
    sendBtn.borderWidth = 1;
    [sendBtn setTitle:Local(@"SendMin") forState:UIControlStateNormal];
    [sendBtn setTitleColor:RGB(0xff,0xff,0xff) forState:UIControlStateNormal];
    [sendBtn setBackgroundColor:RGB(145,90,173)];
    sendBtn.tag = 102;
    [sendBtn addTarget:self action:@selector(sendGift:) forControlEvents:UIControlEventTouchUpInside];
    [_sendView addSubview:sendBtn];
    
    EMButton *closeBtn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 40*kScale - 20, 6*kScale, 25*kScale, 25*kScale)];

    [closeBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"close_d"] forState:UIControlStateHighlighted];
    [closeBtn addTarget:self action:@selector(hiddenMask:) forControlEvents:UIControlEventTouchUpInside];
    [_sendView addSubview:closeBtn];
    
}

- (void)maskViewBtnTap:(UIButton*)btn {
    [self hiddenMask];
}



- (void)sendGift:(EMButton*)btn {
    //判断是不是加值
    [self hiddenMask:nil];
    if ([btn.titleLabel.text isEqualToString:Local(@"AddMoney")]) {
        AddMoneyMainVC *addMoney = [[AddMoneyMainVC alloc] init];
        [(UINavigationController*)[[(AppDelegate*)[[UIApplication sharedApplication] delegate] window] rootViewController] pushViewController:addMoney animated:YES];
    }else{
        NSString *emoji = [NSString stringWithFormat:@"%@##%d",_sendGiftText,_sendGiftSec];
        NSString *notifiString = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiGifNoti formateWihtIndentifier:_panelIdentifier];
        MJNotificationPostObj(notifiString, emoji, nil);
    }
}

//隐藏送礼
- (void)hiddenMask:(EMButton*)btn {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 0;
        _maskBtnView.hidden = YES;
        CGRect frame = _maskBtnView.frame;
        _sendView.frame = Rect(frame.size.width/2, frame.size.height/2, 0, 0);
        _sendView.hidden = YES;
    } completion:NULL];
}


- (void)maskTap:(UIButton *)btn {
    NSLog(@"aaa===");
    [self hiddenMask];
    //显示送礼
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _maskBtnView.alpha = 1;
        _maskBtnView.hidden = NO;
        CGFloat height = 239*kScale;
        if (Is320) {
            height = 239;
        }
        CGFloat y = (kScreenH - height)/2.f;
        _sendView.frame = Rect(15, y, kScreenW-30, height);
        _sendView.hidden = NO;
        UIImageView *imgView = [_sendView viewWithTag:100];
        imgView.image = [UIImage imageNamed:btn.titleLabel.text];
        UILabel *label = [_sendView viewWithTag:101];
        //需要送出的秒数
        int sec = 0;
        if (btn.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 4) {
            label.text = Local(@"Send3MinYouHeart");
            sec = 60*3;
        }else if (btn.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 8) {
            label.text = Local(@"Send5MinYouHeart");
            sec = 60*5;
        }else if (btn.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 12){
            label.text = Local(@"Send10MinYouHeart");
            sec = 60*10;
        }else if (btn.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 14){
            label.text = Local(@"Send20MinYouHeart");
            sec = 60*20;
        }else {
            label.text = Local(@"Send50MinYouHeart");
            sec = 60*50;
        }
        //判断够不够时间
        LonelyUser *user = [ViewModelCommom getCuttentUser];
        UIButton *sendBtn = [_sendView viewWithTag:102];

        if ([user.chat_point intValue] < sec) {
            //时间不够
            [sendBtn setTitle:Local(@"AddMoney") forState:UIControlStateNormal];
            label.text = Local(@"AddMoneyQuick");
            _sendGiftSec = 0;
        }else {
            _sendGiftSec = sec;
            _sendGiftText = btn.titleLabel.text;
            [sendBtn setTitle:Local(@"SendMin") forState:UIControlStateNormal];
        }
        
        
    } completion:NULL];
}


- (void)tapOnEmojiButton:(UIButton *)tapR
{
    _maskBtn.center = tapR.center;
    _maskBtn.titleLabel.text = tapR.titleLabel.text;
    _maskBtn.tag = tapR.tag;
    [_maskBtn setImage:[UIImage imageNamed:tapR.titleLabel.text] forState:UIControlStateNormal];
    _maskViewBtn.hidden = NO;
    _maskBtn.hidden = NO;
    _maskLabel.hidden = NO;
    if (tapR.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 4) {
        _maskLabel.text = Local(@"Send3MinGift");
    }else if (tapR.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 8) {
        _maskLabel.text = Local(@"Send5MinGift");
    }else if (tapR.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 12) {
        _maskLabel.text = Local(@"Send10MinGift");
    }else if (tapR.tag - GJGCChatInputExpandEmojiPanelPageItemSubIconTag < 14) {
        _maskLabel.text = Local(@"Send20MinGift");
    }else  {
        _maskLabel.text = Local(@"Send50MinGift");
    }
}


- (void)hiddenMask {
    _maskViewBtn.hidden = YES;
    _maskBtn.hidden = YES;
    _maskLabel.hidden = YES;

}


- (void)dealloc {
    [self hiddenMask];
}




@end
