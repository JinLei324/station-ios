//
//  MJChatBarToolView.m
//  MJChatBarTool
//
//  Created by linhua hu on 16/10/8.
//  Copyright © 2016年 linhua hu. All rights reserved.
//

#import "MJChatBarToolView.h"
#import "MJChatEmojiView.h"
#import "MJChatBarNotificationCenter.h"
#import "VoiceObj.h"
#import "DouAudioPlayer.h"
#import "UIUtil.h"
#import <AVFoundation/AVFoundation.h>

#import <AFNetworking.h>
#import "MJChatInputItem.h"
#import "ExtAudioConverter.h"

@interface MJChatBarToolView ()<MJChatBarInputViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)MJChatBarInputView *inputBar;
@property (nonatomic ,assign)CGFloat keyBoardHeight;
@property (nonatomic ,assign)CGFloat explangHeight;
@property (nonatomic,strong)MJChatEmojiView *emojiView;
@property (nonatomic,strong)UIButton *testBtn;
@property (nonatomic,strong)DouAudioPlayer *douAudioPlayer;

@property (nonatomic,strong)EMButton *currentBtn;

@property (nonatomic,strong)UIButton *photoBtn;
@property (nonatomic,strong)UIButton *giftBtn;
@property (nonatomic,strong)UIButton *voiceBtn;

@property (nonatomic,strong)UITableView *fileTableView;




@end

@implementation MJChatBarToolView

