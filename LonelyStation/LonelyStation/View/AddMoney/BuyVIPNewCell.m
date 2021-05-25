//
//  BuyVIPNewCell.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/6/16.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "BuyVIPNewCell.h"
#import "Masonry.h"

@interface BuyVIPNewCell()

@property (nonatomic,strong)UIImageView *imgView;

@property (nonatomic,strong)EMLabel *label;

@property (nonatomic,strong)EMButton *buyBtn;

@end

@implementation BuyVIPNewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UIImageView*)imgView {
    if (!_imgView) {
        _imgView = [UIImageView new];
        [self.contentView addSubview:_imgView];
        _imgView.image = [UIImage imageNamed:@"icon_coin"];
        [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(25*kScale);
            make.size.mas_equalTo(Size(34*kScale, 34*kScale));
        }];
    }
    return _imgView;
}


- (EMLabel*)label {
    if (!_label) {
        _label = [EMLabel new];
        [self.contentView addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.imgView.mas_right).offset(20*kScale);
            make.right.mas_equalTo(-100*kScale);
            make.height.mas_equalTo(44*kScale);
        }];
        _label.textColor = RGB(83,83,83);
        _label.font = ComFont(18*kScale);
    }
    return _label;
}

- (EMButton*)buyBtn {
    if (!_buyBtn) {
        _buyBtn = [[EMButton alloc] initWithFrame:Rect(0, 0, 105*kScale, 37*kScale) andConners:18*kScale];
        [self.contentView addSubview:_buyBtn];
        [_buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.right.mas_equalTo(-15*kScale);
            make.height.mas_equalTo(37*kScale);
            make.width.mas_equalTo(105*kScale);
        }];
        _buyBtn.cornerRadius = 20*kScale;
        [_buyBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        _buyBtn.backgroundColor = RGB(145,90,173);
        [_buyBtn addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _buyBtn;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    return self;
}

- (void)buyAction:(EMButton*)btn {
    if (_clickBlock) {
        self.clickBlock();
    }
}

- (void)setModel:(ProgramObj*)model {
    self.label.text = [NSString stringWithFormat:@"%@%@",model.chatPoint,Local(@"ChatMoney")];
    [self.buyBtn setTitle:[NSString stringWithFormat:@"$%@ USD",model.money] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
