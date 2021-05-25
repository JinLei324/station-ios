//
//  MyBuyListCell.m
//  LonelyStation
//
//  Created by zk on 2016/10/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyBuyListCell.h"
#import "UIUtil.h"
#import "Masonry.h"

@interface  MyBuyListCell() {
    EMLabel *_timeLabel;
    EMLabel *_productNameLabel;
    EMLabel *_productDespLabel;
}


@end

@implementation MyBuyListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithSize:(CGSize)size reuseIdentifier:(NSString *)reuseIdentifier {
    //自定义
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        //生成视图，根据样式是否需要创建背景
        [self initViewsWithSize:size];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)initViewsWithSize:(CGSize)size {
    self.backgroundColor = [UIColor clearColor];
    CGFloat x = 11*kScale;
    CGFloat y = 0;
    CGFloat width = kScreenW - 2*x;
    CGFloat height = 84*kScale;
    EMView *backView = [[EMView alloc] initWithFrame:Rect(x, y, width, height) andConners:5];
    backView.backgroundColor = [UIColor clearColor];
    backView.borderColor = RGB(171, 171, 171);
    backView.borderWidth = 1;
    [self.contentView addSubview:backView];
    
    _timeLabel = [EMLabel new];
    [backView addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20*kScale);
        make.left.mas_equalTo(11*kScale);
        make.bottom.mas_equalTo(-22*kScale);
        make.width.mas_equalTo(93*kScale);
    }];
    _timeLabel.numberOfLines = 0;
    _timeLabel.textColor = RGB(51,51,51);
    _timeLabel.font = ComFont(15*kScale);
    
    UIView *line = [UIView new];
    [backView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.bottom.mas_equalTo(0);
        make.width.mas_equalTo(0.5);
        make.left.equalTo(_timeLabel.mas_right).offset(5*kScale);
    }];
    line.backgroundColor =RGB(171, 171, 171);
    
    _productNameLabel = [EMLabel new];
    [backView addSubview:_productNameLabel];
    [_productNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(13*kScale);
        make.left.equalTo(line.mas_right).offset(11*kScale);
        make.right.mas_equalTo(-80*kScale);
        make.bottom.mas_equalTo(-13*kScale);
    }];
    _productNameLabel.numberOfLines = 0;
    _productNameLabel.textColor = RGB(51,51,51);
    _productNameLabel.font = ComFont(15*kScale);
    
    _productDespLabel = [EMLabel new];
    [backView addSubview:_productDespLabel];
    [_productDespLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(backView.mas_centerY);
        make.right.mas_equalTo(-11*kScale);
        make.height.mas_equalTo(30*kScale);
        make.width.mas_equalTo(65*kScale);
    }];
    _productDespLabel.textColor = [UIColor redColor];
    
    _productDespLabel.font = ComFont(15*kScale);
    _productDespLabel.layer.borderColor =  RGB(145,90,173).CGColor;
//    _productDespLabel.layer.backgroundColor = RGB(145,90,173).CGColor;
    _productDespLabel.layer.borderWidth = 1;
    _productDespLabel.textAlignment = NSTextAlignmentCenter;
    _productDespLabel.layer.masksToBounds = YES;
    _productDespLabel.layer.cornerRadius = 15*kScale;
    
//    x = 22*kScale;
//    y = 12*kScale;
//    width = width - 2*x;
//    height = 16*kScale;
//    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
//    _timeLabel.textColor = RGB(255,252,0);
//    _timeLabel.font = ComFont(15*kScale);
//    [backView addSubview:_timeLabel];
//
//    _productNameLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_timeLabel)+7*kScale, width, 17*kScale)];
//    _productNameLabel.textColor = RGB(255,252,0);
//    _productNameLabel.font = ComFont(16*kScale);
//    [backView addSubview:_productNameLabel];
//
//    _productDespLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_productNameLabel)+7*kScale, width, 16*kScale)];
//    _productDespLabel.textColor = RGB(252,0,0);
//    _productDespLabel.font = ComFont(15*kScale);
//    [backView addSubview:_productDespLabel];

    
}

- (void)setBuyListObj:(BuyListObj *)buyListObj {
    _buyListObj = nil;
    _buyListObj = buyListObj;
    _timeLabel.text = [NSString stringWithFormat:@"%@",buyListObj.buyTime];
    _productNameLabel.text = [NSString stringWithFormat:@"%@",buyListObj.productName];
    if ([buyListObj.paid isEqualToString:@"Y"]) {
        _productDespLabel.text = Local(@"Paid");
    }else {
        _productDespLabel.text = Local(@"NotPaid");
    }
}


@end
