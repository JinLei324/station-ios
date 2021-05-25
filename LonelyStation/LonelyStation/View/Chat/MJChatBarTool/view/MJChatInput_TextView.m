//
//  MJChatInput_TextView.m
//  MJChatBarTool
//
//  Created by linhua hu on 16/10/8.
//  Copyright © 2016年 linhua hu. All rights reserved.
//

#import "MJChatInput_TextView.h"
#import "MJChatAudioRecordModel.h"
#import "MJChatInputRecordAudioTipView.h"
#import "MJChatBarNotificationCenter.h"


#define kTextInsetX 2
#define MAX_TextHeight 73

@interface MJChatInput_TextView ()<UITextViewDelegate,MJAudioDelegate>
{
    UIImageView *inputBackgroundImageView;
    UITextView *inputTextView;
    UIButton   *recordButton;
    
    CGRect origin_frame;
    NSString *textViewTempString;
    
    
    /**
     *  录音提示视图
     */
    MJChatInputRecordAudioTipView *recordTipView;
    
}

@end

@implementation MJChatInput_TextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initParam];
        [self initSubviewsWithFrame:frame];
    }
    return self;
}

- (MJChatAudioRecord*)audioRecord
{
    if (!_audioRecord) {
        _audioRecord = [[MJChatAudioRecord alloc]init];
        _audioRecord.limitRecordDuration = 60.0f;
        _audioRecord.minEffectDuration = 3.f;
        _audioRecord.mouterDelegate = self;
        
    }
    return _audioRecord;
}

- (void)initParam//初始化参数
{
    _recordState = NO;
}

- (void)setIndentifiName:(NSString *)indentifiName
{
    _indentifiName = indentifiName;
    NSString *simbleEmojiNoti = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiSambleNoti formateWihtIndentifier:indentifiName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeEmojiPanelChooseEmojiNoti:) name:simbleEmojiNoti object:nil];
    
    NSString *emojiSendNoti = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiSendfNoti formateWihtIndentifier:indentifiName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observeEmojiPanelChooseEmojiNoti:) name:emojiSendNoti object:nil];
}


- (void)didUpDateMouter:(CGFloat)mouter {
    if (recordTipView) {
        recordTipView.soundMeter = mouter;
    }
}


- (void)deleteLastEmoji
{
    if ([MJChatBarToolModel stringIsNull:inputTextView.text]) {
        return ;
    }
    if ([[inputTextView.text substringFromIndex:inputTextView.text.length-1] isEqualToString:@"]"]) {
        
        NSInteger lastCharCursor = inputTextView.text.length - 1;
        
        NSInteger innerCharCount = 0;
        while (lastCharCursor >= 0) {
            
            NSString * lastChar = [inputTextView.text substringWithRange:NSMakeRange(lastCharCursor, 1)];
            
            if ([lastChar isEqualToString:@"["]) {
                break;
            }
            lastCharCursor--;
            innerCharCount ++;
        }
        
        if (innerCharCount > 4) {
            [inputTextView deleteBackward];//删除系统键盘表情
            return;
        }
        inputTextView.text = [inputTextView.text substringToIndex:lastCharCursor];
    }
    else
    {
        [inputTextView deleteBackward];
    }
}

