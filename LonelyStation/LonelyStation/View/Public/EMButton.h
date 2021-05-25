//
//  EMButton.h
//  emeNew
//
//  Created by zk on 15/12/5.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIButton+countDown.h"

@interface EMButton : UIButton

@property (nonatomic) IBInspectable BOOL    topLeft;
@property (nonatomic) IBInspectable BOOL    topRigth;
@property (nonatomic) IBInspectable BOOL    bottomLeft;
@property (nonatomic) IBInspectable BOOL    bottomRigth;
@property (nonatomic) IBInspectable int     cornerRadius;

@property(nonatomic,copy)NSString *titStr;
@property(nonatomic,assign)NSInteger tableTag;
@property(nonatomic,assign)NSInteger section;
@property(nonatomic,assign)NSInteger indexRow;

@property(nonatomic,assign)CGFloat borderWidth;

@property(nonatomic,strong)UIColor *borderColor;

-(id)initWithFrame:(CGRect)frame isRdius:(BOOL)isRadio;

-(id)initWithFrame:(CGRect)frame andConners:(int)conner;

-(void)setDefaultHightlightedImage;

@end