- (void)changeAudioType {
    [_inputBar.recordAudioBarItem sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)changeCallImage:(BOOL)ret {
    if (ret) {
        _inputBar.callBarItem.selectImage = [UIImage imageNamed:@"chat_phone_pay"];
        _inputBar.callBarItem.unSelectImage = [UIImage imageNamed:@"chat_phone_pay"];

        [_inputBar.callBarItem setImage:[UIImage imageNamed:@"chat_phone_pay"] forState:UIControlStateNormal];
    }else {
        [_inputBar.callBarItem setImage:[UIImage imageNamed:@"chat_phone"] forState:UIControlStateNormal];
        _inputBar.callBarItem.selectImage = [UIImage imageNamed:@"chat_phone"];
    }
}


-(id)init
{
    self = [super init];
    if (self) {
        
        _inputBar = [[MJChatBarInputView alloc]initWithFrame:(CGRect){0,0,GJCFSystemScreenWidth,inputBarHeight}];
        _inputBar.delegate = self;
        [self addSubview:self.inputBar];
        [self regestObserver];//注册相关通知
        _douAudioPlayer = [[DouAudioPlayer alloc] init];
        _indentifiName = [MJChatBarToolModel currentTimeStamp];
        _inputBar.indentifiName = _indentifiName;
        
//        _testBtn= [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 20, 20)];
//        _testBtn.backgroundColor = [UIColor redColor];
//        [self addSubview:_testBtn];
//        [_testBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *backView = [[UIView alloc] initWithFrame:Rect(0, 50, kScreenW, EMOJIHEIGHT)];
        backView.backgroundColor = RGB(242, 242, 242);
        [self addSubview:backView];
        
        CGFloat y = 50;
        CGFloat width = 40;
        CGFloat distance = (kScreenW - 2*width)/3.f;
        //照片
        _photoBtn = [[UIButton alloc] initWithFrame:Rect(distance, y, width, width)];
        [_photoBtn setImage:[UIImage imageNamed:@"chat_camera"] forState:UIControlStateNormal];
        [self addSubview:_photoBtn];
        [_photoBtn addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
        //礼物
        _giftBtn =  [[UIButton alloc] initWithFrame:Rect(PositionX(_photoBtn)+distance, y, width, width)];
        [_giftBtn setImage:[UIImage imageNamed:@"chat_gift"] forState:UIControlStateNormal];
        [self addSubview:_giftBtn];
        [_giftBtn addTarget:self action:@selector(giftAction:) forControlEvents:UIControlEventTouchUpInside];
        
//        //罐头音
//        _voiceBtn =  [[UIButton alloc] initWithFrame:Rect(PositionX(_giftBtn)+distance, y, width, width)];
//        [_voiceBtn setImage:[UIImage imageNamed:@"chat_cans"] forState:UIControlStateNormal];
//        [self addSubview:_voiceBtn];
//        [_voiceBtn addTarget:self action:@selector(canAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //音档tableView;
        _fileTableView = [[UITableView alloc] initWithFrame:Rect(0, PositionY(_voiceBtn), kScreenW, 40) style:UITableViewStylePlain];
        _fileTableView.delegate = self;
        _fileTableView.dataSource = self;
//        [self addSubview:_fileTableView];
        self.backgroundColor = RGB(145,90,173);
        [self addObserverGifNoti];
        [self addObserverRecord];
        [self addObserverTextNoti];
        
    }
    return self;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
        EMButton *btn = [[EMButton alloc] initWithFrame:Rect(kScreenW - 50, 0, 50, 40)];
        [btn setTitle:Local(@"TryListen") forState:UIControlStateNormal];
        btn.tag = 100;
        [btn setTitle:Local(@"Playing") forState:UIControlStateSelected];
        [btn setTitleColor:RGB(47,47,47) forState:UIControlStateNormal];
        [btn setTitleColor:RGB(64,0,88) forState:UIControlStateSelected];
        btn.titleLabel.font = ComFont(13);
        [btn addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn];
        
    }
    EMButton *btn = [cell.contentView viewWithTag:100];
    btn.tableTag = indexPath.row;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@%d",Local(@"ChatDocument"),(int)indexPath.row+1];
    cell.textLabel.textColor = RGB(47,47,47);
    cell.textLabel.font = ComFont(13);
    return cell;
}


- (void)playAudio:(EMButton*)btn {
    NSInteger btnTag = btn.tableTag;
    VoiceObj *voice = _fileArray[btnTag];
    if (voice) {
        if (_currentBtn != btn) {
            if (!_currentBtn) {
                _currentBtn = btn;
            }else{
                _currentBtn.selected = NO;
            }
            btn.selected = !btn.selected;
            _currentBtn = btn;
        }else{
            _currentBtn = nil;
            btn.selected = !btn.selected;
        }
        if (btn.selected) {
            [_douAudioPlayer startPlayTime:0 andURL:voice.voiceURL];
        }else {
            if (_douAudioPlayer.isPlayFinish) {
                btn.selected = YES;
                [_douAudioPlayer startPlayTime:_douAudioPlayer.currentValue andURL:voice.voiceURL];
            }else {
                [_douAudioPlayer pause];
            }
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_fileArray) {
        return _fileArray.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //缓存音档，然后把音档发出去，修改成afnetwork的方式
    
    VoiceObj *voice = _fileArray[indexPath.row];
    [UIUtil showHUD:self.superview];
    NSURL *url = [NSURL URLWithString:voice.voiceURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData *data = (NSData*)responseObject;
        //保存到沙盒
        NSString *path_sandox = NSHomeDirectory();
        NSString *newPath = [path_sandox stringByAppendingPathComponent:[NSString stringWithFormat:@"/Documents/%@",voice.voiceURL.lastPathComponent]];
        [data writeToFile:newPath atomically:YES];
        //转换mp3成wav
        ExtAudioConverter* converter = [[ExtAudioConverter alloc] init];
        //converter.inputFile =  @"/Users/lixing/Desktop/playAndRecord.caf";
        converter.inputFile =  newPath;
        //output file extension is for your convenience
        
        NSString *newOutPutPath = [newPath stringByReplacingOccurrencesOfString:@"mp3" withString:@"wav"];;
        converter.outputFile = newOutPutPath;
        //TODO:some option combinations are not valid.
        //Check them out
        converter.outputSampleRate = 8000;
        converter.outputNumberChannels = 1;
        converter.outputBitDepth = BitDepth_16;
        converter.outputFormatID = kAudioFormatLinearPCM;
        converter.outputFileType = kAudioFileWAVEType;
        [converter convert];
        
        [self.delegate needSendCan:newOutPutPath andDuration:[voice.duration floatValue]];
        
    }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          [UIUtil hideHUD:self.superview];
                                          [self.superview.window makeToast:Local(@"FailedAndPlsRetry") duration:ERRORTime position:[CSToastManager defaultPosition]];
                                          
                                      }];
    [operation start];

    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:voice.voiceURL]];
