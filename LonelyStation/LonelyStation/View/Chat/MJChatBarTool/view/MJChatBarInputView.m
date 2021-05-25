//
//  MJChatBarInputView.m
//  MJChatBarTool
//
//  Created by linhua hu on 16/10/8.
//  Copyright © 2016年 linhua hu. All rights reserved.
//

#import "MJChatBarInputView.h"
#import "MJChatInputItem.h"

#define RGB(r, g, b)                        [UIColor colorWithRed:(r)/255.f green:(g)/255.f blue:(b)/255.f alpha:1.f]




@interface MJChatBarInputView ()<MJChatInput_TextViewDelegate>


@property (nonatomic,strong)MJChatInputItem *openPanelBarItem;




@end

@implementation MJChatBarInputView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _barHeight = inputBarHeight;
        _actionType = MJChatInputBarActionType_None;
        [self initLineWith:frame];//初始化分割线
        [self initSubItemView:frame];//初始化录音按钮、聊天框、表情按钮、扩展按钮
        
    }
    return self;
}







/**
 * 初始化分割线
 */
- (void)initLineWith:(CGRect)frame
{
    self.backgroundColor = RGB(145,90,173);
}

- (void)setIndentifiName:(NSString *)indentifiName
{
    _indentifiName = indentifiName;
    _inputTextView.indentifiName = _indentifiName;
    
}

/**
 * 初始化视图元素
 */
- (void)initSubItemView:(CGRect)frame
{
    CGFloat itemMargin = 5.f;
    CGFloat itemToBarMargin = 10.f;
    
    _recordAudioBarItem = [[MJChatInputItem alloc] initWithSelectedIcon:[UIImage imageNamed:@"chat_mic"]];
    [self addSubview:_recordAudioBarItem];
    //打电话的
    _callBarItem = [[MJChatInputItem alloc] initWithSelectedIcon:[UIImage imageNamed:@"chat_phone"]];
    _callBarItem.selectImage = [UIImage imageNamed:@"chat_phone"];
    [_callBarItem setImage:[UIImage imageNamed:@"chat_phone_off"] forState:UIControlStateDisabled];
    
    _openPanelBarItem = [[MJChatInputItem alloc] initWithSelectedIcon:[UIImage imageNamed:@"chat_add"]];
    _openPanelBarItem.selectImage = [UIImage imageNamed:@"chat_add"];
    //这是打电话的按钮
    _callBarItem.frame = CGRectMake(itemToBarMargin, 8,35, 35);
    CGFloat ox = _callBarItem.frame.origin.x + _callBarItem.frame.size.width;
    _openPanelBarItem.frame = CGRectMake(ox + itemMargin, 8,35, 35);
    _inputTextView = [[MJChatInput_TextView alloc] initWithFrame:CGRectMake(ox + 35 + 2*itemMargin, 8, GJCFSystemScreenWidth - 35 * 3 - 2*itemToBarMargin - itemMargin * 3, 32)];
    CGFloat openItm_ox = GJCFSystemScreenWidth - 35 -itemToBarMargin;
    _recordAudioBarItem.frame = CGRectMake(openItm_ox, 8,35, 35);
    
    
    [_inputTextView setRecordAudioBackgroundImage:[UIImage imageNamed:@"输入框-灰色"]];
    [_inputTextView setPreRecordTitle:Local(@"HoldSpeak")];
    [_inputTextView setRecordingTitle:Local(@"ReleaseSend")];
    _inputTextView.delegate = self;
    [self addSubview:_inputTextView];
    
    
    
    
    
    [self addSubview:_callBarItem];
    [self addSubview:_openPanelBarItem];
    
    [_callBarItem addTarget:self action:@selector(itemChangeStatus:) forControlEvents:UIControlEventTouchUpInside];
    [_openPanelBarItem addTarget:self action:@selector(itemChangeStatus:) forControlEvents:UIControlEventTouchUpInside];
    [_recordAudioBarItem addTarget:self action:@selector(itemChangeStatus:) forControlEvents:UIControlEventTouchUpInside];    
}


