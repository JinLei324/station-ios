//
//  ChatMiddleView.h
//  LonelyStation
//
//  Created by zk on 2016/12/17.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ChatMiddleViewDelegate <NSObject>

- (void)didClickMain;

@end




@interface ChatMiddleView : UIView

@property (nonatomic,assign)id<ChatMiddleViewDelegate> delegate;


@end
