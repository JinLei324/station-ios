//
//  VoiceSliderView.h
//  dexotrip
//
//  Created by kevin on 16/8/5.
//  Copyright © 2016年 kevin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VoiceSliderView : UIView

@property (nonatomic, strong) UILabel *crruentLabel;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UIProgressView *progressView;

@end