- (void)chatInputStyle:(BOOL)isRecordState
{
    if (isRecordState) {
        [self setCurrentActionType:MJChatInputBarActionType_Audio];
    }else
    {
        _openPanelBarItem.itemIsSelect = NO;
        [self setCurrentActionType:MJChatInputBarActionType_Text];
    }
}

- (void)recordActionCallBack:(MJChatRecordState)recordState
{
    
}


- (void)changeHeight:(CGFloat)changeH
{
    CGFloat temH = inputBarHeight - 36.f;
    _barHeight = changeH + temH;
    if ([self.delegate respondsToSelector:@selector(chatBarFrameChage)]) {
        [self.delegate chatBarFrameChage];
    }
}

-(CGFloat)barHeight
{
    if (_barHeight < inputBarHeight) {
        return inputBarHeight;
    }else
    {
        return _barHeight;
    }
}

- (void)changeToShowEmoj:(UIButton*)btn {
    if (btn.selected) {
        _recordAudioBarItem.itemIsSelect = NO;
        _openPanelBarItem.itemIsSelect = NO;
        [self setCurrentActionType:MJChatInputBarActionType_Emoji];
    }else{
        _recordAudioBarItem.itemIsSelect = NO;
        _openPanelBarItem.itemIsSelect = YES;
        [self setCurrentActionType:MJChatInputBarActionType_Panel];
    }
    if (_inputTextView.recordState == YES) {
        [_inputTextView hiddenRecordButton];
    }
    [_inputTextView resignInputTextView];
}


- (void)changeToShowCan:(int)canNum andSender:(UIButton*)sender{
    _recordAudioBarItem.itemIsSelect = NO;
    if (sender.selected) {
        _openPanelBarItem.itemIsSelect = NO;
        [self.delegate setCanNum:canNum];
        [self setCurrentActionType:MJChatInputBarActionType_Can];
    }else {
        [self.delegate setCanNum:0];
        _openPanelBarItem.itemIsSelect = YES;
        [self setCurrentActionType:MJChatInputBarActionType_Panel];
    }
    if (_inputTextView.recordState == YES) {
        [_inputTextView hiddenRecordButton];
    }
    [_inputTextView resignInputTextView];
}


- (void)itemChangeStatus:(MJChatInputItem *)item
{
    item.itemIsSelect = !item.itemIsSelect;
    if (item == _recordAudioBarItem) {
        _callBarItem.itemIsSelect = NO;
        _openPanelBarItem.itemIsSelect = NO;
        if (item.itemIsSelect) {
            [self setCurrentActionType:MJChatInputBarActionType_Audio];
            _inputTextView.recordState = YES;
        }else
        {
            [self setCurrentActionType:MJChatInputBarActionType_Text];
            _inputTextView.recordState = NO;
        }
    }
    else if (item == _callBarItem)
    {
        //拨打电话
        [self.delegate chatCall];
    }
    else if (item == _openPanelBarItem)
    {
        if (item.itemIsSelect) {
            _recordAudioBarItem.itemIsSelect = NO;
            [self cancleInputState];
            _callBarItem.itemIsSelect = NO;
            [self setCurrentActionType:MJChatInputBarActionType_Panel];
            if (_inputTextView.recordState == YES) {
                [_inputTextView hiddenRecordButton];
            }
            [_inputTextView resignInputTextView];
        }else {
            [self cancleInputState];
        }
    }
}

- (void)setCurrentActionType:(MJChatBarActionType)actionType
{
    _actionType = actionType;
    if ([self.delegate respondsToSelector:@selector(changeActionType:)]) {
        [self.delegate changeActionType:_actionType];
    }
}

- (void)cancleInputState
{
    switch (_actionType) {
        case MJChatInputBarActionType_None:
            return ;
            break;
            
        case MJChatInputBarActionType_Audio:
            return ;
            break;
        case MJChatInputBarActionType_Text:
            [_inputTextView resignInputTextView];
            break;
            
        case MJChatInputBarActionType_Emoji:
            _callBarItem.itemIsSelect = NO;
            break;
            
        case MJChatInputBarActionType_Panel:
            _callBarItem.itemIsSelect = NO;
            break;
            
        default:
            break;
    }
    _openPanelBarItem.itemIsSelect = NO;
    [self setCurrentActionType:MJChatInputBarActionType_None];
}


@end
