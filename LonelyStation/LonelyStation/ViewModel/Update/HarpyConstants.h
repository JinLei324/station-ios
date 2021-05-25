//
//  HarpyConstants.h
//  
//
//  Created by Arthur Ariel Sabintsev on 1/30/13.
//
//

#import <Foundation/Foundation.h>

/*
 Option 1 (DEFAULT): NO gives user option to update during next session launch
 Option 2: YES forces user to update app on launch
 */
static BOOL harpyForceUpdate = NO;

// 2. Your AppID (found in iTunes Connect)
#define kHarpyAppID                 @"973082073"

// 3. Customize the alert title and action buttons
#define kHarpyAlertViewTitle     NSLocalizedStringFromTable(@"UPDATEAVILIBALE", @"Localization",nil)
#define kHarpyCancelButtonTitle     NSLocalizedStringFromTable(@"BACK", @"Localization",nil)
#define kHarpyUpdateButtonTitle     NSLocalizedStringFromTable(@"UPDATE", @"Localization",nil)
#define kHarpyAlertViewMSG  NSLocalizedStringFromTable(@"UPDATEALERT", @"Localization",nil)
