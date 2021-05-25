//
//  MyRecordsTableViewCell.m
//  LonelyStation
//
//  Created by zk on 16/8/19.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "MyRecordsTableViewCell.h"
#import "UICycleImgView.h"
#import "EMButton.h"
#import "EMView.h"
#import "ViewModelCommom.h"
#import "EMUtil.h"

@interface MyRecordsTableViewCell()

@property (nonatomic,strong)UICycleImgView *headImgView;

@property (nonatomic,strong)EMLabel *categoryLabel;

@property (nonatomic,strong)EMLabel *collectLabel;

@property (nonatomic,strong)EMLabel *timeLabel;

@property (nonatomic,strong)EMLabel *stateLabel;


@property (nonatomic,strong)EMButton *telBtn;

@property (nonatomic,strong)EMButton *posBtn;

@property (nonatomic,strong)EMView *line;

@end


@implementation MyRecordsTableViewCell

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
    }
    
    return self;
}

- (void)initViewsWithSize:(CGSize)size {
    //tag图片
    CGFloat fImgWH = 42.0f*kScale;
    CGFloat x = 11.f*kScale;
    CGFloat y = 17.f*kScale;
    CGFloat _categoryLabelWidth = 170 * kScale;
    CGFloat _categoryLabelHight = 13 * kScale;
    CGFloat _timeLabelWidth = 150*kScale;
    
    _headImgView = [[UICycleImgView alloc] initWithFrame:Rect(x, y, fImgWH, fImgWH)];
    
    [self.contentView addSubview:_headImgView];
    
    _categoryLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_headImgView) + 18*kScale, y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_categoryLabel];
    _categoryLabel.textColor = RGB(51, 51, 51);
    _categoryLabel.text = @"";
    _categoryLabel.font = ComFont(12);
    _collectLabel = [[EMLabel alloc] initWithFrame:Rect(PositionX(_headImgView) + 18*kScale, PositionY(_categoryLabel) + y, _categoryLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_collectLabel];
    _collectLabel.textColor = RGB(51,51,51);
    _collectLabel.text = @"";
    _collectLabel.font = ComFont(12);
    
    
//    NSString *str = [[[FileAccessData sharedInstance] objectForEMKey:@"isChecking"] lastObject];
//    if ([str isEqualToString:@"0"]) {
        _collectLabel.hidden = NO;
//    }else{
//        _collectLabel.hidden = YES;
//
//    }
    
    

    _timeLabel = [[EMLabel alloc] initWithFrame:Rect(size.width - _timeLabelWidth - 13*kScale, y, _timeLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_timeLabel];
    _timeLabel.textColor = RGB(253,125,255);
    _timeLabel.text = @"";
    _timeLabel.font = ComFont(12);
    _timeLabel.textAlignment = NSTextAlignmentRight;
    
    _stateLabel = [[EMLabel alloc] initWithFrame:Rect(size.width - _timeLabelWidth - 13*kScale, PositionY(_categoryLabel) + y, _timeLabelWidth, _categoryLabelHight)];
    [self.contentView addSubview:_stateLabel];
    _stateLabel.textColor = RGBA(51, 51, 51, 1);
    _stateLabel.text = @"";
    _stateLabel.font = ComFont(12);
    _stateLabel.textAlignment = NSTextAlignmentRight;

    
    //线
    _line = [[EMView alloc] initWithFrame:Rect(0, size.height - 0.5, size.width, 0.5)];
    _line.backgroundColor = RGBA(171,171,171,1);
    [self.contentView addSubview:_line];
}

- (void)setBoardcastObj:(BoardcastObj *)boardcastObj {
    _boardcastObj = nil;
    _boardcastObj = boardcastObj;
    //用户当前头像
    if (_user) {
        [_headImgView yy_setImageWithURL:[NSURL URLWithString:_user.file]placeholder:[UIImage imageNamed:[EMUtil getHeaderDefaultImgName:_user.gender]]];

    }
    _categoryLabel.text = [NSString stringWithFormat:@"%@:%@",boardcastObj.category,boardcastObj.title];
    _collectLabel.text = [NSString stringWithFormat:@"%@:%@ USD",Local(@"ThisAiringCollect"),_boardcastObj.profit];
    
    _timeLabel.text = [EMUtil getTimeToNow:boardcastObj.updateTime];
    //先写死先
    if (boardcastObj.status.intValue == 2) {
        _stateLabel.text = Local(@"PendingChecking");
    }else if(boardcastObj.status.intValue == 3){
        _stateLabel.text = Local(@"RefuseCheck");
    }else {
        _stateLabel.text = Local(@"NoChecked");
    }    
    
}


@end
