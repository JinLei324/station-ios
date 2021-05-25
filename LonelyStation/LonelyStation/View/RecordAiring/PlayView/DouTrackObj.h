//
//  DouTrackObj.h
//  PlayerTest
//
//  Created by zk on 2016/10/20.
//  Copyright © 2016年 zk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface DouTrackObj : NSObject<DOUAudioFile>

@property (nonatomic, strong) NSURL *audioFileURL;


@end
