//
//  ArticleCateView.m
//  LonelyStation
//
//  Created by zk on 2016/11/6.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ArticleCateView.h"

@interface  ArticleCateView()

@property (nonatomic,strong)EMButton *cellButton;

@end

@implementation ArticleCateView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self initWithSize:(CGSize)frame.size];
    }
    return self;
}

- (void)initWithSize:(CGSize)size {
    _cellButton = [self buttonWithImage:@"" andHightlightName:@"" andFrame:Rect(0, 0, size.width, size.height) andName:@""];
    [_cellButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(EMButton*)btn {
    if (_delegate) {
        [_delegate didClickCellBtn:btn andIndex:self.index];
    }
}

- (void)setCategory:(Categories *)category {
    _category = category;
    LonelyUser *user = [ViewModelCommom getCuttentUser];
    [_cellButton yy_setImageWithURL:[NSURL URLWithString:category.productImageName] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgName:user.gender]]];
    if ([category.productImageName isEqualToString:@""]) {
        [_cellButton yy_setImageWithURL:[NSURL URLWithString:category.productImageNameBig] forState:UIControlStateNormal placeholder:[UIImage imageNamed:[EMUtil getMainDefaultImgName:user.gender]]];
    }
    _cellButton.imageView.contentMode = UIViewContentModeScaleAspectFill;
    EMLabel *label = [self viewWithTag:1000];
    label.text = category.categoriesName;
}



- (EMButton*)buttonWithImage:(NSString*)imageName andHightlightName:(NSString*)hightlightName andFrame:(CGRect)frame andName:(NSString*)name {
    EMButton *btn = [[EMButton alloc] initWithFrame:Rect(0, 0, frame.size.width, frame.size.height)];
    [self addSubview:btn];

    EMView *lastView = [[EMView alloc] initWithFrame:Rect(0, frame.size.height - 20*kScale, frame.size.width, 20*kScale)];
    lastView.backgroundColor = RGB(242,242,242);
    lastView.alpha = 0.5;
    [self addSubview:lastView];
    EMLabel *label = [[EMLabel alloc] initWithFrame:Rect(frame.size.width - 161, frame.size.height - 20*kScale, 150, 20*kScale)];
    label.font = ComFont(15*kScale);
    label.textColor = RGB(3,41,172);
    label.text = name;
    label.textAlignment = NSTextAlignmentRight;
    label.tag = 1000;
    [self addSubview:label];
    return btn;
    
}


@end
