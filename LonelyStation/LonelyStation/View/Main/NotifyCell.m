//
//  NotifyCell.m
//  LonelyStation
//
//  Created by zk on 2016/11/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "NotifyCell.h"

@implementation NotifyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (JPLabel*)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[JPLabel alloc]initWithFrame:CGRectMake(28*kScale,
                                                                 13*kScale, kScreenW - 56*kScale, CGRectGetHeight(self.frame))];
        [self.contentView addSubview:_contentLabel];
        //设置字体
       
    }
    _contentLabel.textColor = RGB(51, 51, 51);
    _contentLabel.jp_commonTextColor = RGB(51, 51, 51);
    _contentLabel.numberOfLines = 0;
    _contentLabel.font = ComFont(14*kScale);
    _contentLabel.frame = CGRectMake(28*kScale,
                                     13*kScale, kScreenW - 56*kScale, _height-44*kScale);
    return _contentLabel;
}

- (UIImageView*)goImageView{
    if (!_goImageView) {
        _goImageView = [[UIImageView alloc]initWithFrame:CGRectMake(28*kScale,
                                                                 _height - 30*kScale, 46*kScale, 22*kScale)];
        [self.contentView addSubview:_goImageView];
        
    }
    _goImageView.frame = CGRectMake(28*kScale,
                                    _height - 30*kScale, 46*kScale, 22*kScale);
    return _goImageView;
}







- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
