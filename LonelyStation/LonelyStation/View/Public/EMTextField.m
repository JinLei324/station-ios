//
//  EMTextField.m
//  emeNew
//
//  Created by zk on 15/12/14.
//  Copyright © 2015年 zk. All rights reserved.
//

#import "EMTextField.h"

@implementation EMTextField
-(id)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.delegate = self;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEditing]) {
        if (![textField.placeholder isEqualToString:@""]) {
            _currentplaceholder = textField.placeholder;
        }
        textField.placeholder = @"";
        if ([textField.superview isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView*)textField.superview setDirectionalLockEnabled:YES];
        }
    }
    return YES;
}

-(BOOL) respondsToSelector:(SEL)aSelector {
    
    NSString * selectorName = NSStringFromSelector(aSelector);
    
    if ([selectorName isEqualToString:@"customOverlayContainer"]) {
        
        return NO;
    }
    
    return [super respondsToSelector:aSelector];
}


//- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
//    if (_notUsePaster) {
//        UIMenuController *menuController = [UIMenuController sharedMenuController];
//        if (menuController) {
//            [UIMenuController sharedMenuController].menuVisible = NO;
//        }
//        return NO;
//    }
//    return YES;
//}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (_currentplaceholder && ![_currentplaceholder isEqualToString:@""]) {
         textField.placeholder = _currentplaceholder;
//        if ([textField.superview isKindOfClass:[UIScrollView class]]) {
//            [(UIScrollView*)textField.superview setScrollEnabled:YES];
//        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.textMaxLength == 0) {
        self.textMaxLength = 32;
    }
    if (range.location >= self.textMaxLength){
        if ([string isEqualToString:@""]) {
            return YES;
        }
        return NO; // return NO to not change text

    }
    return YES;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}


-(void)dealloc{
    _titStr = nil;
    _currentplaceholder = nil;
}


@end
