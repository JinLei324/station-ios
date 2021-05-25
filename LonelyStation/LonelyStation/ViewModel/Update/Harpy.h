//
//  Harpy.h
//  Harpy
//
//  Created by Arthur Ariel Sabintsev on 11/14/12.
//  Copyright (c) 2012 Arthur Ariel Sabintsev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Harpy : NSObject <UIAlertViewDelegate>{
    
}

/*
 Checks the installed version of your application against the version currently available on the iTunes store.
 If a newer version exists in the AppStore, it prompts the user to update your app.
 */
@property(nonatomic,assign) BOOL shouldUpdateVersion;
+ (Harpy *)sharedInstance;
+ (void)checkVersion;
+ (void)checkVersion:(BOOL)sholdalert andView:(UIView*)view;

@end
