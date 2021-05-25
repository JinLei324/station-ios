//
//  RecordAiringNextStepViewController.h
//  LonelyStation
//
//  Created by 钟铿 on 2019/2/14.
//  Copyright © 2019 zk. All rights reserved.
//

#import "EMViewController.h"

@interface RecordAiringNextStepViewController : EMViewController
//地址
@property(nonatomic,strong)NSString *audioPath;
//用来记录录音总长多少秒，裁剪的总长多少秒
@property(nonatomic,assign)long long totalTime;
@end
