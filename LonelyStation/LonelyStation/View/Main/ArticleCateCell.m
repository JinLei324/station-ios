//
//  ArticleCateCell.m
//  LonelyStation
//
//  Created by zk on 16/10/14.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "ArticleCateCell.h"
#import "UIUtil.h"

@interface ArticleCateCell()

@property (nonatomic,strong)UIImageView *headImgView;

@property (nonatomic,strong)EMLabel *titleLabel;

@property (nonatomic,strong)EMLabel *fromLabel;

@property (nonatomic,strong)UIImageView *smallImgView;

@property (nonatomic,strong)UIImageView *a18BanImgView;

@end


@implementation ArticleCateCell

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


- (void)initViewsWithSize:(CGSize)size {
    CGFloat x = 12*kScale;
    CGFloat y = 7*kScale;
    CGFloat width = 83*kScale;
    CGFloat height = 59*kScale;
    _headImgView = [[UIImageView alloc] initWithFrame:Rect(x, y, width, height)];
    [self.contentView addSubview:_headImgView];
    
    x = PositionX(_headImgView) + 14*kScale;
    y = 19*kScale;
    width = kScreenW - x - 11*kScale;
    height = 14 * kScale;
    _titleLabel = [[EMLabel alloc] initWithFrame:Rect(x, y, width, height)];
    _titleLabel.font = ComFont(13*kScale);
    _titleLabel.textColor = RGB(51,51,51);
    [self.contentView addSubview:_titleLabel];
    
    _smallImgView = [[UIImageView alloc] initWithFrame:Rect(x, PositionY(_titleLabel) + 20*kScale, 13*kScale, 13*kScale)];
    _smallImgView.image = [UIImage imageNamed:@"BTmoreTopic"];
    [self.contentView addSubview:_smallImgView];
    
    x = PositionX(_smallImgView) + 7*kScale;
    width = kScreenW - 11*kScale - x;
    height = 13*kScale;
    _fromLabel = [[EMLabel alloc] initWithFrame:Rect(x, PositionY(_titleLabel)+19*kScale, width, height)];
    _fromLabel.textColor = RGB(51,51,51);
    _fromLabel.font = ComFont(12*kScale);
    [self.contentView addSubview:_fromLabel];
    [self setBackgroundColor:[UIColor clearColor]];
    
    _a18BanImgView = [[UIImageView alloc] initWithFrame:Rect(PositionX(_fromLabel)+7*kScale, PositionY(_titleLabel)+14*kScale, 20*kScale, 20*kScale)];
    _a18BanImgView.image = [UIImage imageNamed:@"topic_ban"];
    [self.contentView addSubview:_a18BanImgView];
    _a18BanImgView.hidden = YES;
    EMView *line = [[EMView alloc] initWithFrame:Rect(0, 69*kScale, kScreenW, 1)];
    line.backgroundColor = RGB(171,171,171);
    [self.contentView addSubview:line];
}

- (void)setArticleObj:(ArticleObj *)articleObj {
    _articleObj = nil;
    _articleObj = articleObj;
    if ([articleObj.productImgName isEqualToString:@""]) {
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:articleObj.productImgName0] placeholder:[UIImage imageNamed:@"topic_no_photo"]];
    }else{
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:articleObj.productImgName] placeholder:[UIImage imageNamed:@"topic_no_photo"]];
    }
    _headImgView.contentMode = UIViewContentModeScaleAspectFit;
    _titleLabel.text = articleObj.productName;
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@/%@%@",Local(@"From"),articleObj.productNo,articleObj.productClick,Local(@"Seen")]];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:RGB(145,90,173) range:NSMakeRange(0, [[NSString stringWithFormat:@"%@%@/",Local(@"From"),articleObj.productNo] length])];
    [_fromLabel setAttributedText:attributedString1];
    CGSize size = [_fromLabel.attributedText.string sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:ComFont(12*kScale),NSFontAttributeName, nil]];
    CGRect rect = _a18BanImgView.frame;
    rect.origin.x = _fromLabel.frame.origin.x + size.width + 7*kScale;
    _a18BanImgView.frame = rect;
    if ([_articleObj.product18Ban isEqualToString:@"Y"]) {
        _a18BanImgView.hidden = NO;
    }else {
        _a18BanImgView.hidden = YES;
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
