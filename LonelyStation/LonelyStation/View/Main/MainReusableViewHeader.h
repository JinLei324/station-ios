//
//  MainReusableViewHeader.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/1/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainReusableViewHeader : UICollectionReusableView



typedef void(^HeadClickBlock)(void);

@property (nonatomic,strong)EMLabel *leftLabel;
@property (nonatomic,strong)EMLabel *rightLabel;
@property (nonatomic,strong)UIImageView *rightImageView;

@property (nonatomic,copy)HeadClickBlock clickBlock;

@end
