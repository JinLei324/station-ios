//
//  EffectSelectViewController.h
//  LonelyStation
//
//  Created by zk on 16/8/18.
//  Copyright © 2016年 zk. All rights reserved.
//

#import "EMViewController.h"
#import "BgAudioObj.h"

@protocol EffectSelectProtocol <NSObject>

- (void)didSelectEffect:(BgAudioObj*)obj andController:(id)controller;

@end

@interface EffectSelectViewController : EMViewController

@property(nonatomic,assign)id<EffectSelectProtocol> delegate;


@end
