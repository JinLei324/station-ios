//
//  InnerImgViewController.h
//  LonelyStation
//
//  Created by zk on 16/8/13.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "RecordAiringVM.h"


@protocol InnerImgSelectProtocol <NSObject>

- (void)didSelectInnerImg:(InnerRecBgImgObj*)obj andController:(id)controller;

@end

@interface InnerImgViewController : EMViewController

@property(nonatomic,assign)id<InnerImgSelectProtocol> delegate;

@end
