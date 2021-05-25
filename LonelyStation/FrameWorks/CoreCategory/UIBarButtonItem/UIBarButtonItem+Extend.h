//
//  UIBarButtonItem+Extend.h
//  Carpenter
//
//  Created by zk on 15/5/11.
//  Copyright (c) 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+Extend.h"


@interface UIBarButtonItem (Extend)



+(instancetype)barButtonItemWithSize:(CGSize)size target:(id)target selector:(SEL)selector ImgName:(NSString *)imgName hlImageColor:(UIColor *)hlImageColor;


@end
