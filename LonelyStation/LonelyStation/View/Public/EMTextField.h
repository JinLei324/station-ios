//
//  EMTextField.h
//  emeNew
//
//  Created by zk on 15/12/14.
//  Copyright © 2015年 zk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMTextField : UITextField<UITextFieldDelegate>{
    NSString *_currentplaceholder;
}

@property(nonatomic,assign)BOOL notUsePaster;
@property(nonatomic,copy)NSString *titStr;
@property(nonatomic,assign)NSInteger textMaxLength;

@end
