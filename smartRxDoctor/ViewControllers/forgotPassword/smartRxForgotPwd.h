//
//  smartRxForgotPwd.h
//  smartRxDoctor
//
//  Created by Manju Basha on 05/06/15.
//  Copyright (c) 2015 Anil Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface smartRxForgotPwd : UIViewController<MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtMobileNumber;
- (IBAction)resetPasswordClicked:(id)sender;

@end
