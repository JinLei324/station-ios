//
//  MainBoutiqueCell.h
//  LonelyStation
//
//  Created by 钟铿 on 2018/1/20.
//  Copyright © 2018年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainBoutiqueCell : UICollectionViewCell

typedef void(^MainBoutiqueCellClickBlock)(NSDictionary *dict);

@property (nonatomic,strong)UIImageView *imageView;//头像

@property (nonatomic,strong)UIImageView *playView;//播放按钮

@property (nonatomic,strong)EMLabel *seenLabel;//多少人看过

@property (nonatomic,strong)EMLabel *nickName;

@property (nonatomic,copy)MainBoutiqueCellClickBlock  cellClickBlock;



- (void)setValueWithDict:(NSDictionary*)dict;

@end
