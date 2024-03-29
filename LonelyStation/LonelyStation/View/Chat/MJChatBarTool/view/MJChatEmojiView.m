//
//  MJChatEmojiView.m
//  MJChatBarTool
//
//  Created by linhua hu on 16/10/13.
//  Copyright © 2016年 linhua hu. All rights reserved.
//

#import "MJChatEmojiView.h"
#import "MJChatBarToolModel.h"
#import "MJChatEmojiBar.h"
#import "MJhatInputExpandEmojiPanelPageItem.h"
#import "MJChatInputExpandEmojiPanelGifPageItem.h"
#import "MJChatBarNotificationCenter.h"

@interface MJChatEmojiView ()<UIScrollViewDelegate,MJChatEmojiBardelegate>

@property (nonatomic , strong)UIScrollView *scrollView;
@property (nonatomic , strong)UIPageControl *pageControl;
@property (nonatomic , strong)MJChatEmojiBar *emojiBar;
@property (nonatomic , strong)UIButton *sendButton;
@property (nonatomic,assign)NSInteger pageCount;

@end

@implementation MJChatEmojiView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        _scrollView = [self getScrollViewWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 70)];
        [self addSubview:_scrollView];
        
        _pageControl = [self getPageControlL:frame];
        _pageControl.numberOfPages = 6;
        
        UIImageView *bottomBarBack = [[UIImageView alloc]initWithFrame:CGRectMake(0, frame.size.height - 40.5, GJCFSystemScreenWidth, 0.1)];
        bottomBarBack.userInteractionEnabled = YES;
        [self addSubview:bottomBarBack];
        
        _emojiBar = [[MJChatEmojiBar alloc] init];
        _emojiBar.delegate = self;
        [bottomBarBack addSubview:_emojiBar];

    }
    return self;
}

- (void)setIndentifiName:(NSString *)indentifiName
{
    _indentifiName = indentifiName;
    [self loadEmojisWithSourceItem];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    NSArray *subViews = self.scrollView.subviews;
    if (hidden) {
        for (int i = 0; i < subViews.count; i++) {
            UIView *subView = self.scrollView.subviews[i];
            if ([subView isKindOfClass:[MJChatInputExpandEmojiPanelGifPageItem class]]) {
                [(MJChatInputExpandEmojiPanelGifPageItem*)subView hiddenMask];
            }
        }
    }
}




- (UIScrollView *)getScrollViewWithFrame:(CGRect)frame
{
    UIScrollView *scrllv = [[UIScrollView alloc] initWithFrame:frame];
    scrllv.delegate = self;
    scrllv.showsVerticalScrollIndicator = NO;
    scrllv.showsHorizontalScrollIndicator = NO;
    scrllv.pagingEnabled = YES;
    return scrllv;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
//    self.pageControl.currentPage = page;
}


- (UIPageControl *)getPageControlL:(CGRect)frame
{
    UIPageControl *pc = [[UIPageControl alloc] initWithFrame:CGRectMake(0, frame.size.height - 60.5, 80, 20)];
    CGPoint ceterP = pc.center;
    ceterP.x = 0.5*frame.size.width;
    pc.center = ceterP;
    pc.pageIndicatorTintColor = [MJChatBarToolModel colorFromHexString:@"cccccc"];
    pc.currentPageIndicatorTintColor = [MJChatBarToolModel colorFromHexString:@"b3b3b3"];
    [_pageControl addTarget:self action:@selector(pageIndexChange:) forControlEvents:UIControlEventValueChanged];
    return pc;
}