//        AVURLAsset* audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:voice.voiceURL] options:nil];
//        CMTime audioDuration = audioAsset.duration;
//        float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
//        [self.delegate needSendCan:data andLength:audioDurationSeconds];
//    });
    

}



- (void)giftAction:(UIButton*)sender {
    NSLog(@"btnClick");
    sender.selected = !sender.selected;
    _voiceBtn.selected = NO;
    [_inputBar changeToShowEmoj:(UIButton*)sender];
}


- (void)setFileArray:(NSArray *)fileArray {
    _fileArray = fileArray;
    [self setCanNum:(int)_fileArray.count];
}


- (void)photoAction:(UIButton*)sender {
    [self.delegate photoAction];
}


- (void)canAction:(UIButton*)sender {
    if (_canNum == 0){
        [self.superview.window makeToast:Local(@"YouNeverRecordIntroduce") duration:ERRORTime position:[CSToastManager defaultPosition]];
        return;
    }
    sender.selected = !sender.selected;
    _giftBtn.selected = NO;
    [_inputBar changeToShowCan:_canNum andSender:sender];
}

- (void)setCallEnable:(BOOL)ret {
    [(UIButton*)_inputBar.callBarItem setEnabled:ret];
}

//gif表情通知
- (void)addObserverGifNoti
{
    NSString *gifEmojiNoti = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiGifNoti formateWihtIndentifier:_indentifiName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeGIFEmojiPanelChooseEmojiNoti:) name:gifEmojiNoti object:nil];
}

//语音通知
- (void)addObserverRecord
{
    NSString *recodNoti = [MJChatBarNotificationCenter getNofitName:MJChatBarRecordSoundNoti formateWihtIndentifier:_indentifiName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerRecordNotif:) name:recodNoti object:nil];
}

//文本通知
- (void)addObserverTextNoti
{
    NSString *recodNoti = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiTextfNoti formateWihtIndentifier:_indentifiName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observerTextNoti:) name:recodNoti object:nil];
}

- (void)observerTextNoti:(NSNotification *)noti
{
    NSString *strtt = noti.object;
    NSLog(@"文本通知->  %@",strtt);
    if ([self.delegate respondsToSelector:@selector(msgType:msgBody:)]) {
        [self.delegate msgType:MJChatBarMsgType_Text msgBody:strtt];
    }
}

- (void)observeGIFEmojiPanelChooseEmojiNoti:(NSNotification *)noti
{
    NSString *strtt = noti.object;
    if ([self.delegate respondsToSelector:@selector(msgType:msgBody:)]) {
        [self.delegate msgType:MJChatBarMsgType_GIFEmoji msgBody:strtt];
    }
}

- (void)observerRecordNotif:(NSNotification *)notif
{
    MJChatAudioRecordModel *model = notif.object;
    if ([self.delegate respondsToSelector:@selector(msgType:msgBody:)]) {
        [self.delegate msgType:MJChatBarMsgType_Audio msgBody:model];        
    }
}

- (MJChatEmojiView*)emojiView
{
    if (!_emojiView) {
        _emojiView = [[MJChatEmojiView alloc] initWithFrame:CGRectMake(0, 40, GJCFSystemScreenWidth, EMOJIHEIGHT)];
        _emojiView.hidden = YES;
        _emojiView.indentifiName = _indentifiName;
        [self addSubview:_emojiView];
        
    }
    _emojiView.frame = CGRectMake(0, _inputBar.barHeight+40, GJCFSystemScreenWidth, EMOJIHEIGHT-40);
    return _emojiView;
}

- (void)chatBarFrameChage
{
    [UIView animateWithDuration:0.2f animations:^{
        [self layerBarFrame];
    }];
    
}

- (void)chatCall {
    if (_delegate && [_delegate respondsToSelector:@selector(chatCallUser)]) {
        [self.delegate chatCallUser];
    }
}