- (void)observeEmojiPanelChooseEmojiNoti:(NSNotification *)noti
{
    NSString *emoji = noti.object;
    if ([emoji isEqualToString:@"删除"]) {
        [self deleteLastEmoji];
    }else if ([emoji isEqualToString:@"MJ_发送"])
    {
        [self senMsg];
    }
    else
    {
       inputTextView.text = [NSString stringWithFormat:@"%@%@",inputTextView.text,emoji];
    }
    
    [self updateTextView:inputTextView];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSubviewsWithFrame:(CGRect)frame
{
    CGRect backgroundFrame = self.bounds;
    inputBackgroundImageView = [[UIImageView alloc] initWithFrame:backgroundFrame];
    [self addSubview:inputBackgroundImageView];
    
    recordButton = [[UIButton alloc] initWithFrame:backgroundFrame];
    [self addSubview:recordButton];
    recordButton.hidden = YES;
    [recordButton setTitleColor:[MJChatBarToolModel colorFromHexString:@"484848"] forState:UIControlStateNormal];
    [recordButton setTitleColor:[MJChatBarToolModel colorFromHexString:@"484848"] forState:UIControlStateHighlighted];
    
//    UILongPressGestureRecognizer *longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecord:)];
//    [recordButton addGestureRecognizer:longPressGes];
//    longPressGes.cancelsTouchesInView = NO;
    
    [recordButton addTarget:self action:@selector(recordStart) forControlEvents:UIControlEventTouchDown];
    // Set record end action for UIControlEventTouchUpInside
    [recordButton addTarget:self action:@selector(recordEnd) forControlEvents:UIControlEventTouchUpInside];
    // Set record cancel action for UIControlEventTouchUpOutside
    [recordButton addTarget:self action:@selector(recordCancel) forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    
    [recordButton addTarget:self action:@selector(showCancel) forControlEvents:UIControlEventTouchDragOutside];
    [recordButton addTarget:self action:@selector(hideCancel) forControlEvents:UIControlEventTouchDragExit];
    
    
    _autoExpandHeight = frame.size.height;
    CGRect textViewFrame = CGRectInset(backgroundFrame, kTextInsetX, kTextInsetX);
    textViewFrame.size.height = self.frame.size.height - 2*kTextInsetX;
    
    inputTextView = [[UITextView alloc] initWithFrame:textViewFrame];
    inputTextView.delegate        = self;
    inputTextView.font            = [UIFont systemFontOfSize:15.f];
    inputTextView.contentInset    = UIEdgeInsetsMake(-4,0,-4,0);
    inputTextView.showsHorizontalScrollIndicator = NO;
    inputTextView.returnKeyType = UIReturnKeySend;
    inputTextView.enablesReturnKeyAutomatically = YES;
    [self addSubview:inputTextView];
}

- (void)showCancel {
//    NSLog(@"showCancel");
    recordTipView.willCancel = YES;
}

- (void)hideCancel {
//    NSLog(@"hideCancel");
}


- (void)recordStart {
    [self showRecordTipView];
    [self.audioRecord startRecord];
}


- (void)recordEnd {
    [self removeRecordTipView];
    [self.audioRecord finshishRecord];
    MJChatAudioRecordModel *audioModel = [self.audioRecord getRecordAudioFile];
    [self sendVedio:audioModel];
}


- (void)recordCancel {
    [self removeRecordTipView];
    [self.audioRecord cancleRecord];
    NSLog(@"cancel");
}


- (void)sendVedio:(MJChatAudioRecordModel*)model
{
    
    NSString *notifiString = [MJChatBarNotificationCenter getNofitName:MJChatBarRecordSoundNoti formateWihtIndentifier:self.indentifiName];
    MJNotificationPostObj(notifiString, model, nil);
}

#pragma mark - 录音按钮触摸检测
- (void)showRecordTipView
{
    [self removeRecordTipView];
    recordTipView = [[MJChatInputRecordAudioTipView alloc]init];
    [[[UIApplication sharedApplication]keyWindow] addSubview:recordTipView];
}

- (void)removeRecordTipView
{
    if (recordTipView.isTooShortRecordDuration) {
        [UIView animateWithDuration:0.5 animations:^{
            if (recordTipView) {
                [recordTipView removeFromSuperview];
                recordTipView = nil;
            }
        }];
        return;
    }
    
    if (recordTipView) {
        [recordTipView removeFromSuperview];
        recordTipView = nil;
    }
    
}

- (void)changeRecordState:(MJChatRecordState)state
{
    if ([self.delegate respondsToSelector:@selector(recordActionCallBack:)]) {
        [self.delegate recordActionCallBack:state];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    _recordState = NO;
    if ([self.delegate respondsToSelector:@selector(chatInputStyle:)]) {
        [self.delegate chatInputStyle:_recordState];
    }
    return YES;
}

- (void)setInputBackgroundImage:(UIImage *)inputBackgroundImage
{
    inputBackgroundImageView.image = [inputBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch];
}

- (void)setRecordAudioBackgroundImage:(UIImage *)recordAudioBackgroundImage
{
    [recordButton setBackgroundImage:[recordAudioBackgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2) resizingMode:UIImageResizingModeStretch] forState:normal];
}

- (void)setPreRecordTitle:(NSString *)preRecordTitle
{
    [recordButton setTitle:preRecordTitle forState:UIControlStateNormal];
}

- (void)setRecordingTitle:(NSString *)recordingTitle
{
    [recordButton setTitle:recordingTitle forState:UIControlStateHighlighted];
}

- (void)becomFirstResponderInput{
    [inputTextView becomeFirstResponder];
}


- (void)resignInputTextView
{
    [inputTextView resignFirstResponder];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 400) {
        textView.text = [textView.text substringToIndex:400];
    }
    [self updateTextView:textView];
}

- (void)updateTextView:(UITextView *)textView
{
    CGFloat h = [self heightForString:textView andWidth:textView.contentSize.width];
    if (_autoExpandHeight == h-2) {
        return;
    }else
    {
        _autoExpandHeight = h-4;
        CGRect newTextFrame = textView.frame;
        newTextFrame.size.height = h-4;
        textView.frame = newTextFrame;
        inputBackgroundImageView.frame = newTextFrame;
        
        CGRect newTextFrame2 = self.frame;
        newTextFrame2.size.height = h - 4;
        self.frame = newTextFrame2;
        if ([self.delegate respondsToSelector:@selector(changeHeight:)]) {
            [self.delegate changeHeight:_autoExpandHeight];
        }
        if (h == 50) {
            textView.contentOffset = CGPointMake(0, 0);
        }
    }
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([MJChatBarToolModel stringIsAllWhiteSpace:textView.text]) {
            return NO;
        }else
        {
            [self senMsg];
            return NO;
        }
        
    }
    return YES;
}

- (void)senMsg
{
    NSString *notifiStr = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiTextfNoti formateWihtIndentifier:_indentifiName];
    MJNotificationPostObj(notifiStr, inputTextView.text, nil);
    textViewTempString = nil;
    inputTextView.text = nil;
    [self updateTextView:inputTextView];
}

- (void)hiddenRecordButton
{
    recordButton.hidden = YES;
    inputTextView.hidden = NO;

}
- (void)setRecordState:(BOOL)recordState
{
    _recordState = recordState;
    if (_recordState) {
        textViewTempString = inputTextView.text;
        inputTextView.text = nil;
        [self updateTextView:inputTextView];
        [inputTextView resignFirstResponder];
        inputTextView.hidden = YES;
        recordButton.hidden = NO;
    }else
    {
        if (textViewTempString) {
            inputTextView.text = textViewTempString;
        }
        
        [self updateTextView:inputTextView];
        [inputTextView becomeFirstResponder];
        inputTextView.hidden = NO;
        recordButton.hidden = YES;
    }
}

- (CGFloat) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height<MAX_TextHeight ? sizeToFit.height : MAX_TextHeight;
}

@end
