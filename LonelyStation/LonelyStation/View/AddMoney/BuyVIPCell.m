//
//  BuyVIPCell.m
//  LonelyStation
//
//  Created by zk on 2016/10/16.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "BuyVIPCell.h"
#import "EMView.h"

@interface BuyVIPCell()

@property (nonatomic,strong)EMLabel *likeLabel;
@property (nonatomic,strong)EMLabel *despLabel;

@end

@implementation BuyVIPCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier {
    //自定义
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        //生成视图，根据样式是否需要创建背景
        [self initViewsWithSize:size];
    }
    return self;
}


- (void)setCardDesp:(NSString *)cardDesp {
    _cardDesp = cardDesp;
    _despLabel.text = cardDesp;
}

- (void)setLikeCard:(NSString *)likeCard {
    _likeCard = likeCard;
    _likeLabel.text = likeCard;
}


- (void)initViewsWithSize:(CGSize)size {
    self.backgroundColor = [UIColor clearColor];
    CGFloat x = 34*kScale;
    CGFloat y = 16*kScale;
    CGFloat width = 200*kScale;
    CGFloat height = 16*kScale;
    _likeLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
    _likeLabel.textColor = RGB(255,255,255);
    _likeLabel.font = ComFont(15*kScale);
    [self.contentView addSubview:_likeLabel];
    
    y = PositionY(_likeLabel) + 8*kScale;
    width = 250*kScale;
    _despLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
    _despLabel.textColor = RGB(255,252,0);
    _despLabel.font = ComFont(14*kScale);
    [self.contentView addSubview:_despLabel];
    
    y = 20*kScale;
    width = 27*kScale;
    height = 27*kScale;
    x = kScreenW - width - 30*kScale;
    _radioBtn = [[EMButton alloc] initWithFrame:Rect(x, y, width, height)];
    [_radioBtn setImage:[UIImage imageNamed:@"singlenoButton"] forState:UIControlStateNormal];
    [_radioBtn setImage:[UIImage imageNamed:@"singleyesButton"] forState:UIControlStateSelected];
    [self.contentView addSubview:_radioBtn];
    _radioBtn.userInteractionEnabled = NO;
    
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, size.height - 1, kScreenW, 1)];
    line.backgroundColor = RGB(0xff, 0xff, 0xff);
    [self.contentView addSubview:line];
    
    EMView *selectView = [[EMView alloc] initWithFrame:Rect(0, 0, size.width, size.height)];
    selectView.backgroundColor = RGBA(80,27,104,0.3);
    EMView *line1 = [[EMView alloc] initWithFrame:Rect(0, size.height - 1, kScreenW, 1)];
    line1.backgroundColor = RGB(0xff, 0xff, 0xff);
    [selectView addSubview:line1];
    
    self.selectedBackgroundView = selectView;
}





- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [_radioBtn setSelected:selected];
    // Configure the view for the selected state
}

@end