- (void)setCanNum:(int)num {
    _canNum = num;
    _fileTableView.frame = Rect(0, PositionY(_voiceBtn), kScreenW, 40*_canNum);
    [_fileTableView reloadData];
    
}


- (void)changeActionType:(MJChatBarActionType)type
{
    [UIView animateWithDuration:0.2f animations:^{
        [self layerBarFrame];
        if (type == MJChatInputBarActionType_Emoji) {
            self.emojiView.hidden = NO;
//            self.photoBtn.hidden = YES;
//            self.giftBtn.hidden = YES;
//            self.voiceBtn.hidden = YES;
            self.fileTableView.hidden = YES;
        }else{
            self.emojiView.hidden = YES;
            self.photoBtn.hidden = YES;
            self.giftBtn.hidden = YES;
            self.voiceBtn.hidden = YES;
            if (type == MJChatBarMsgType_Panel) {
                _voiceBtn.selected = NO;
                _giftBtn.selected = NO;
                self.photoBtn.hidden = NO;
                self.giftBtn.hidden = NO;
                self.voiceBtn.hidden = NO;
                self.fileTableView.hidden = YES;
            }else if(type == MJChatInputBarActionType_Can) {
                self.photoBtn.hidden = NO;
                self.giftBtn.hidden = NO;
                self.voiceBtn.hidden = NO;
                self.fileTableView.hidden = NO;
            }
        }
    }];

}

- (void)layerBarFrame
{
    CGFloat ori_x = 0;
    if (_keyBoardHeight > 0 && _explangHeight>0) {
        _keyBoardHeight = 0;
    }
    switch (_inputBar.actionType) {
        case MJChatInputBarActionType_None:
            _keyBoardHeight = 0;
            _explangHeight = 0;
            break;
            
        case MJChatInputBarActionType_Audio:
            _keyBoardHeight = 0;
            _explangHeight = 0;
            break;
            
        case MJChatInputBarActionType_Emoji:
            _keyBoardHeight = 0;
            _explangHeight = EMOJIHEIGHT;
            break;
            
        case MJChatInputBarActionType_Text:
            _explangHeight = 0;
            break;
            
        case MJChatInputBarActionType_Panel:
            _keyBoardHeight = 0;
            _explangHeight = 40;
            break;
        case MJChatInputBarActionType_Can:
            _keyBoardHeight = 0;
            _explangHeight = 40 + 40*self.canNum;
            break;
        default:
            break;
    }
    
    CGFloat ori_y = GJCFSystemScreenHeight - self.barToolHeight + EMOJIHEIGHT - _keyBoardHeight -_explangHeight;
    CGFloat size_w = GJCFSystemScreenWidth;
    CGFloat size_h = GJCFSystemScreenHeight-ori_y;
    CGRect newFrame = (CGRect){ori_x,ori_y,size_w,size_h};
    self.frame = newFrame;
    
    CGRect barFrame = _inputBar.frame;
    barFrame.size.height = _inputBar.barHeight;
    _inputBar.frame = barFrame;
    
    
    if ([self.delegate respondsToSelector:@selector(chatBarToolViewChangeFrame:)]) {
        [self.delegate chatBarToolViewChangeFrame:newFrame];
    }
}


- (void)UIKeyboardWillShow:(NSNotification *)noti
{
    CGRect keyboardEndFrame = [noti.userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    _keyBoardHeight = keyboardEndFrame.size.height;
    [_inputBar.inputTextView becomFirstResponderInput];
    [self layerBarFrame];
}

- (void)UIKeyboardWillHidden:(NSNotification *)noti
{
    _keyBoardHeight = 0;
    [self layerBarFrame];
}

- (void)dealloc
{
    [_douAudioPlayer stop];
    [self removeAllObserver];
}

- (void)regestObserver//注册通知
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UIKeyboardWillHidden:) name:UIKeyboardWillHideNotification object:nil];//监视键盘尺寸
}

- (void)removeAllObserver//移除所有通知
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (CGFloat)barToolHeight
{
    return _inputBar.barHeight + EMOJIHEIGHT;
}

- (void)cancleInputState
{
    [_inputBar cancleInputState];
}

@end
