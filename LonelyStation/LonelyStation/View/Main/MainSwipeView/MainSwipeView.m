//
//  MainSwipeView.m
//  LonelyStation
//
//  Created by 钟铿 on 2018/5/1.
//  Copyright © 2018年 zk. All rights reserved.
//

#import "MainSwipeView.h"
#import "SMSwipeView.h"
#import "Masonry.h"
#import "LonelyStationUser.h"
#import "ViewModelCommom.h"

@interface MainSwipeView()<SMSwipeDelegate>

@property (nonatomic,weak)SMSwipeView *swipeView;

@property (nonatomic,strong)EMView *maskView;


@end

@implementation MainSwipeView

-(instancetype)init {
    self = [super init];
    [self initView];
    return self;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    [_swipeView reloadData];
}

- (void)initView {
    SMSwipeView *swipeView = [SMSwipeView new];
    swipeView.w = 317*kScale;
    swipeView.h = 450*kScale;
    [self addSubview:swipeView];
    [swipeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.top.and.bottom.mas_equalTo(0);
    }];
    swipeView.delegate = self;
    swipeView.isStackCard = YES;
    _swipeView = swipeView;
    NSUserDefaults *defaluts = [NSUserDefaults standardUserDefaults];
    BOOL isThisAccountFirstComing = (BOOL)[defaluts objectForKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
    if (!isThisAccountFirstComing) {
        //再加一个maskView
        _maskView = [EMView new];
        [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
        [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.and.bottom.mas_equalTo(0);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
        [_maskView addGestureRecognizer:tap];
        
        _maskView.backgroundColor = RGBA(0, 0, 0, 0.6);
        UIImageView *leftView = [UIImageView new];
        [_maskView addSubview:leftView];
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(280*kScale);
            make.left.mas_equalTo(71*kScale);
            make.size.mas_equalTo(Size(46*kScale, 46*kScale));
        }];
        leftView.image = [UIImage imageNamed:@"turn_left"];
        EMLabel * leftLabel = [EMLabel new];
        [_maskView addSubview:leftLabel];
        leftLabel.font = ComFont(15*kScale);
        leftLabel.textColor = RGB(0,255,255);
        [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftView.mas_bottom).offset(15*kScale);
            make.left.mas_equalTo(41*kScale);
            make.size.mas_equalTo(Size(100*kScale, 15*kScale));
        }];
        leftLabel.text = Local(@"LeftDesp");
        leftLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *rightView = [UIImageView new];
        [_maskView addSubview:rightView];
        [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(280*kScale);
            make.right.mas_equalTo(-71*kScale);
            make.size.mas_equalTo(Size(46*kScale, 46*kScale));
        }];
        rightView.image = [UIImage imageNamed:@"turn_right"];
        
        EMLabel * rightLabel = [EMLabel new];
        [_maskView addSubview:rightLabel];
        rightLabel.font = ComFont(15*kScale);
        rightLabel.textColor = RGB(0,255,255);
        [rightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(rightView.mas_bottom).offset(15*kScale);
            make.right.mas_equalTo(-41*kScale);
            make.size.mas_equalTo(Size(100*kScale, 15*kScale));
        }];
        rightLabel.text = Local(@"RightDesp");
        rightLabel.textAlignment = NSTextAlignmentCenter;
        [defaluts setBool:YES forKey:[NSString stringWithFormat:@"%@firstComing",[[ViewModelCommom getCuttentUser] userID]]];
    }
}


- (void)tapAction {
    [_maskView removeFromSuperview];
    _maskView = nil;
}

-(UITableViewCell*)SMSwipeGetView:(SMSwipeView *)swipe withIndex:(int)index{
    static NSString * identify=@"MainSwipeViewCell";
    MainSwipeViewCell * cell=(MainSwipeViewCell*)[self.swipeView dequeueReusableUIViewWithIdentifier:identify];
    if (cell==nil) {
        cell=[[MainSwipeViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.cornerRadius=10;
    if (index < _dataArray.count) {
        LonelyStationUser *user = _dataArray[index];
        [cell setModel:user andTarget:_mainDelegate andIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    }
    return cell;
}


-(void)SMSwipeisLast {
    [self.superview removeFromSuperview];
    [self removeFromSuperview];
}


-(NSInteger)SMSwipeGetTotaleNum:(SMSwipeView *)swipe{
    if (!_dataArray) {
        return 0;
    }
    return self.dataArray.count;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