- (UIButton*)getSendButtonWihtFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setTitle:@"发送" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor blueColor];
    [button addTarget:self action:@selector(sendEmojiAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}

- (void)loadGifEmojisWithListPath:(NSString *)listPath
{
    NSArray *emojiArray = [NSArray arrayWithContentsOfFile:listPath];
    
    NSInteger pageItemCount = 16;
    
    /* 分割页面 */
    NSMutableArray *pagesArray = [NSMutableArray array];
    
    self.pageCount = emojiArray.count%pageItemCount == 0? emojiArray.count/pageItemCount:emojiArray.count/pageItemCount+1;
    self.pageControl.numberOfPages = self.pageCount;
    
    for (int i = 0; i < self.pageCount; i++) {
        
        NSMutableArray *pageItemArray = [NSMutableArray array];
        
        [pageItemArray addObjectsFromArray:[emojiArray subarrayWithRange:NSMakeRange(i*pageItemCount,pageItemCount)]];
        
        [pagesArray addObject:pageItemArray];
    }
    
    /* 创建 */
    for (int i = 0; i < pagesArray.count ; i++) {
        
        NSArray *pageNamesArray = [pagesArray objectAtIndex:i];
        
        MJChatInputExpandEmojiPanelGifPageItem  *pageItem = [[MJChatInputExpandEmojiPanelGifPageItem alloc]initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) withEmojiNameArray:pageNamesArray];
        pageItem.panelIdentifier = _indentifiName;
        pageItem.panelView = self.superview;
        [self.scrollView addSubview:pageItem];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.pageCount * GJCFSystemScreenWidth, self.scrollView.frame.size.height);
    
}

- (void)loadDataFromEmojiBarEmojiTypeSimple:(MJEmogjiStyleModel *)model
{
    
    NSInteger pageItemCount = 20;
    /* 分割页面 */
    NSMutableArray *pagesArray = [NSMutableArray array];
    
    self.pageCount = model.emojiArr.count%pageItemCount == 0? model.emojiArr.count/pageItemCount:model.emojiArr.count/pageItemCount+1;
    self.pageControl.numberOfPages = self.pageCount;
    NSInteger pageLastCount = model.emojiArr.count%pageItemCount;
    
    for (int i = 0; i < self.pageCount; i++) {
        NSMutableArray *pageItemArray = [NSMutableArray array];
        if (i != self.pageCount - 1) {
            
            [pageItemArray addObjectsFromArray:[model.emojiArr subarrayWithRange:NSMakeRange(i*pageItemCount,pageItemCount)]];
            [pageItemArray addObject:@{@"删除":@"删除"}];
        }else{
            [pageItemArray addObjectsFromArray:[model.emojiArr subarrayWithRange:NSMakeRange(i*pageItemCount, pageLastCount)]];
        }
        
        [pagesArray addObject:pageItemArray];
    }
    
    /* 创建 */
    for (int i = 0; i < pagesArray.count ; i++) {
        
        NSArray *pageNamesArray = [pagesArray objectAtIndex:i];
        
        MJhatInputExpandEmojiPanelPageItem *pageItem = [[MJhatInputExpandEmojiPanelPageItem alloc]initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) withEmojiNameArray:pageNamesArray];
        pageItem.indentifiName = _indentifiName;
        [self.scrollView addSubview:pageItem];
    }
    
    self.scrollView.contentSize = CGSizeMake(self.pageCount * GJCFSystemScreenWidth, self.scrollView.frame.size.height);
}


- (void)loadEmojisWithSourceItem
{
   
    MJEmogjiStyleModel *item = _emojiBar.emojiModel;
    if (!item.emojiArr) {
        item.emojiArr = [NSArray arrayWithContentsOfFile:item.emojiListFilePath];
    }
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.pageControl.currentPage = 0;
    CGRect visiableRect = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [self.scrollView scrollRectToVisible:visiableRect animated:NO];
    
    self.sendButton.hidden = !item.isNeedShowSendButton;

    
    
    switch (item.emojiType) {
        case MJCChatInputExpandEmojiTypeSimple:
        {
            
            [self loadDataFromEmojiBarEmojiTypeSimple:item];
        }
            break;
        case MJCChatInputExpandEmojiTypeGIF:
        {
            [self loadGifEmojisWithListPath:item.emojiListFilePath];
        }
            break;
        case MJCChatInputExpandEmojiTypeMyFavorit:
        {
            
        }
            break;
        case MJCChatInputExpandEmojiTypeFindFunGif:
        {
            
        }
            break;
        default:
            break;
    }
}


- (void)sendEmojiAction
{
    NSString *notifName = [MJChatBarNotificationCenter getNofitName:MJChatBarEmojiSendfNoti formateWihtIndentifier:_indentifiName];
    MJNotificationPostObj(notifName, @"MJ_发送", nil);
}

- (void)pageIndexChange:(UIPageControl *)pageControl
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
